// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../features/access/application/access_service.dart';
import '../features/access/application/claim_codes.dart';
import '../features/access/application/user_management_service.dart';
import '../features/access/domain/access_policy.dart';
import '../features/access/domain/account.dart';
import '../features/access/domain/user_query.dart';
import '../features/clinic/application/chamber_service.dart';
import '../features/clinic/application/doctor_profile_service.dart';
import '../features/clinic/domain/chamber.dart';
import '../features/clinic/domain/doctor.dart';
import '../features/home/application/receptionist_scope_service.dart';
import '../platform/backup_gateway.dart';
import '../features/backup/application/backup_service.dart';
import '../features/backup/domain/backup_policy.dart';
import '../features/connectivity/application/test_token_service.dart';
import '../features/monitoring/application/monitoring_service.dart';
import '../features/monitoring/domain/health_snapshot.dart';
import '../features/queue/application/queue_service.dart';
import '../features/queue/domain/queue_models.dart';
import '../features/queue_board/application/queue_board_service.dart';
import '../features/queue_board/domain/board_models.dart';
import '../features/audit/application/audit_query_service.dart';
import 'https_server_socket.dart';
import 'cors_policy.dart';
import 'live_api_web_socket.dart';
import 'live_event_bus.dart';
import 'web_site.dart';

/// The tablet's local backend API (`/api/v1`), served over HTTPS to the web
/// app, the TV and other clients on the chamber Wi-Fi. The contract is
/// `docs/api/openapi.yaml`.
///
/// Rules: JSON only, bearer tokens (no cookies), small request bodies, no
/// internal details in errors, nothing cached.
class LocalApiServer {
  LocalApiServer({
    required this._access,
    Future<UserManagementService> Function()? users,
    Future<DoctorProfileService> Function()? doctor,
    Future<ChamberService> Function()? chambers,
    Future<ReceptionistScopeService> Function()? receptionistScope,
    MonitoringService? monitoring,
    Future<BackupService> Function()? backup,
    Future<QueueService> Function()? queue,
    Future<QueueBoardService> Function()? queueBoard,
    AuditQueryService? auditQuery,
    this._web,
    LiveEventBus? liveEvents,
    CorsPolicy? corsPolicy,
  }) : _users = users,
       _doctor = doctor,
       _chambers = chambers,
       _receptionistScope = receptionistScope,
       _monitoring = monitoring,
       _backup = backup,
       _queue = queue,
       _queueBoard = queueBoard,
       _auditQuery = auditQuery,
       liveEvents = liveEvents ?? LiveEventBus(),
       _corsPolicy = corsPolicy ?? defaultCorsPolicy() {
    _liveSocket = LiveApiWebSocket(bus: this.liveEvents, access: _access);
  }

  final Future<AccessService> Function() _access;
  final Future<UserManagementService> Function()? _users;
  final Future<DoctorProfileService> Function()? _doctor;
  final Future<ChamberService> Function()? _chambers;
  final Future<ReceptionistScopeService> Function()? _receptionistScope;
  final MonitoringService? _monitoring;
  final Future<BackupService> Function()? _backup;
  final Future<QueueService> Function()? _queue;
  final Future<QueueBoardService> Function()? _queueBoard;
  final AuditQueryService? _auditQuery;
  DateTime _startedAt = DateTime.now();
  final CorsPolicy _corsPolicy;

  /// Ordered live events for WebSocket clients. Queue code publishes here.
  final LiveEventBus liveEvents;
  late final LiveApiWebSocket _liveSocket;

  /// The web app served at `/` (null: only the API and a plain home page).
  final WebSite? _web;
  HttpServer? _server;
  HttpsServerSocket? _socket;

  /// The port actually bound (useful when started on port 0 in tests).
  int get port => _server!.port;

  static const _maxBodyBytes = 16 * 1024;
  static const _maxBackupImportBytes = 512 * 1024 * 1024;

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
    _startedAt = DateTime.now();
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
    final path = request.uri.path;
    if (path == LiveApiWebSocket.path) {
      if (request.method == 'GET') {
        await _liveSocket.handle(request);
        return;
      }
      await _fail(request.response, 405, 'method_not_allowed', 'Wrong method.');
      return;
    }
    if (!path.startsWith('/api/')) {
      await _page(request);
      return;
    }
    try {
      if (path.startsWith('/api/v1/users')) {
        await _usersApi(request, path);
        return;
      }
      if (path.startsWith('/api/v1/me/pin/')) {
        final id = path.substring('/api/v1/me/pin/'.length);
        if (id.isEmpty || id.contains('/')) {
          throw const _ApiError(404, 'not_found', 'Not found.');
        }
        if (request.method != 'DELETE') {
          throw const _ApiError(405, 'method_not_allowed', 'Wrong method.');
        }
        await _removePin(request, id);
        return;
      }
      if (path.startsWith('/api/v1/backups')) {
        await _backupsApi(request, path);
        return;
      }
      if (path == '/api/v1/monitoring' ||
          path == '/api/v1/monitoring/bluetooth/enable' ||
          path.startsWith('/api/v1/monitoring/services/')) {
        await _monitoringApi(request, path);
        return;
      }
      if (path == '/api/v1/license' || path.startsWith('/api/v1/chambers')) {
        await _licenseApi(request, path);
        return;
      }
      if (path.startsWith('/api/v1/queue-board') || path.startsWith('/api/v1/patients')) {
        await _queueBoardApi(request, path);
        return;
      }
      if (path.startsWith('/api/v1/queue')) {
        await _queueApi(request, path);
        return;
      }
      if (path.startsWith('/api/v1/audit')) {
        await _auditApi(request, path);
        return;
      }
      if (path == '/api/v1/clinic' ||
          path == '/api/v1/doctor' ||
          path == '/api/v1/doctor/photo') {
        await _clinicApi(request, path);
        return;
      }
      switch ((request.method, path)) {
        case ('GET', '/api/v1/health'):
          await _json(request, 200, {'status': 'ok'});
        case ('GET', '/api/v1/setup/status'):
          await _setupStatus(request);
        case ('POST', '/api/v1/setup/claim/verify'):
          await _verifyClaim(request);
        case ('POST', '/api/v1/setup/admin'):
          await _registerAdmin(request);
        case ('POST', '/api/v1/auth/login'):
          await _login(request);
        case ('POST', '/api/v1/auth/pin/login'):
          await _pinLogin(request);
        case ('POST', '/api/v1/auth/logout'):
          await _logout(request);
        case ('POST', '/api/v1/auth/password/reset/start'):
          await _startReset(request);
        case ('POST', '/api/v1/auth/password/reset'):
          await _finishReset(request);
        case ('GET', '/api/v1/me'):
          await _me(request);
        case ('GET', '/api/v1/me/work-scopes'):
          await _workScopes(request);
        case ('GET', '/api/v1/me/pin'):
          await _listPins(request);
        case ('POST', '/api/v1/me/pin'):
          await _setPin(request);
        case ('POST', '/api/v1/me/password'):
          await _changePassword(request);
        case ('PATCH', '/api/v1/me'):
          await _updateProfile(request);
        case ('GET', '/api/v1/me/photo'):
          await _photo(request);
        case ('PUT', '/api/v1/me/photo'):
          await _changePhoto(request);
        case ('DELETE', '/api/v1/me/photo'):
          await _removePhoto(request);
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
    '/api/v1/health',
    '/api/v1/setup/status',
    '/api/v1/setup/claim/verify',
    '/api/v1/setup/admin',
    '/api/v1/auth/login',
    '/api/v1/auth/logout',
    '/api/v1/auth/pin/login',
    '/api/v1/me/pin',
    '/api/v1/auth/password/reset/start',
    '/api/v1/auth/password/reset',
    '/api/v1/me',
    '/api/v1/me/work-scopes',
    '/api/v1/me/photo',
    '/api/v1/me/password',
    '/api/v1/users',
    '/api/v1/users/context',
    '/api/v1/clinic',
    '/api/v1/license',
    '/api/v1/monitoring',
    '/api/v1/chambers',
    '/api/v1/queue/defaults',
    '/api/v1/audit',
    '/api/v1/doctor',
    '/api/v1/doctor/photo',
    LiveApiWebSocket.path,
  };

  Future<UserManagementService> _userService() async {
    final factory = _users;
    if (factory == null) {
      throw const _ApiError(404, 'not_found', 'Not found.');
    }
    return factory();
  }

  Future<void> _usersApi(HttpRequest request, String path) async {
    if (path == '/api/v1/users/context' && request.method == 'GET') {
      await _usersContext(request);
      return;
    }
    if (path == '/api/v1/users' && request.method == 'GET') {
      await _listUsers(request);
      return;
    }
    if (path == '/api/v1/users' && request.method == 'POST') {
      await _createUser(request);
      return;
    }
    const prefix = '/api/v1/users/';
    if (path.startsWith(prefix)) {
      final rest = path.substring(prefix.length);
      const passwordSuffix = '/password';
      if (rest.endsWith(passwordSuffix) && request.method == 'POST') {
        final id = rest.substring(0, rest.length - passwordSuffix.length);
        if (id.isEmpty || id.contains('/')) {
          throw const _ApiError(404, 'not_found', 'Not found.');
        }
        await _setUserPassword(request, id);
        return;
      }
      if (request.method == 'PATCH' && !rest.contains('/')) {
        await _updateUser(request, rest);
        return;
      }
    }
    if (_knownPaths.contains(path)) {
      throw const _ApiError(405, 'method_not_allowed', 'Wrong method.');
    }
    throw const _ApiError(404, 'not_found', 'Not found.');
  }

  Future<ChamberService> _chamberService() async {
    final factory = _chambers;
    if (factory == null) {
      throw const _ApiError(404, 'not_found', 'Not found.');
    }
    return factory();
  }

  /// The license and its chambers (admins only, doctor license).
  Future<void> _monitoringApi(HttpRequest request, String path) async {
    await _signedInAdmin(request);
    final monitoring = _monitoring;
    if (monitoring == null) {
      throw const _ApiError(404, 'not_found', 'Not found.');
    }
    if (path == '/api/v1/monitoring') {
      if (request.method != 'GET') {
        throw const _ApiError(405, 'method_not_allowed', 'Wrong method.');
      }
      await _json(request, 200, await _healthJson(monitoring));
      return;
    }
    if (path == '/api/v1/monitoring/bluetooth/enable') {
      if (request.method != 'POST') {
        throw const _ApiError(405, 'method_not_allowed', 'Wrong method.');
      }
      final outcome = await monitoring.enableBluetooth();
      await _json(request, 200, {
        'outcome': outcome.code,
        ...await _healthJson(monitoring),
      });
      return;
    }
    if (path == '/api/v1/monitoring/services/printer/test') {
      if (request.method != 'POST') {
        throw const _ApiError(405, 'method_not_allowed', 'Wrong method.');
      }
      final outcome = await monitoring.testPrinter();
      if (outcome == null) {
        throw const _ApiError(404, 'not_found', 'Not found.');
      }
      await _json(request, 200, {
        'outcome': _testPrintOutcomeCode(outcome),
        ...await _healthJson(monitoring),
      });
      return;
    }
    const prefix = '/api/v1/monitoring/services/';
    const suffix = '/retry';
    if (!path.startsWith(prefix) || !path.endsWith(suffix)) {
      throw const _ApiError(404, 'not_found', 'Not found.');
    }
    final id = ServiceId.fromCode(
      path.substring(prefix.length, path.length - suffix.length),
    );
    if (id == null) throw const _ApiError(404, 'not_found', 'Not found.');
    if (request.method != 'POST') {
      throw const _ApiError(405, 'method_not_allowed', 'Wrong method.');
    }
    if (!monitoring.canRetry(id)) {
      throw const _ApiError(
        409,
        'not_retryable',
        'This part cannot be tried again.',
      );
    }
    // Runs on: the page watches the progress in the next readings.
    final started = monitoring.isRetrying(id);
    if (!started) unawaited(monitoring.retry(id));
    await _json(request, 202, await _healthJson(monitoring));
  }

  Future<BackupService> _backupService() async {
    final factory = _backup;
    if (factory == null) {
      throw const _ApiError(404, 'not_found', 'Not found.');
    }
    return factory();
  }

  Future<void> _backupsApi(HttpRequest request, String path) async {
    await _signedInAdmin(request);
    final backup = await _backupService();

    if (path == '/api/v1/backups/settings') {
      if (request.method == 'GET') {
        final settings = await backup.settings();
        await _json(request, 200, _backupSettingsJson(settings));
        return;
      }
      if (request.method == 'PUT') {
        final body = await _readJson(request);
        final schedule = _backupSchedule(body['schedule']);
        final updated = await backup.updateSettings(
          BackupSettings(schedule: schedule),
        );
        await _json(request, 200, _backupSettingsJson(updated));
        return;
      }
      throw const _ApiError(405, 'method_not_allowed', 'Wrong method.');
    }

    if (path == '/api/v1/backups') {
      if (request.method == 'GET') {
        final entries = await backup.list();
        await _json(request, 200, {
          'backups': [for (final e in entries) _backupEntryJson(e)],
        });
        return;
      }
      if (request.method == 'POST') {
        final entry = await backup.createManual();
        await _json(request, 201, _backupEntryJson(entry));
        return;
      }
      throw const _ApiError(405, 'method_not_allowed', 'Wrong method.');
    }

    if (path == '/api/v1/backups/import' && request.method == 'POST') {
      final mime = request.headers.contentType?.mimeType ?? '';
      if (mime != 'application/zip' && mime != 'application/octet-stream') {
        throw const _ApiError(
          415,
          'unsupported_media_type',
          'Send the backup as application/zip.',
        );
      }
      final bytes = await _readBytes(request, _maxBackupImportBytes);
      final entry = await backup.importArchiveBytes(bytes);
      await _json(request, 201, _backupEntryJson(entry));
      return;
    }

    const prefix = '/api/v1/backups/';
    if (!path.startsWith(prefix)) {
      throw const _ApiError(404, 'not_found', 'Not found.');
    }
    final rest = path.substring(prefix.length);
    if (rest.contains('/')) {
      final slash = rest.indexOf('/');
      final id = rest.substring(0, slash);
      final action = rest.substring(slash + 1);
      if (action == 'restore' && request.method == 'POST') {
        await backup.restore(id);
        await _json(request, 200, {'restored': true, 'restartRequired': true});
        return;
      }
      if (action == 'download' && request.method == 'GET') {
        await _downloadBackup(request, backup, id);
        return;
      }
    } else if (request.method == 'DELETE') {
      await backup.delete(rest);
      request.response.statusCode = 204;
      await request.response.close();
      return;
    }
    throw const _ApiError(404, 'not_found', 'Not found.');
  }

  Future<void> _downloadBackup(
    HttpRequest request,
    BackupService backup,
    String id,
  ) async {
    final path = await backup.archivePath(id);
    final file = File(path);
    if (!await file.exists()) {
      throw const _ApiError(404, 'not_found', 'Not found.');
    }
    final response = request.response
      ..statusCode = 200
      ..headers.set('content-type', 'application/zip')
      ..headers.set(
        'content-disposition',
        'attachment; filename="algoritiq-backup-$id.zip"',
      )
      ..contentLength = await file.length();
    await response.addStream(file.openRead());
    await response.close();
  }

  static BackupSchedule _backupSchedule(Object? raw) {
    if (raw is! String) {
      throw const _ApiError(400, 'invalid_request', 'Invalid "schedule".');
    }
    return BackupSchedule.values.asNameMap()[raw] ??
        (throw const _ApiError(400, 'invalid_request', 'Invalid "schedule".'));
  }

  static Map<String, Object?> _backupSettingsJson(BackupSettings settings) => {
    'schedule': settings.schedule.name,
    'retentionLimit': BackupPolicy.retentionLimit,
  };

  static Map<String, Object?> _backupEntryJson(BackupEntry entry) => {
    'id': entry.id,
    'createdAt': entry.createdAt.toIso8601String(),
    'sizeBytes': entry.sizeBytes,
    'kind': entry.kind == BackupKind.automatic ? 'automatic' : 'manual',
  };

  Future<Map<String, Object?>> _healthJson(MonitoringService monitoring) async {
    final snapshot = await monitoring.snapshot(
      apiStartedAt: _startedAt,
      liveClients: liveEvents.clientCount,
    );
    return _snapshotJson(snapshot);
  }

  static Map<String, Object?> _snapshotJson(HealthSnapshot s) => {
    'generatedAt': s.generatedAt.toIso8601String(),
    'deviceUptimeSeconds': s.deviceUptime.inSeconds,
    'resources': {
      'cpu': _resourceJson(s.cpu),
      'ram': _resourceJson(s.ram),
      'storage': _resourceJson(s.storage),
      'bluetooth': _resourceJson(s.bluetooth),
    },
    'services': [for (final service in s.services) _serviceJson(service)],
  };

  static Map<String, Object?> _resourceJson(ResourceHealth r) => {
    'status': r.status.name,
    'reason': ?r.reason?.code,
    'percent': ?r.percent?.roundToDouble(),
    'usedBytes': ?r.usedBytes,
    'totalBytes': ?r.totalBytes,
    'detail': ?r.detail,
  };

  static Map<String, Object?> _serviceJson(ServiceHealth s) => {
    'id': s.id.code,
    'status': s.status.name,
    'retryable': s.retryable,
    'reason': ?s.reason?.code,
    'uptimeSeconds': ?s.uptime?.inSeconds,
    'clients': ?s.clients,
    if (s.retry case final retry?)
      'retry': {'attempt': retry.attempt, 'max': retry.max},
  };

  static String _testPrintOutcomeCode(TestTokenOutcome outcome) =>
      switch (outcome) {
        TestTokenOutcome.printed => 'printed',
        TestTokenOutcome.failed => 'failed',
        TestTokenOutcome.notConnected => 'not_connected',
        TestTokenOutcome.noDetails => 'no_details',
      };

  Future<void> _licenseApi(HttpRequest request, String path) async {
    final method = request.method;
    final admin = await _signedInAdmin(request);
    final service = await _chamberService();
    try {
      if (path == '/api/v1/license' && method == 'GET') {
        return await _json(request, 200, {
          'license': _licenseJson(await service.summary(admin)),
        });
      }
      if (path == '/api/v1/chambers' && method == 'GET') {
        return await _json(request, 200, {
          'chambers': [
            for (final chamber in await service.list(admin))
              _chamberJson(chamber),
          ],
        });
      }
      if (path == '/api/v1/chambers' && method == 'POST') {
        final body = await _readJson(request);
        final result = await service.create(
          admin,
          name: _text(body, 'name'),
          location: _text(body, 'location'),
          phone: _text(body, 'phone'),
        );
        return await _chamberResult(request, result, 201);
      }
      const prefix = '/api/v1/chambers/';
      if (path.startsWith(prefix)) {
        final id = path.substring(prefix.length);
        if (id.isEmpty || id.contains('/')) {
          throw const _ApiError(404, 'not_found', 'Not found.');
        }
        if (method == 'PATCH') {
          final body = await _readJson(request);
          final result = await service.update(
            admin,
            id,
            name: _text(body, 'name'),
            location: _text(body, 'location'),
            phone: _text(body, 'phone'),
          );
          return await _chamberResult(request, result, 200);
        }
        if (method == 'DELETE') {
          final problem = await service.delete(admin, id);
          if (problem != null) throw _chamberError(problem);
          request.response.statusCode = HttpStatus.noContent;
          return await request.response.close();
        }
      }
      throw const _ApiError(405, 'method_not_allowed', 'Wrong method.');
    } on UserManagementForbidden {
      throw const _ApiError(403, 'forbidden', 'Admins only.');
    } on ChambersUnavailable {
      throw const _ApiError(
        404,
        'license_unavailable',
        'This clinic is not licensed for chambers of one doctor.',
      );
    }
  }

  Future<void> _chamberResult(
    HttpRequest request,
    ChamberResult result,
    int status,
  ) async {
    switch (result) {
      case ChamberSaved(:final chamber):
        await _json(request, status, {'chamber': _chamberJson(chamber)});
      case ChamberRefused(:final problem):
        throw _chamberError(problem);
    }
  }

  _ApiError _chamberError(ChamberProblem problem) => switch (problem) {
    ChamberProblem.nameMissing => const _ApiError(
      400,
      'chamber_name_missing',
      'The chamber needs a name.',
    ),
    ChamberProblem.locationMissing => const _ApiError(
      400,
      'chamber_location_missing',
      'The chamber needs an address.',
    ),
    ChamberProblem.phoneMissing => const _ApiError(
      400,
      'chamber_phone_missing',
      'The chamber needs a phone number.',
    ),
    ChamberProblem.phoneInvalid => const _ApiError(
      400,
      'chamber_phone_invalid',
      'The phone number is not valid.',
    ),
    ChamberProblem.tooLong => const _ApiError(
      400,
      'chamber_too_long',
      'A value is too long.',
    ),
    ChamberProblem.limitReached => const _ApiError(
      409,
      'chamber_limit_reached',
      'The license allows no more chambers.',
    ),
    ChamberProblem.notFound => const _ApiError(404, 'not_found', 'Not found.'),
    ChamberProblem.lastChamber => const _ApiError(
      409,
      'last_chamber',
      'The last chamber cannot be deleted.',
    ),
  };

  Map<String, Object?> _chamberJson(Chamber chamber) => {
    'id': chamber.id,
    'name': chamber.name,
    'location': chamber.location ?? '',
    'phone': chamber.phone ?? '',
  };

  Map<String, Object?> _licenseJson(LicenseSummary license) => {
    'type': license.type.name,
    'maxDoctors': license.maxDoctors,
    'maxChambers': license.maxChambers,
    'chambersUsed': license.chambersUsed,
    'issuedAt': license.issuedAt.toIso8601String(),
    'expiresAt': license.expiresAt?.toIso8601String(),
    'status': license.status.name,
  };

  Future<DoctorProfileService> _doctorService() async {
    final factory = _doctor;
    if (factory == null) {
      throw const _ApiError(404, 'not_found', 'Not found.');
    }
    return factory();
  }

  /// `/clinic` (what the clinic is licensed for, for any signed-in person) and
  /// the doctor of a doctor license: `/doctor` and `/doctor/photo`, admins only.
  Future<void> _clinicApi(HttpRequest request, String path) async {
    final method = request.method;
    if (path == '/api/v1/clinic' && method == 'GET') {
      await _signedIn(request);
      final type = await (await _doctorService()).licenseType();
      await _json(request, 200, {'licenseType': type?.name});
      return;
    }
    if (path == '/api/v1/doctor') {
      if (method == 'GET') return _guardDoctor(request, _showDoctor);
      if (method == 'PUT') return _guardDoctor(request, _saveDoctor);
    }
    if (path == '/api/v1/doctor/photo') {
      if (method == 'GET') return _guardDoctor(request, _doctorPhoto);
      if (method == 'PUT') return _guardDoctor(request, _changeDoctorPhoto);
      if (method == 'DELETE') return _guardDoctor(request, _removeDoctorPhoto);
    }
    throw const _ApiError(405, 'method_not_allowed', 'Wrong method.');
  }

  Future<void> _guardDoctor(
    HttpRequest request,
    Future<void> Function(HttpRequest, Account, DoctorProfileService) action,
  ) async {
    final admin = await _signedInAdmin(request);
    try {
      await action(request, admin, await _doctorService());
    } on UserManagementForbidden {
      throw const _ApiError(403, 'forbidden', 'Admins only.');
    } on DoctorProfileUnavailable {
      throw const _ApiError(
        404,
        'doctor_unavailable',
        'This clinic has no single doctor to edit.',
      );
    }
  }

  Future<Map<String, Object?>> _doctorJson(
    DoctorProfileService service,
    Doctor doctor,
  ) async => {
    'id': doctor.id,
    'name': doctor.name,
    'degrees': doctor.degrees,
    'designation': doctor.designation ?? '',
    'workplace': doctor.workplace ?? '',
    'registrationNumber': doctor.registrationNumber ?? '',
    'specialty': doctor.specialty ?? '',
    // 0 when there is no photo; changes whenever the photo does.
    'photoVersion': await service.photoVersion(doctor),
  };

  Future<void> _showDoctor(
    HttpRequest request,
    Account admin,
    DoctorProfileService service,
  ) async {
    final doctor = await service.load(admin);
    await _json(request, 200, {'doctor': await _doctorJson(service, doctor)});
  }

  Future<void> _saveDoctor(
    HttpRequest request,
    Account admin,
    DoctorProfileService service,
  ) async {
    final body = await _readJson(request);
    final result = await service.update(
      admin,
      DoctorDetails(
        name: _text(body, 'name'),
        degrees: _stringList(body, 'degrees', required: false),
        designation: _text(body, 'designation', required: false),
        workplace: _text(body, 'workplace', required: false),
        registrationNumber: _text(body, 'registrationNumber', required: false),
        specialty: _text(body, 'specialty', required: false),
      ),
    );
    switch (result) {
      case DoctorSaved(:final doctor):
        await _json(request, 200, {
          'doctor': await _doctorJson(service, doctor),
        });
      case DoctorRefused(:final problem):
        throw switch (problem) {
          DoctorProblem.nameMissing => const _ApiError(
            400,
            'doctor_name_missing',
            'The doctor needs a name.',
          ),
          DoctorProblem.tooLong => const _ApiError(
            400,
            'doctor_too_long',
            'A value is too long.',
          ),
          DoctorProblem.tooManyDegrees => const _ApiError(
            400,
            'doctor_too_many_degrees',
            'Too many degrees.',
          ),
        };
    }
  }

  Future<void> _doctorPhoto(
    HttpRequest request,
    Account admin,
    DoctorProfileService service,
  ) async {
    final bytes = await service.photo(admin);
    if (bytes == null) throw const _ApiError(404, 'not_found', 'No photo.');
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.set('content-type', 'image/${AccessPolicy.imageType(bytes)}')
      ..contentLength = bytes.length
      ..add(bytes);
    await request.response.close();
  }

  Future<void> _changeDoctorPhoto(
    HttpRequest request,
    Account admin,
    DoctorProfileService service,
  ) async {
    final bytes = await _readBytes(request, AccessPolicy.maxPhotoBytes);
    final problem = await service.setPhoto(admin, bytes);
    switch (problem) {
      case null:
        await _showDoctor(request, admin, service);
      case DoctorPhotoProblem.unsupported:
        throw const _ApiError(
          415,
          'unsupported_media_type',
          'Send a JPEG, PNG or WebP picture.',
        );
      case DoctorPhotoProblem.tooLarge:
        throw const _ApiError(413, 'body_too_large', 'The picture is too big.');
    }
  }

  Future<void> _removeDoctorPhoto(
    HttpRequest request,
    Account admin,
    DoctorProfileService service,
  ) async {
    await service.removePhoto(admin);
    await _showDoctor(request, admin, service);
  }

  Future<Account> _signedInAdmin(HttpRequest request) async {
    final account = await _signedIn(request);
    if (account.role != Role.admin) {
      throw const _ApiError(403, 'forbidden', 'Admins only.');
    }
    return account;
  }

  Future<QueueService> _queueService() async {
    final factory = _queue;
    if (factory == null) {
      throw const _ApiError(404, 'not_found', 'Not found.');
    }
    return factory();
  }

  Future<void> _queueApi(HttpRequest request, String path) async {
    final admin = await _signedInAdmin(request);
    late final QueueService service;
    try {
      service = await _queueService();
    } on Object catch (e) {
      await _fail(
        request.response,
        500,
        'internal_error',
        _internalErrorMessage(e),
      );
      return;
    }
    try {
      if (path == '/api/v1/queue/defaults' && request.method == 'GET') {
        try {
          final loaded = await service.loadClinicDefaults(admin);
          await _json(request, 200, {
            'policy': _queuePolicyJson(loaded.policy),
            'types': [for (final t in loaded.types) _queueTypeJson(t)],
          });
        } on Object catch (e) {
          await _fail(
            request.response,
            500,
            'internal_error',
            _internalErrorMessage(e),
          );
        }
        return;
      }
      if (path == '/api/v1/queue/defaults' && request.method == 'PATCH') {
        final body = await _readJson(request);
        final policyMap = _queuePolicyPatchMap(body);
        await service.updateClinicPolicy(
          admin,
          QueuePolicy(
            timeZone:
                policyMap['timeZone'] as String? ?? QueuePolicy.defaults.timeZone,
            dayBoundary:
                policyMap['dayBoundary'] as String? ??
                QueuePolicy.defaults.dayBoundary,
            autoStart:
                policyMap['autoStart'] as bool? ?? QueuePolicy.defaults.autoStart,
          ),
        );
        if (body['types'] is List) {
          final types = [
            for (final raw in body['types']! as List)
              _queueTypeFromJson(raw as Map<String, Object?>),
          ];
          await service.replaceClinicTypes(admin, types);
        }
        final loaded = await service.loadClinicDefaults(admin);
        _publishQueueConfigurationChanged(scope: 'clinic');
        await _json(request, 200, {
          'policy': _queuePolicyJson(loaded.policy),
          'types': [for (final t in loaded.types) _queueTypeJson(t)],
        });
        return;
      }
      const prefix = '/api/v1/queue/chambers/';
      if (path.startsWith(prefix)) {
        final rest = path.substring(prefix.length);
        final parts = rest.split('/');
        final chamberId = parts.first;
        if (parts.length == 1 && request.method == 'GET') {
          final loaded = await service.loadChamberConfiguration(
            admin,
            chamberId,
          );
          await _json(request, 200, {
            'settings': {
              'useClinicDefaults': loaded.settings.useClinicDefaults,
              'dayBoundaryOverride': loaded.settings.dayBoundaryOverride,
              'autoStartOverride': loaded.settings.autoStartOverride,
            },
            'effectivePolicy': _queuePolicyJson(loaded.effectivePolicy),
            'types': [for (final t in loaded.types) _queueTypeJson(t)],
            'session': loaded.session == null
                ? null
                : _queueSessionJson(loaded.session!),
          });
          return;
        }
        if (parts.length == 1 && request.method == 'PATCH') {
          final body = await _readJson(request);
          if (body['types'] is! List) {
            throw const _ApiError(400, 'invalid_body', 'Missing types array.');
          }
          final types = [
            for (final raw in body['types']! as List)
              _queueTypeFromJson(raw as Map<String, Object?>),
          ];
          final saved = await service.replaceChamberTypes(
            admin,
            chamberId,
            types,
          );
          _publishQueueConfigurationChanged(
            scope: 'chamber',
            chamberId: chamberId,
          );
          await _json(request, 200, {
            'settings': {
              'useClinicDefaults': saved.settings.useClinicDefaults,
              'dayBoundaryOverride': saved.settings.dayBoundaryOverride,
              'autoStartOverride': saved.settings.autoStartOverride,
            },
            'types': [for (final t in saved.types) _queueTypeJson(t)],
          });
          return;
        }
        if (parts.length == 2 &&
            parts[1] == 'customize' &&
            request.method == 'POST') {
          final settings = await service.customizeChamberQueue(admin, chamberId);
          _publishQueueConfigurationChanged(
            scope: 'chamber',
            chamberId: chamberId,
          );
          await _json(request, 200, {
            'settings': {
              'useClinicDefaults': settings.useClinicDefaults,
              'dayBoundaryOverride': settings.dayBoundaryOverride,
              'autoStartOverride': settings.autoStartOverride,
            },
          });
          return;
        }
        if (parts.length == 2 &&
            parts[1] == 'clear-override' &&
            request.method == 'POST') {
          final settings = await service.clearChamberQueueOverride(
            admin,
            chamberId,
          );
          _publishQueueConfigurationChanged(
            scope: 'chamber',
            chamberId: chamberId,
          );
          await _json(request, 200, {
            'settings': {
              'useClinicDefaults': settings.useClinicDefaults,
              'dayBoundaryOverride': settings.dayBoundaryOverride,
              'autoStartOverride': settings.autoStartOverride,
            },
          });
          return;
        }
        if (parts.length == 2 && parts[1] == 'policy' && request.method == 'PATCH') {
          final body = await _readJson(request);
          final boundary = body['dayBoundary'] as String?;
          if (boundary == null || boundary.trim().isEmpty) {
            throw const _ApiError(400, 'invalid_body', 'Missing dayBoundary.');
          }
          await service.updateChamberDayBoundary(admin, chamberId, boundary.trim());
          final loaded = await service.loadChamberConfiguration(admin, chamberId);
          _publishQueueConfigurationChanged(scope: 'chamber', chamberId: chamberId);
          await _json(request, 200, {
            'settings': {
              'useClinicDefaults': loaded.settings.useClinicDefaults,
              'dayBoundaryOverride': loaded.settings.dayBoundaryOverride,
              'autoStartOverride': loaded.settings.autoStartOverride,
            },
            'effectivePolicy': _queuePolicyJson(loaded.effectivePolicy),
          });
          return;
        }
        if (parts.length == 3 && parts[1] == 'session') {
          switch ((request.method, parts[2])) {
            case ('POST', 'start'):
              final session = await service.startSession(admin, chamberId);
              await _json(request, 200, {
                'session': session == null ? null : _queueSessionJson(session),
              });
            case ('POST', 'close'):
              await service.closeSession(admin, chamberId);
              await _json(request, 204, {});
            case ('POST', 'force-close'):
              final body = await _readJson(request);
              await service.forceCloseSession(
                admin,
                chamberId,
                body['reason'] as String? ?? '',
              );
              await _json(request, 204, {});
            default:
              throw const _ApiError(405, 'method_not_allowed', 'Wrong method.');
          }
          return;
        }
      }
      throw const _ApiError(404, 'not_found', 'Not found.');
    } on QueueServiceRefused catch (refused) {
      final error = _queueError(refused);
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

  Future<QueueBoardService> _queueBoardService() async {
    final factory = _queueBoard;
    if (factory == null) {
      throw const _ApiError(404, 'not_found', 'Not found.');
    }
    return factory();
  }

  Future<void> _queueBoardApi(HttpRequest request, String path) async {
    final admin = await _signedInAdmin(request);
    final service = await _queueBoardService();
    try {
      if (path == '/api/v1/patients/search' && request.method == 'POST') {
        final body = await _readJson(request);
        final patients = await service.searchPatients(
          admin,
          body['query'] as String? ?? '',
        );
        await _json(request, 200, {
          'patients': [for (final p in patients) _patientSummaryJson(p)],
        });
        return;
      }
      if (path == '/api/v1/patients' && request.method == 'POST') {
        final body = await _readJson(request);
        final saved = await service.registerPatient(
          admin,
          _patientInputFromJson(body),
          commandId: body['commandId'] as String? ?? '',
        );
        await _json(request, 200, _patientSummaryJson(saved));
        return;
      }
      const prefix = '/api/v1/queue-board/chambers/';
      if (path.startsWith(prefix)) {
        final rest = path.substring(prefix.length);
        final parts = rest.split('/');
        final chamberId = parts.first;
        if (parts.length == 1 && request.method == 'GET') {
          final board = await service.loadBoard(admin, chamberId);
          await _json(request, 200, _boardSnapshotJson(board));
          return;
        }
        if (parts.length == 3 &&
            parts[1] == 'session' &&
            parts[2] == 'start' &&
            request.method == 'POST') {
          await service.startSession(admin, chamberId);
          await _json(request, 204, {});
          return;
        }
        if (parts.length == 2 &&
            parts[1] == 'issue-preview' &&
            request.method == 'POST') {
          final body = await _readJson(request);
          final preview = await service.previewIssue(
            admin,
            chamberId,
            body['patientId'] as String? ?? '',
            body['queueTypeId'] as String? ?? '',
            feeBdt: body['feeBdt'] as int?,
          );
          await _json(request, 200, _issuePreviewJson(preview));
          return;
        }
        if (parts.length == 2 && parts[1] == 'issue' && request.method == 'POST') {
          final body = await _readJson(request);
          final issued = await service.issueToken(
            admin,
            chamberId,
            body['patientId'] as String? ?? '',
            body['queueTypeId'] as String? ?? '',
            feeBdt: body['feeBdt'] as int?,
            commandId: body['commandId'] as String? ?? '',
          );
          await _json(request, 200, _issuedTokenJson(issued));
          return;
        }
        if (parts.length == 2 &&
            parts[1] == 'call-next' &&
            request.method == 'POST') {
          final body = await _readJson(request);
          final token = await service.callNext(
            admin,
            chamberId,
            body['queueTypeId'] as String? ?? '',
          );
          await _json(request, 200, _boardTokenJson(token));
          return;
        }
        if (parts.length == 2 && parts[1] == 'recall' && request.method == 'POST') {
          final body = await _readJson(request);
          await service.recall(
            admin,
            chamberId,
            body['queueTypeId'] as String? ?? '',
          );
          await _json(request, 204, {});
          return;
        }
      }
      const tokenPrefix = '/api/v1/queue-board/tokens/';
      if (path.startsWith(tokenPrefix)) {
        final rest = path.substring(tokenPrefix.length);
        final parts = rest.split('/');
        final tokenId = parts.first;
        if (parts.length == 2 && request.method == 'POST') {
          final body = await _readJson(request);
          switch (parts[1]) {
            case 'entered':
              final entered = await service.markEntered(admin, tokenId);
              await _json(request, 200, _boardTokenJson(entered));
            case 'skipped':
              final skipped = await service.markSkipped(admin, tokenId);
              await _json(request, 200, _boardTokenJson(skipped));
            case 'cancel':
              final cancelled = await service.cancelToken(
                admin,
                tokenId,
                body['reason'] as String? ?? '',
              );
              await _json(request, 200, _boardTokenJson(cancelled));
            case 'reprint':
              final attemptId = await service.reprint(
                admin,
                tokenId,
                body['reason'] as String? ?? '',
              );
              await _json(request, 200, {'printAttemptId': attemptId});
            default:
              throw const _ApiError(405, 'method_not_allowed', 'Wrong method.');
          }
          return;
        }
      }
      throw const _ApiError(404, 'not_found', 'Not found.');
    } on QueueBoardRefused catch (refused) {
      throw _boardError(refused);
    }
  }

  _ApiError _boardError(QueueBoardRefused refused) {
    return switch (refused.problem) {
      QueueBoardProblem.forbidden => const _ApiError(
        403,
        'forbidden',
        'Admins only.',
      ),
      QueueBoardProblem.chamberNotFound => const _ApiError(
        404,
        'not_found',
        'Unknown chamber.',
      ),
      QueueBoardProblem.sessionClosed => const _ApiError(
        409,
        'queue_session_missing',
        'Start a queue session first.',
      ),
      QueueBoardProblem.duplicatePhoneNeedsConfirm => const _ApiError(
        409,
        'duplicate_phone',
        'This phone already has patients. Confirm to register another.',
      ),
      QueueBoardProblem.patientHasActiveToken => const _ApiError(
        409,
        'patient_has_active_token',
        'This patient already has a token in this session.',
      ),
      QueueBoardProblem.rangeExhausted => const _ApiError(
        409,
        'queue_range_exhausted',
        'This queue type has no serials left.',
      ),
      QueueBoardProblem.noWaitingToken => const _ApiError(
        409,
        'no_waiting_token',
        'No one is waiting in this queue.',
      ),
      QueueBoardProblem.noCalledToken => const _ApiError(
        409,
        'no_called_token',
        'Nothing to recall for this queue.',
      ),
      QueueBoardProblem.unresolvedCalledToken => const _ApiError(
        409,
        'unresolved_called_token',
        'Mark the current call entered, missed, or cancelled first.',
      ),
      QueueBoardProblem.printerBusy => const _ApiError(
        409,
        'printer_busy',
        'Wait for the current print attempt to finish.',
      ),
      QueueBoardProblem.validation ||
      QueueBoardProblem.commandRequired => const _ApiError(
        400,
        'validation_failed',
        'Check the fields and try again.',
      ),
    };
  }

  Map<String, Object?> _boardSnapshotJson(BoardSnapshot board) => {
    'chamberId': board.chamberId,
    'chamberName': board.chamberName,
    'sessionId': board.sessionId,
    'sessionOpen': board.sessionOpen,
    'calledToken': board.calledToken == null
        ? null
        : _boardTokenJson(board.calledToken!),
    'queueControls': [
      for (final c in board.queueControls) _queueControlJson(c),
    ],
    'tokens': [for (final t in board.tokens) _boardTokenJson(t)],
    'printerBusyTokenId': board.printerBusyTokenId,
  };

  Map<String, Object?> _queueControlJson(QueueTypeBoardControl c) => {
    'queueTypeId': c.queueTypeId,
    'englishName': c.englishName,
    'bengaliName': c.bengaliName,
    'waitingCount': c.waitingCount,
    'nextSerial': c.nextSerial,
    'canCallNext': c.canCallNext,
    'canRecall': c.canRecall,
  };

  Map<String, Object?> _boardTokenJson(BoardTokenView t) => {
    'id': t.id,
    'serial': t.serial,
    'queueTypeId': t.queueTypeId,
    'queueEnglishName': t.queueEnglishName,
    'queueBengaliName': t.queueBengaliName,
    'patientId': t.patientId,
    'clinicPatientId': t.clinicPatientId,
    'patientBengaliName': t.patientBengaliName,
    'status': t.status.apiValue,
    'issuedAt': t.issuedAt.toUtc().toIso8601String(),
    'firstCalledAt': t.firstCalledAt?.toUtc().toIso8601String(),
    'enteredAt': t.enteredAt?.toUtc().toIso8601String(),
    'feeBdt': t.feeBdt,
    'latestPrintStatus': t.latestPrintStatus,
  };

  Map<String, Object?> _patientSummaryJson(PatientSummary p) => {
    'id': p.id,
    'patientNumber': p.patientNumber,
    'clinicPatientId': p.clinicPatientId,
    'bengaliName': p.bengaliName,
    'englishName': p.englishName,
    'phoneNormalized': p.phoneNormalized,
    'gender': p.gender?.apiValue,
    'ageLabel': p.ageLabel,
  };

  Map<String, Object?> _issuePreviewJson(IssuePreview preview) => {
    'patient': _patientSummaryJson(preview.patient),
    'chamberName': preview.chamberName,
    'queueTypeId': preview.queueTypeId,
    'queueEnglishName': preview.queueEnglishName,
    'queueBengaliName': preview.queueBengaliName,
    'previewSerial': preview.previewSerial,
    'feeBdt': preview.feeBdt,
  };

  Map<String, Object?> _issuedTokenJson(IssuedTokenResult issued) => {
    'token': _boardTokenJson(issued.token),
    'printAttemptId': issued.printAttemptId,
    'printStatus': issued.printStatus,
  };

  PatientInput _patientInputFromJson(Map<String, Object?> body) => PatientInput(
    bengaliName: body['bengaliName'] as String? ?? '',
    phone: body['phone'] as String? ?? '',
    englishName: body['englishName'] as String?,
    gender: PatientGender.parse(body['gender'] as String?),
    dateOfBirthMs: body['dateOfBirthMs'] as int?,
    birthYear: body['birthYear'] as int?,
    approximateAgeYears: body['approximateAgeYears'] as int?,
    locality: body['locality'] as String?,
    legacyFileNumber: body['legacyFileNumber'] as String?,
    adminNote: body['adminNote'] as String?,
    hasPaperFile: body['hasPaperFile'] as bool? ?? false,
    confirmDuplicatePhone: body['confirmDuplicatePhone'] as bool? ?? false,
  );

  Future<void> _auditApi(HttpRequest request, String path) async {
    await _signedInAdmin(request);
    final audit = _auditQuery;
    if (audit == null || path != '/api/v1/audit' || request.method != 'GET') {
      throw const _ApiError(404, 'not_found', 'Not found.');
    }
    final params = request.uri.queryParameters;
    final page = await audit.list(
      AuditLogQuery(
        offset: int.tryParse(params['offset'] ?? '0') ?? 0,
        fromMs: params['from'] == null
            ? null
            : DateTime.parse(params['from']!).toUtc().millisecondsSinceEpoch,
        toMs: params['to'] == null
            ? null
            : DateTime.parse(params['to']!).toUtc().millisecondsSinceEpoch,
        actionPrefix: params['actionPrefix'],
        outcome: params['outcome'],
      ),
    );
    await _json(request, 200, {
      'entries': [for (final e in page.entries) _auditEntryJson(e)],
      'total': page.total,
      'nextOffset': page.nextOffset,
    });
  }

  _ApiError _queueError(QueueServiceRefused refused) {
    return switch (refused.problem) {
      QueueServiceProblem.forbidden => const _ApiError(
        403,
        'forbidden',
        'Admins only.',
      ),
      QueueServiceProblem.validation => _ApiError(
        400,
        'queue_validation_failed',
        'Check the queue type fields.',
        extra: {
          'problems': refused.validation?.keys.map((p) => p.name).toList(),
        },
      ),
      QueueServiceProblem.openSession => const _ApiError(
        409,
        'queue_session_open',
        'Close the current session first.',
      ),
      QueueServiceProblem.noOpenSession => const _ApiError(
        404,
        'queue_session_missing',
        'There is no open session for this chamber.',
      ),
      QueueServiceProblem.reasonRequired => const _ApiError(
        400,
        'queue_reason_required',
        'A reason is required.',
      ),
      QueueServiceProblem.inheritClinicDefaults => const _ApiError(
        409,
        'queue_chamber_inherits_defaults',
        'This chamber uses clinic queue types. Edit clinic defaults instead.',
      ),
      QueueServiceProblem.chamberNotFound => const _ApiError(
        404,
        'not_found',
        'Chamber not found.',
      ),
      _ => const _ApiError(400, 'queue_refused', 'The change was refused.'),
    };
  }

  Map<String, Object?> _queuePolicyJson(QueuePolicy policy) => {
    'timeZone': policy.timeZone,
    'dayBoundary': policy.dayBoundary,
    'autoStart': policy.autoStart,
  };

  void _publishQueueConfigurationChanged({
    required String scope,
    String? chamberId,
  }) {
    liveEvents.publish('queue.configuration.changed', {
      'scope': scope,
      if (chamberId != null) 'chamberId': chamberId,
    });
  }

  Map<String, Object?> _queuePolicyPatchMap(Map<String, Object?> body) {
    final nested = body['policy'];
    if (nested is Map<String, Object?>) return nested;
    if (nested is Map) return Map<String, Object?>.from(nested);
    return body;
  }

  Map<String, Object?> _queueTypeJson(QueueTypeConfig type) => {
    'id': type.id,
    'englishName': type.englishName,
    'bengaliName': type.bengaliName,
    'startNumber': type.startNumber,
    'endNumber': type.endNumber,
    'displayOrder': type.displayOrder,
    'enabled': type.enabled,
  };

  QueueTypeConfig _queueTypeFromJson(Map<String, Object?> json) =>
      QueueTypeConfig(
        id: json['id'] as String,
        englishName: json['englishName'] as String? ?? '',
        bengaliName: json['bengaliName'] as String? ?? '',
        startNumber: _queueNumberFromJson(json['startNumber']),
        endNumber: _queueNumberFromJson(json['endNumber']),
        displayOrder: _queueNumberFromJson(json['displayOrder']),
        enabled: json['enabled'] as bool? ?? true,
      );

  int _queueNumberFromJson(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  Map<String, Object?> _queueSessionJson(QueueSessionView session) => {
    'id': session.id,
    'chamberId': session.chamberId,
    'businessDate': session.businessDate,
    'status': session.status.apiValue,
    'openedAt': session.openedAt.toUtc().toIso8601String(),
    'openedByAccountId': session.openedByAccountId,
    'usage': [
      for (final u in session.usage)
        {
          'queueTypeId': u.queueTypeId,
          'englishName': u.englishName,
          'bengaliName': u.bengaliName,
          'startNumber': u.startNumber,
          'endNumber': u.endNumber,
          'issuedCount': u.issuedCount,
          'nextNumber': u.nextNumber,
          'enabled': u.enabled,
          'capacity': u.capacity,
        },
    ],
  };

  Map<String, Object?> _auditEntryJson(AuditLogEntryView entry) => {
    'id': entry.id,
    'occurredAt': entry.occurredAt.toUtc().toIso8601String(),
    'action': entry.action,
    'category': entry.category,
    'outcome': entry.outcome,
    'actorDisplayName': entry.actorDisplayName,
    'actorRole': entry.actorRole,
    'safeMetadata': entry.safeMetadata,
    'detail': entry.detail,
  };

  Future<void> _usersContext(HttpRequest request) async {
    final admin = await _signedInAdmin(request);
    try {
      final context = await (await _userService()).loadContext(admin);
      await _json(request, 200, _usersContextJson(context));
    } on UserManagementForbidden {
      throw const _ApiError(403, 'forbidden', 'Admins only.');
    }
  }

  Future<void> _listUsers(HttpRequest request) async {
    final admin = await _signedInAdmin(request);
    final query = _userQuery(request.uri);
    try {
      final page = await (await _userService()).listUsers(admin, query: query);
      await _json(request, 200, {
        'users': [for (final user in page.users) _managedUserJson(user)],
        'total': page.total,
        'nextCursor': page.nextOffset == null
            ? null
            : _encodeCursor(page.nextOffset!),
      });
    } on UserManagementForbidden {
      throw const _ApiError(403, 'forbidden', 'Admins only.');
    }
  }

  /// `search`, `role`, `status`, `sort`, `dir`, `limit` and `cursor` of
  /// `GET /users`. Anything unknown is a 400, never silently ignored.
  UserQuery _userQuery(Uri uri) {
    final p = uri.queryParameters;
    _ApiError bad(String what) =>
        _ApiError(400, 'invalid_request', 'Invalid "$what".');

    final roleRaw = p['role'];
    final role = roleRaw == null || roleRaw.isEmpty
        ? null
        : Role.values.asNameMap()[roleRaw] ?? (throw bad('role'));
    final statusRaw = p['status'];
    if (statusRaw != null &&
        statusRaw.isNotEmpty &&
        statusRaw != 'active' &&
        statusRaw != 'inactive') {
      throw bad('status');
    }
    final sortRaw = p['sort'];
    final sort = sortRaw == null || sortRaw.isEmpty
        ? UserSort.name
        : UserSort.values.asNameMap()[sortRaw] ?? (throw bad('sort'));
    final dir = p['dir'];
    if (dir != null && dir != 'asc' && dir != 'desc') throw bad('dir');
    final limitRaw = p['limit'];
    final limit = limitRaw == null
        ? UserQuery.defaultLimit
        : int.tryParse(limitRaw) ?? (throw bad('limit'));
    final search = p['search'] ?? '';
    if (search.length > 100) throw bad('search');
    return UserQuery(
      search: search,
      role: role,
      status: statusRaw == null || statusRaw.isEmpty ? null : statusRaw,
      sort: sort,
      descending: dir == 'desc',
      offset: _decodeCursor(p['cursor']),
      limit: limit,
    );
  }

  /// Opaque to clients: where the next page starts.
  String _encodeCursor(int offset) =>
      base64Url.encode(utf8.encode('o:$offset')).replaceAll('=', '');

  int _decodeCursor(String? cursor) {
    if (cursor == null || cursor.isEmpty) return 0;
    try {
      final text = utf8.decode(base64Url.decode(base64Url.normalize(cursor)));
      final offset = text.startsWith('o:')
          ? int.tryParse(text.substring(2))
          : null;
      if (offset != null && offset >= 0) return offset;
    } on FormatException {
      // Falls through to the error below.
    }
    throw const _ApiError(400, 'invalid_request', 'Invalid "cursor".');
  }

  Future<void> _createUser(HttpRequest request) async {
    final admin = await _signedInAdmin(request);
    final body = await _readJson(request);
    final scopeIds = _stringList(body, 'scopeIds', required: false);
    try {
      final result = await (await _userService()).createUser(
        admin: admin,
        role: _roleOf(body),
        username: _text(body, 'username'),
        firstName: _text(body, 'firstName'),
        lastName: _text(body, 'lastName'),
        email: _text(body, 'email'),
        password: _text(body, 'password'),
        scopeIds: scopeIds,
      );
      switch (result) {
        case UserCreated(:final user):
          await _json(request, 201, {'user': _managedUserJson(user)});
        case CreateUserRefused(:final problem):
          throw _createUserError(problem, body);
      }
    } on UserManagementForbidden {
      throw const _ApiError(403, 'forbidden', 'Admins only.');
    }
  }

  /// `role` of a new user: `receptionist` unless `admin` is asked for.
  Role _roleOf(Map<String, Object?> body) {
    final raw = body['role'];
    if (raw == null) return Role.receptionist;
    final role = raw is String ? Role.values.asNameMap()[raw] : null;
    if (role == null) {
      throw const _ApiError(400, 'invalid_request', 'Invalid "role".');
    }
    return role;
  }

  _ApiError _createUserError(
    CreateUserProblem problem,
    Map<String, Object?> body,
  ) {
    return switch (problem) {
      CreateUserProblem.usernameTaken => const _ApiError(
        409,
        'username_taken',
        'Another account uses this username.',
      ),
      CreateUserProblem.emailTaken => const _ApiError(
        409,
        'email_taken',
        'Another account uses this email.',
      ),
      CreateUserProblem.scopeInvalid => const _ApiError(
        400,
        'scope_invalid',
        'One or more scopes are not valid.',
      ),
      CreateUserProblem.credentialsInvalid => _ApiError(
        400,
        _credentialCode(
          username: _text(body, 'username'),
          email: _text(body, 'email'),
          password: _text(body, 'password'),
        ),
        'The registration details were not accepted.',
      ),
    };
  }

  String _credentialCode({
    required String username,
    required String email,
    required String password,
  }) {
    if (AccessPolicy.checkEmail(email) != null) return 'email_invalid';
    return switch (AccessPolicy.check(username: username, password: password)) {
      CredentialProblem.usernameInvalid => 'username_invalid',
      CredentialProblem.passwordTooShort => 'password_too_short',
      CredentialProblem.passwordTooLong => 'password_too_long',
      CredentialProblem.passwordContainsUsername =>
        'password_contains_username',
      _ => 'invalid_request',
    };
  }

  Future<void> _setUserPassword(HttpRequest request, String userId) async {
    final admin = await _signedInAdmin(request);
    final body = await _readJson(request);
    final password = _text(body, 'password');
    try {
      final service = await _userService();
      final result = await service.setUserPassword(
        admin: admin,
        userId: userId,
        password: password,
      );
      switch (result) {
        case UserPasswordSet():
          request.response.statusCode = 204;
          await request.response.close();
        case SetUserPasswordRefused(:final problem):
          var username = 'user';
          if (problem == SetUserPasswordProblem.credentialsInvalid) {
            username = await service.usernameOf(userId) ?? username;
          }
          throw _setUserPasswordError(
            problem,
            username: username,
            password: password,
          );
      }
    } on UserManagementForbidden {
      throw const _ApiError(403, 'forbidden', 'Admins only.');
    }
  }

  _ApiError _setUserPasswordError(
    SetUserPasswordProblem problem, {
    required String username,
    required String password,
  }) {
    return switch (problem) {
      SetUserPasswordProblem.notFound => const _ApiError(
        404,
        'not_found',
        'Not found.',
      ),
      SetUserPasswordProblem.forbidden => const _ApiError(
        403,
        'password_change_forbidden',
        'You may not change this person\'s password.',
      ),
      SetUserPasswordProblem.credentialsInvalid => _ApiError(
        400,
        _passwordOnlyCode(username: username, password: password),
        'The password was not accepted.',
      ),
    };
  }

  String _passwordOnlyCode({
    required String username,
    required String password,
  }) {
    return switch (AccessPolicy.check(username: username, password: password)) {
      CredentialProblem.passwordTooShort => 'password_too_short',
      CredentialProblem.passwordTooLong => 'password_too_long',
      CredentialProblem.passwordContainsUsername =>
        'password_contains_username',
      _ => 'invalid_request',
    };
  }

  Future<void> _updateUser(HttpRequest request, String userId) async {
    final admin = await _signedInAdmin(request);
    final body = await _readJson(request);
    final scopeIds = body.containsKey('scopeIds')
        ? _stringList(body, 'scopeIds')
        : null;
    final statusRaw = body['status'];
    final status = statusRaw is String ? statusRaw : null;
    if (statusRaw != null && status == null) {
      throw const _ApiError(
        400,
        'invalid_request',
        'Missing or invalid "status".',
      );
    }
    try {
      final result = await (await _userService()).updateUser(
        admin: admin,
        userId: userId,
        firstName: _text(body, 'firstName'),
        lastName: _text(body, 'lastName', required: false),
        email: _text(body, 'email'),
        phone: _text(body, 'phone', required: false),
        status: status,
        scopeIds: scopeIds,
      );
      switch (result) {
        case UserUpdated(:final user):
          await _json(request, 200, {'user': _managedUserJson(user)});
        case UpdateUserRefused(:final problem):
          if (problem == UpdateUserProblem.profileInvalid) {
            throw _updateProfileError(body);
          }
          throw _updateUserError(problem);
      }
    } on UserManagementForbidden {
      throw const _ApiError(403, 'forbidden', 'Admins only.');
    }
  }

  _ApiError _updateUserError(UpdateUserProblem problem) => switch (problem) {
    UpdateUserProblem.notFound => const _ApiError(
      404,
      'not_found',
      'Not found.',
    ),
    UpdateUserProblem.cannotDisableSelf => const _ApiError(
      409,
      'cannot_disable_self',
      'You cannot disable your own account.',
    ),
    UpdateUserProblem.lastAdmin => const _ApiError(
      409,
      'last_admin',
      'The last active admin cannot be disabled.',
    ),
    UpdateUserProblem.cannotDisableInitialAdmin => const _ApiError(
      409,
      'cannot_disable_initial_admin',
      'The first administrator cannot be disabled.',
    ),
    UpdateUserProblem.emailTaken => const _ApiError(
      409,
      'email_taken',
      'Another account uses this email.',
    ),
    UpdateUserProblem.scopeInvalid => const _ApiError(
      400,
      'scope_invalid',
      'One or more scopes are not valid.',
    ),
    UpdateUserProblem.statusInvalid => const _ApiError(
      400,
      'invalid_request',
      'Missing or invalid "status".',
    ),
    UpdateUserProblem.profileInvalid => const _ApiError(
      400,
      'invalid_request',
      'The profile was not accepted.',
    ),
  };

  _ApiError _updateProfileError(Map<String, Object?> body) {
    final problem = AccessPolicy.checkProfile(
      firstName: _text(body, 'firstName'),
      lastName: _text(body, 'lastName', required: false),
      email: _text(body, 'email'),
      phone: _text(body, 'phone', required: false),
    );
    return _ApiError(400, switch (problem) {
      ProfileProblem.firstNameMissing => 'first_name_missing',
      ProfileProblem.nameTooLong => 'name_too_long',
      ProfileProblem.emailInvalid => 'email_invalid',
      _ => 'phone_invalid',
    }, 'The profile was not accepted.');
  }

  Map<String, Object?> _usersContextJson(UsersContext context) => {
    'licenseType': context.licenseType?.name,
    'assignmentTarget': context.assignmentTarget.name,
    'targets': [
      for (final target in context.targets)
        {'id': target.id, 'name': target.name},
    ],
    'onboarding': {'needsAttention': context.onboarding.needsAttention},
    'firstAdminId': context.firstAdminId,
  };

  Map<String, Object?> _managedUserJson(ManagedUser user) => {
    ..._accountJson(user.account),
    'status': user.status,
    'scopeIds': user.scopeIds,
    'createdAt': user.account.createdAt.toUtc().toIso8601String(),
  };

  Future<void> _setupStatus(HttpRequest request) async {
    final registered = await (await _access()).hasAdmin;
    await _json(request, 200, {
      'adminRegistered': registered,
      // Registration needs the code shown on the tablet.
      'claimCodeRequired': !registered,
    });
  }

  Future<void> _verifyClaim(HttpRequest request) async {
    final body = await _readJson(request);
    final result = await (await _access()).verifyClaimCode(
      _text(body, 'claimCode'),
    );
    switch (result) {
      case ClaimVerified():
        await _json(request, 200, {'valid': true});
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
    }
  }

  Future<void> _registerAdmin(HttpRequest request) async {
    final body = await _readJson(request);
    final result = await (await _access()).registerAdmin(
      claimCode: _text(body, 'claimCode'),
      username: _text(body, 'username'),
      firstName: _text(body, 'firstName'),
      lastName: _text(body, 'lastName'),
      email: _text(body, 'email'),
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
          CredentialProblem.emailInvalid => 'email_invalid',
          CredentialProblem.passwordTooShort => 'password_too_short',
          CredentialProblem.passwordTooLong => 'password_too_long',
          CredentialProblem.passwordContainsUsername =>
            'password_contains_username',
        }, 'The registration details were not accepted.');
    }
  }

  Future<void> _login(HttpRequest request) async {
    final body = await _readJson(request);
    final result = await (await _access()).login(
      username: _text(body, 'username'),
      password: _text(body, 'password'),
      clientKey: request.connectionInfo?.remoteAddress.address ?? 'unknown',
      remember: body['remember'] == true,
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

  Future<void> _startReset(HttpRequest request) async {
    final body = await _readJson(request);
    final result = await (await _access()).startReset(
      username: _text(body, 'username'),
      activationKey: _text(body, 'activationKey'),
      clientKey: request.connectionInfo?.remoteAddress.address ?? 'unknown',
    );
    switch (result) {
      case ResetTicketIssued(:final ticket, :final expiresAt):
        await _json(request, 200, {
          'resetToken': ticket,
          'expiresAt': expiresAt.toUtc().toIso8601String(),
        });
      case ResetRefused():
        throw const _ApiError(
          403,
          'reset_refused',
          'The activation key or the username was not accepted.',
        );
      case ResetThrottled(:final retryAfter):
        throw _tooManyAttempts(retryAfter);
    }
  }

  Future<void> _finishReset(HttpRequest request) async {
    final body = await _readJson(request);
    final result = await (await _access()).finishReset(
      ticket: _text(body, 'resetToken'),
      newPassword: _text(body, 'newPassword'),
      clientKey: request.connectionInfo?.remoteAddress.address ?? 'unknown',
    );
    switch (result) {
      case PasswordWasReset():
        request.response.statusCode = HttpStatus.noContent;
        await request.response.close();
      case ResetTicketInvalid():
        throw const _ApiError(
          403,
          'reset_token_invalid',
          'This reset has expired. Start again.',
        );
      case ResetCredentialsRefused(:final problem):
        throw _ApiError(400, switch (problem) {
          CredentialProblem.passwordTooShort => 'password_too_short',
          CredentialProblem.passwordTooLong => 'password_too_long',
          CredentialProblem.passwordContainsUsername =>
            'password_contains_username',
          CredentialProblem.usernameInvalid => 'invalid_request',
          CredentialProblem.emailInvalid => 'invalid_request',
        }, 'The new password was not accepted.');
      case ResetThrottled(:final retryAfter):
        throw _tooManyAttempts(retryAfter);
    }
  }

  _ApiError _tooManyAttempts(Duration retryAfter) => _ApiError(
    429,
    'too_many_attempts',
    'Too many attempts. Try again later.',
    headers: {'retry-after': '${retryAfter.inSeconds + 1}'},
  );

  Future<void> _pinLogin(HttpRequest request) async {
    final body = await _readJson(request);
    final result = await (await _access()).loginWithPin(
      deviceToken: _text(body, 'deviceToken'),
      pin: _text(body, 'pin'),
      clientKey: request.connectionInfo?.remoteAddress.address ?? 'unknown',
    );
    switch (result) {
      case PinLoggedIn(:final session):
        await _json(request, 200, {
          'token': session.token,
          'expiresAt': session.expiresAt.toUtc().toIso8601String(),
          'account': _accountJson(session.account),
        });
      case PinWrong(:final attemptsLeft):
        throw _ApiError(
          401,
          'invalid_pin',
          'That PIN is not correct.',
          extra: {'attemptsLeft': attemptsLeft},
        );
      case PinLocked():
        throw const _ApiError(
          403,
          'pin_locked',
          'Too many wrong PINs. Sign in with your password.',
        );
      case PinUnavailable():
        throw const _ApiError(
          401,
          'pin_unavailable',
          'PIN sign-in is not available here. Use your password.',
        );
      case PinLoginThrottled(:final retryAfter):
        throw _tooManyAttempts(retryAfter);
    }
  }

  Map<String, Object?> _pinDeviceJson(PinDeviceInfo device) => {
    'id': device.id,
    'label': device.label,
    'createdAt': device.createdAt.toUtc().toIso8601String(),
    'lastUsedAt': device.lastUsedAt?.toUtc().toIso8601String(),
  };

  Future<void> _listPins(HttpRequest request) async {
    final account = await _signedIn(request);
    final devices = await (await _access()).pinDevices(account);
    await _json(request, 200, {
      'devices': [for (final device in devices) _pinDeviceJson(device)],
    });
  }

  Future<void> _setPin(HttpRequest request) async {
    final account = await _signedIn(request);
    final body = await _readJson(request);
    final replace = body['replaceDeviceId'];
    final result = await (await _access()).setPin(
      account: account,
      password: _text(body, 'password'),
      pin: _text(body, 'pin'),
      label: _text(body, 'label', required: false),
      replaceDeviceId: replace is String ? replace : null,
    );
    switch (result) {
      case PinSet(:final deviceToken, :final device):
        await _json(request, 201, {
          'deviceToken': deviceToken,
          'device': _pinDeviceJson(device),
        });
      case PinPasswordWrong():
        throw const _ApiError(
          403,
          'current_password_wrong',
          'The password is not correct.',
        );
      case PinRefused(:final problem):
        throw switch (problem) {
          PinProblem.format => const _ApiError(
            400,
            'pin_invalid',
            'A PIN is exactly 6 digits.',
          ),
          PinProblem.weak => const _ApiError(
            400,
            'pin_too_easy',
            'Choose a PIN that is harder to guess.',
          ),
        };
      case PinSetThrottled(:final retryAfter):
        throw _tooManyAttempts(retryAfter);
    }
  }

  Future<void> _removePin(HttpRequest request, String deviceId) async {
    final account = await _signedIn(request);
    final removed = await (await _access()).removePinDevice(account, deviceId);
    if (!removed) throw const _ApiError(404, 'not_found', 'Not found.');
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
  }

  Future<void> _logout(HttpRequest request) async {
    final token = _bearer(request);
    if (token != null) await (await _access()).logout(token);
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
  }

  Future<Account> _signedIn(HttpRequest request) async {
    final token = _bearer(request);
    final account = token == null
        ? null
        : await (await _access()).authenticate(token);
    if (account == null) {
      throw const _ApiError(401, 'unauthorized', 'Sign in first.');
    }
    return account;
  }

  Future<void> _me(HttpRequest request) async {
    final account = await _signedIn(request);
    await _json(request, 200, {'account': _accountJson(account)});
  }

  Future<void> _workScopes(HttpRequest request) async {
    final account = await _signedIn(request);
    if (account.role != Role.receptionist) {
      throw const _ApiError(403, 'forbidden', 'Receptionists only.');
    }
    final factory = _receptionistScope;
    if (factory == null) {
      throw const _ApiError(404, 'not_found', 'Not found.');
    }
    final loaded = await (await factory()).load(account);
    await _json(request, 200, {
      'assignmentTarget': loaded.assignmentTarget.name,
      'assignmentCount': loaded.scopeIds.length,
      'options': [
        for (final option in loaded.options)
          {'id': option.id, 'name': option.name, 'detail': option.detail ?? ''},
      ],
    });
  }

  Future<void> _updateProfile(HttpRequest request) async {
    final account = await _signedIn(request);
    final body = await _readJson(request);
    final result = await (await _access()).updateProfile(
      accountId: account.id,
      firstName: _text(body, 'firstName'),
      lastName: _text(body, 'lastName', required: false),
      email: _text(body, 'email'),
      phone: _text(body, 'phone', required: false),
    );
    switch (result) {
      case ProfileSaved(:final account):
        await _json(request, 200, {'account': _accountJson(account)});
      case ProfileRefused(:final problem):
        throw switch (problem) {
          ProfileProblem.emailTaken => const _ApiError(
            409,
            'email_taken',
            'Another account uses this email.',
          ),
          _ => _ApiError(400, switch (problem) {
            ProfileProblem.firstNameMissing => 'first_name_missing',
            ProfileProblem.nameTooLong => 'name_too_long',
            ProfileProblem.emailInvalid => 'email_invalid',
            _ => 'phone_invalid',
          }, 'The profile was not accepted.'),
        };
    }
  }

  Future<void> _changePassword(HttpRequest request) async {
    final account = await _signedIn(request);
    final body = await _readJson(request);
    final result = await (await _access()).changePassword(
      account: account,
      token: _bearer(request)!,
      currentPassword: _text(body, 'currentPassword'),
      newPassword: _text(body, 'newPassword'),
    );
    switch (result) {
      case PasswordChanged():
        request.response.statusCode = HttpStatus.noContent;
        await request.response.close();
      case CurrentPasswordWrong():
        throw const _ApiError(
          403,
          'current_password_wrong',
          'The current password is not correct.',
        );
      case NewPasswordSame():
        throw const _ApiError(
          400,
          'password_unchanged',
          'Choose a different password.',
        );
      case NewPasswordRefused(:final problem):
        throw _ApiError(400, switch (problem) {
          CredentialProblem.passwordTooShort => 'password_too_short',
          CredentialProblem.passwordTooLong => 'password_too_long',
          CredentialProblem.passwordContainsUsername =>
            'password_contains_username',
          _ => 'invalid_request',
        }, 'The new password was not accepted.');
      case ChangeThrottled(:final retryAfter):
        throw _tooManyAttempts(retryAfter);
    }
  }

  Future<void> _photo(HttpRequest request) async {
    final account = await _signedIn(request);
    final bytes = await (await _access()).photoOf(account.id);
    if (bytes == null) {
      throw const _ApiError(404, 'not_found', 'No photo.');
    }
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.set('content-type', 'image/${AccessPolicy.imageType(bytes)}')
      ..contentLength = bytes.length
      ..add(bytes);
    await request.response.close();
  }

  Future<void> _changePhoto(HttpRequest request) async {
    final account = await _signedIn(request);
    final bytes = await _readBytes(request, AccessPolicy.maxPhotoBytes);
    final result = await (await _access()).changePhoto(
      accountId: account.id,
      bytes: bytes,
    );
    switch (result) {
      case PhotoSaved(:final account):
        await _json(request, 200, {'account': _accountJson(account)});
      case PhotoUnsupported():
        throw const _ApiError(
          415,
          'unsupported_media_type',
          'Send a JPEG, PNG or WebP picture.',
        );
      case PhotoTooLarge():
        throw const _ApiError(413, 'body_too_large', 'The picture is too big.');
    }
  }

  Future<void> _removePhoto(HttpRequest request) async {
    final account = await _signedIn(request);
    final updated = await (await _access()).removePhoto(account.id);
    await _json(request, 200, {'account': _accountJson(updated)});
  }

  /// Anything outside `/api/`: the web app's pages and files, read-only.
  Future<void> _page(HttpRequest request) async {
    final response = request.response;
    final isRead = request.method == 'GET' || request.method == 'HEAD';
    if (!isRead) {
      return _fail(response, 405, 'method_not_allowed', 'Wrong method.');
    }
    final asset = await _web?.find(request.uri.path);
    if (asset == null) {
      if (_web == null && request.uri.path == '/') return _plainHome(request);
      return _fail(response, 404, 'not_found', 'Not found.');
    }
    response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.parse(asset.contentType)
      ..contentLength = asset.bytes.length;
    asset.headers.forEach(response.headers.set);
    if (request.method == 'GET') response.add(asset.bytes);
    await response.close();
  }

  /// Shown at `/` when no web app is bundled.
  Future<void> _plainHome(HttpRequest request) async {
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
    'email': account.email,
    'role': account.role.name,
    'firstName': account.firstName,
    'lastName': account.lastName,
    'phone': account.phone,
    // 0 when there is no photo; changes whenever the photo does.
    'photoVersion': account.photoVersion,
  };

  String? _bearer(HttpRequest request) {
    final header = request.headers.value(HttpHeaders.authorizationHeader);
    if (header == null || !header.startsWith('Bearer ')) return null;
    final token = header.substring(7).trim();
    return token.isEmpty ? null : token;
  }

  /// The raw request body, refused above [limit] bytes.
  Future<List<int>> _readBytes(HttpRequest request, int limit) async {
    if (request.contentLength > limit) {
      throw const _ApiError(413, 'body_too_large', 'Request body too large.');
    }
    final bytes = <int>[];
    await for (final chunk in request.timeout(const Duration(seconds: 20))) {
      bytes.addAll(chunk);
      if (bytes.length > limit) {
        throw const _ApiError(413, 'body_too_large', 'Request body too large.');
      }
    }
    return bytes;
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

  List<String> _stringList(
    Map<String, Object?> body,
    String key, {
    bool required = true,
  }) {
    final value = body[key];
    if (value == null && !required) return const [];
    if (value is! List) {
      throw _ApiError(400, 'invalid_request', 'Missing or invalid "$key".');
    }
    final out = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw _ApiError(400, 'invalid_request', 'Missing or invalid "$key".');
      }
      out.add(item);
    }
    return out;
  }

  void _addCommonHeaders(HttpRequest request) {
    final headers = request.response.headers
      ..set('cache-control', 'no-store')
      ..set('x-content-type-options', 'nosniff');
    // Browsers on the laptop call the API from the web app's address, so
    // cross-origin headers are needed when the SPA is not same-origin (Vite dev).
    // Release reflects Origin; debug allows any origin for local development.
    // Safe here: authentication uses bearer tokens, never cookies.
    final origin = request.headers.value('origin');
    if (origin == null) return;

    const shared = (
      allowHeaders: 'authorization, content-type',
      allowMethods: 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
      maxAge: '600',
    );

    final privateNetworkPreflight =
        request.headers.value('access-control-request-private-network') == 'true';
    final allowOrigin = accessControlAllowOrigin(
      policy: _corsPolicy,
      origin: origin,
      privateNetworkPreflight: privateNetworkPreflight,
    );

    headers
      ..set('access-control-allow-origin', allowOrigin)
      ..set('access-control-allow-headers', shared.allowHeaders)
      ..set('access-control-allow-methods', shared.allowMethods)
      ..set('access-control-max-age', shared.maxAge);
    if (allowOrigin != '*') {
      headers.set('vary', 'Origin');
    }
    if (privateNetworkPreflight || _corsPolicy == CorsPolicy.allowAnyOrigin) {
      headers.set('access-control-allow-private-network', 'true');
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

  String _internalErrorMessage(Object error) {
    if (kDebugMode) {
      return error.toString();
    }
    return 'Server error.';
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
