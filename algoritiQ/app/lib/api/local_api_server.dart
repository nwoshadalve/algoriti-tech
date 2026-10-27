import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../features/access/application/access_service.dart';
import '../features/access/application/claim_codes.dart';
import '../features/access/domain/access_policy.dart';
import '../features/access/domain/account.dart';
import 'https_server_socket.dart';

/// The tablet's local backend API (`/api/v1`), served over HTTPS to the web
/// app, the TV and other clients on the chamber Wi-Fi. The contract is
/// `docs/api/openapi.yaml`.
///
/// Rules: JSON only, bearer tokens (no cookies), small request bodies, no
/// internal details in errors, nothing cached.
class LocalApiServer {
  LocalApiServer({required this._access});

  final Future<AccessService> Function() _access;
  HttpServer? _server;
  HttpsServerSocket? _socket;

  /// The port actually bound (useful when started on port 0 in tests).
  int get port => _server!.port;

  static const _maxBodyBytes = 16 * 1024;

  Future<HttpServer> _bind(
    InternetAddress address,
    int port,
    SecurityContext? context,
  ) async {
    if (context == null) return HttpServer.bind(address, port, v6Only: false);
    // Also answers a plain-HTTP visit with a redirect to https.
    final socket = await HttpsServerSocket.bind(address, port, context);
    _socket = socket;
    return HttpServer.listenOn(socket);
  }

  /// Both IPv4 and IPv6, so a name that resolves to either one works.
  Future<HttpServer> _bindEverywhere(int port, SecurityContext? context) async {
    try {
      return await _bind(InternetAddress.anyIPv6, port, context);
    } on SocketException {
      // A tablet without IPv6.
      return _bind(InternetAddress.anyIPv4, port, context);
    }
  }

  /// Starts listening. Pass a [context] for HTTPS; without one the server is
  /// plain HTTP (tests only).
  Future<void> start({
    SecurityContext? context,
    int port = 8443,
    InternetAddress? address,
  }) async {
    final server = address != null
        ? await _bind(address, port, context)
        : await _bindEverywhere(port, context);
    _server = server;
    unawaited(
      server.forEach((request) async {
        try {
          await _handle(request);
        } on Object {
          // A failing request must never stop the server.
          await _fail(request.response, 500, 'internal_error', 'Server error.');
        }
      }),
    );
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    await _socket?.close();
    _server = null;
    _socket = null;
  }

  Future<void> _handle(HttpRequest request) async {
    _addCommonHeaders(request);
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      return;
    }
    try {
      switch ((request.method, request.uri.path)) {
        case ('GET', '/'):
          await _home(request);
        case ('GET', '/api/v1/health'):
          await _json(request, 200, {'status': 'ok'});
        case ('GET', '/api/v1/setup/status'):
          await _setupStatus(request);
        case ('POST', '/api/v1/setup/admin'):
          await _registerAdmin(request);
        case ('POST', '/api/v1/auth/login'):
          await _login(request);
        case ('POST', '/api/v1/auth/logout'):
          await _logout(request);
        case ('GET', '/api/v1/me'):
          await _me(request);
        default:
          throw _knownPaths.contains(request.uri.path)
              ? const _ApiError(405, 'method_not_allowed', 'Wrong method.')
              : const _ApiError(404, 'not_found', 'Not found.');
      }
    } on _ApiError catch (error) {
      await _fail(
        request.response,
        error.status,
        error.code,
        error.message,
        extra: error.extra,
        headers: error.headers,
      );
    }
  }

  static const _knownPaths = {
    '/',
    '/api/v1/health',
    '/api/v1/setup/status',
    '/api/v1/setup/admin',
    '/api/v1/auth/login',
    '/api/v1/auth/logout',
    '/api/v1/me',
  };

  Future<void> _setupStatus(HttpRequest request) async {
    final registered = await (await _access()).hasAdmin;
    await _json(request, 200, {
      'adminRegistered': registered,
      // Registration needs the code shown on the tablet.
      'claimCodeRequired': !registered,
    });
  }

  Future<void> _registerAdmin(HttpRequest request) async {
    final body = await _readJson(request);
    final result = await (await _access()).registerAdmin(
      claimCode: _text(body, 'claimCode'),
      username: _text(body, 'username'),
      displayName: _text(body, 'displayName', required: false),
      password: _text(body, 'password'),
    );
    switch (result) {
      case Registered(:final account):
        await _json(request, 201, {'account': _accountJson(account)});
      case ClaimRefused(:final reason, :final attemptsLeft):
        throw _ApiError(
          403,
          switch (reason) {
            ClaimCheck.expired => 'claim_code_expired',
            ClaimCheck.locked => 'claim_code_locked',
            _ => 'claim_code_invalid',
          },
          'The claim code on the tablet was not accepted.',
          extra: {'attemptsLeft': attemptsLeft},
        );
      case AdminAlreadyRegistered():
        throw const _ApiError(
          409,
          'admin_already_registered',
          'An admin account already exists.',
        );
      case CredentialsRefused(:final problem):
        throw _ApiError(400, switch (problem) {
          CredentialProblem.usernameInvalid => 'username_invalid',
          CredentialProblem.passwordTooShort => 'password_too_short',
          CredentialProblem.passwordTooLong => 'password_too_long',
          CredentialProblem.passwordContainsUsername =>
            'password_contains_username',
        }, 'The username or password was not accepted.');
    }
  }

  Future<void> _login(HttpRequest request) async {
    final body = await _readJson(request);
    final result = await (await _access()).login(
      username: _text(body, 'username'),
      password: _text(body, 'password'),
      clientKey: request.connectionInfo?.remoteAddress.address ?? 'unknown',
    );
    switch (result) {
      case LoggedIn(:final token, :final expiresAt, :final account):
        await _json(request, 200, {
          'token': token,
          'expiresAt': expiresAt.toUtc().toIso8601String(),
          'account': _accountJson(account),
        });
      case InvalidCredentials():
        throw const _ApiError(
          401,
          'invalid_credentials',
          'Wrong username or password.',
        );
      case TooManyAttempts(:final retryAfter):
        throw _ApiError(
          429,
          'too_many_attempts',
          'Too many attempts. Try again later.',
          headers: {'retry-after': '${retryAfter.inSeconds + 1}'},
        );
    }
  }

  Future<void> _logout(HttpRequest request) async {
    final token = _bearer(request);
    if (token != null) await (await _access()).logout(token);
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
  }

  Future<void> _me(HttpRequest request) async {
    final token = _bearer(request);
    final account = token == null
        ? null
        : await (await _access()).authenticate(token);
    if (account == null) {
      throw const _ApiError(401, 'unauthorized', 'Sign in first.');
    }
    await _json(request, 200, {'account': _accountJson(account)});
  }

  Future<void> _home(HttpRequest request) async {
    request.response.headers.contentType = ContentType.html;
    request.response.write(
      '<!doctype html><meta charset="utf-8"><title>AlgoritiQ</title>'
      '<p>AlgoritiQ is running on this tablet.</p>',
    );
    await request.response.close();
  }

  Map<String, Object?> _accountJson(Account account) => {
    'id': account.id,
    'username': account.username,
    'displayName': account.displayName,
    'role': account.role.name,
  };

  String? _bearer(HttpRequest request) {
    final header = request.headers.value(HttpHeaders.authorizationHeader);
    if (header == null || !header.startsWith('Bearer ')) return null;
    final token = header.substring(7).trim();
    return token.isEmpty ? null : token;
  }

  Future<Map<String, Object?>> _readJson(HttpRequest request) async {
    if (request.headers.contentType?.mimeType != 'application/json') {
      throw const _ApiError(
        415,
        'unsupported_media_type',
        'Send application/json.',
      );
    }
    if (request.contentLength > _maxBodyBytes) {
      throw const _ApiError(413, 'body_too_large', 'Request body too large.');
    }
    final bytes = <int>[];
    await for (final chunk in request.timeout(const Duration(seconds: 10))) {
      bytes.addAll(chunk);
      if (bytes.length > _maxBodyBytes) {
        throw const _ApiError(413, 'body_too_large', 'Request body too large.');
      }
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is Map<String, Object?>) return decoded;
    } on FormatException {
      // Falls through to the error below.
    }
    throw const _ApiError(400, 'invalid_request', 'Send a JSON object.');
  }

  String _text(Map<String, Object?> body, String key, {bool required = true}) {
    final value = body[key];
    if (value is String) return value;
    if (!required && value == null) return '';
    throw _ApiError(400, 'invalid_request', 'Missing or invalid "$key".');
  }

  void _addCommonHeaders(HttpRequest request) {
    final headers = request.response.headers
      ..set('cache-control', 'no-store')
      ..set('x-content-type-options', 'nosniff');
    // Browsers on the laptop call the API from the web app's address, so
    // reflect the origin. Safe here: authentication uses bearer tokens, never
    // cookies, so a foreign page cannot ride on a signed-in browser.
    final origin = request.headers.value('origin');
    if (origin != null) {
      headers
        ..set('access-control-allow-origin', origin)
        ..set('vary', 'Origin')
        ..set('access-control-allow-headers', 'authorization, content-type')
        ..set('access-control-allow-methods', 'GET, POST, OPTIONS')
        ..set('access-control-max-age', '600');
    }
  }

  Future<void> _json(
    HttpRequest request,
    int status,
    Map<String, Object?> body,
  ) async {
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await request.response.close();
  }

  Future<void> _fail(
    HttpResponse response,
    int status,
    String code,
    String message, {
    Map<String, Object?> extra = const {},
    Map<String, String> headers = const {},
  }) async {
    try {
      response
        ..statusCode = status
        ..headers.contentType = ContentType.json;
      headers.forEach(response.headers.set);
      response.write(
        jsonEncode({
          'error': {'code': code, 'message': message, ...extra},
        }),
      );
      await response.close();
    } on Object {
      // The client already went away.
    }
  }
}

class _ApiError implements Exception {
  const _ApiError(
    this.status,
    this.code,
    this.message, {
    this.extra = const {},
    this.headers = const {},
  });

  final int status;
  final String code;
  final String message;
  final Map<String, Object?> extra;
  final Map<String, String> headers;
}
