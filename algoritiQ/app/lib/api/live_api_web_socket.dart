// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:io';

import '../features/access/application/access_service.dart';
import '../features/access/domain/account.dart';
import 'live_event_bus.dart';

/// Upgrades `/api/v1/ws/live` and attaches authenticated clients to [LiveEventBus].
///
/// Staff browsers sign in with their session token (header or query, since a
/// browser cannot set headers on a WebSocket). The waiting-room TV uses
/// [tvPath] with no sign-in: it only receives what the TV screen shows, over
/// the tablet's self-signed TLS.
final class LiveApiWebSocket {
  LiveApiWebSocket({
    required this.bus,
    required Future<AccessService> Function() access,
  }) : _access = access;

  static const path = '/api/v1/ws/live';

  /// The waiting-room TV's channel.
  static const tvPath = '/api/v1/ws/tv';

  final LiveEventBus bus;
  final Future<AccessService> Function() _access;

  Future<void> handle(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }
    final isTv = request.uri.path == tvPath;
    Account? account;
    if (!isTv) {
      final token = _tokenFrom(request);
      account = token == null
          ? null
          : await (await _access()).authenticate(token);
      if (account == null) {
        await _reject(request, HttpStatus.unauthorized);
        return;
      }
    }
    // No compression: the frames are tiny, and the extension header Dart
    // answers with makes OkHttp (the TV client) refuse the connection.
    final socket = await WebSocketTransformer.upgrade(
      request,
      compression: CompressionOptions.compressionOff,
    );
    final adapter = IoWebSocketAdapter(socket);
    final id =
        '${isTv ? 'tv' : account!.id}-${DateTime.now().microsecondsSinceEpoch}';
    bus.attach(id, adapter, tv: isTv ? TvClientInfo.waitingRoom : null);
    socket.listen(
      (data) {
        if (data is String) {
          bus.handleClientMessage(adapter, data);
        }
      },
      onDone: () => bus.detach(adapter),
      onError: (_, _) => bus.detach(adapter),
      cancelOnError: true,
    );
  }

  String? _tokenFrom(HttpRequest request) {
    final query = request.uri.queryParameters['token']?.trim();
    if (query != null && query.isNotEmpty) return query;
    return _bearerOf(request);
  }

  String? _bearerOf(HttpRequest request) {
    final header = request.headers.value(HttpHeaders.authorizationHeader);
    if (header != null && header.startsWith('Bearer ')) {
      final value = header.substring(7).trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  Future<void> _reject(HttpRequest request, int status) async {
    request.response.statusCode = status;
    await request.response.close();
  }
}

/// Adapts [WebSocket] to [WebSocketLike].
final class IoWebSocketAdapter implements WebSocketLike {
  IoWebSocketAdapter(this._inner);
  final WebSocket _inner;

  @override
  void send(String data) => _inner.add(data);
}
