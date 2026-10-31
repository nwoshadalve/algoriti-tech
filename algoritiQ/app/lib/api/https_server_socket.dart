// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// The listening socket of the HTTPS API. It also understands someone who
/// types `algoritiq.local:8443` and whose browser tries plain `http://`: that
/// visit would otherwise fail silently (the port only speaks TLS). Such a
/// visit is answered with a redirect to the same address over `https://`.
///
/// Only connections that start a TLS handshake reach the HTTP server; plain
/// ones are answered here and closed.
final class HttpsServerSocket extends StreamView<Socket>
    implements ServerSocket {
  HttpsServerSocket._(
    this._inner,
    this._context,
    this._sniffTimeout,
    StreamController<Socket> secure,
  ) : _secure = secure,
      super(secure.stream) {
    _inner.listen(
      _onConnection,
      onError: _secure.addError,
      onDone: _secure.close,
    );
  }

  /// Listens on [address]:[port] (`v6Only` off: IPv4 too on an IPv6 address).
  static Future<HttpsServerSocket> bind(
    InternetAddress address,
    int port,
    SecurityContext context, {
    Duration sniffTimeout = const Duration(seconds: 5),
  }) async {
    final inner = await ServerSocket.bind(address, port, v6Only: false);
    return HttpsServerSocket._(
      inner,
      context,
      sniffTimeout,
      StreamController<Socket>(),
    );
  }

  final ServerSocket _inner;
  final SecurityContext _context;
  final Duration _sniffTimeout;
  final StreamController<Socket> _secure;

  /// First byte of a TLS handshake record.
  static const _tlsHandshake = 0x16;

  /// A browser's request line and headers are far smaller than this.
  static const _maxHeadBytes = 4 * 1024;

  @override
  int get port => _inner.port;

  @override
  InternetAddress get address => _inner.address;

  @override
  Future<ServerSocket> close() async {
    await _inner.close();
    if (!_secure.isClosed) await _secure.close();
    return this;
  }

  void _onConnection(Socket socket) {
    final received = BytesBuilder();
    final deadline = Timer(_sniffTimeout, socket.destroy);
    late final StreamSubscription<Uint8List> subscription;
    subscription = socket.listen(
      (data) {
        received.add(data);
        final bytes = received.toBytes();
        if (bytes.isEmpty) return;
        if (bytes.first == _tlsHandshake) {
          deadline.cancel();
          subscription.pause();
          unawaited(_upgrade(socket, bytes));
        } else if (_endOfHead(bytes) || bytes.length >= _maxHeadBytes) {
          deadline.cancel();
          subscription.pause();
          unawaited(_redirect(socket, bytes));
        }
      },
      onError: (Object _) {
        deadline.cancel();
        socket.destroy();
      },
      onDone: () {
        deadline.cancel();
        socket.destroy();
      },
      cancelOnError: true,
    );
  }

  Future<void> _upgrade(Socket socket, Uint8List first) async {
    try {
      final secure = await SecureSocket.secureServer(
        socket,
        _context,
        bufferedData: first,
      );
      if (_secure.isClosed) {
        secure.destroy();
      } else {
        _secure.add(secure);
      }
    } on Object {
      // A failed handshake is the client's problem, not the server's.
      socket.destroy();
    }
  }

  Future<void> _redirect(Socket socket, Uint8List first) async {
    final location = redirectLocation(
      utf8.decode(first, allowMalformed: true),
      port,
    );
    try {
      socket.add(
        utf8.encode(
          location == null
              ? 'HTTP/1.1 400 Bad Request\r\n'
                    'Content-Length: 0\r\nConnection: close\r\n\r\n'
              : 'HTTP/1.1 307 Temporary Redirect\r\n'
                    'Location: $location\r\n'
                    'Content-Length: 0\r\nCache-Control: no-store\r\n'
                    'Connection: close\r\n\r\n',
        ),
      );
      await socket.flush();
    } on Object {
      // The client left; nothing to tell it.
    } finally {
      socket.destroy();
    }
  }

  static bool _endOfHead(Uint8List bytes) {
    for (var i = 3; i < bytes.length; i++) {
      if (bytes[i] == 0x0A &&
          bytes[i - 1] == 0x0D &&
          bytes[i - 2] == 0x0A &&
          bytes[i - 3] == 0x0D) {
        return true;
      }
    }
    return false;
  }

  static final _path = RegExp(r'^/[\x21-\x7E]*$');
  static final _host = RegExp(r'^(\[[0-9A-Fa-f:.]+\]|[A-Za-z0-9.-]+)$');

  /// `https://<the host the visitor used>:<port><path>`, or null when the
  /// request does not name a plausible host. The visitor's own host is used
  /// (never anything else from the request), with this server's port.
  static String? redirectLocation(String head, int port) {
    final lines = head.split('\r\n');
    final request = lines.first.split(' ');
    if (request.length < 3 || !request[2].startsWith('HTTP/')) return null;
    final path = _path.hasMatch(request[1]) ? request[1] : '/';

    String? host;
    for (final line in lines.skip(1)) {
      if (line.toLowerCase().startsWith('host:')) {
        host = line.substring(5).trim();
        break;
      }
    }
    if (host == null || host.isEmpty) return null;
    final name = host.startsWith('[')
        ? host.substring(0, host.indexOf(']') + 1)
        : host.split(':').first;
    if (!_host.hasMatch(name)) return null;
    return 'https://$name:$port$path';
  }
}
