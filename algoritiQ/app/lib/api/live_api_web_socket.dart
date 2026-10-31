// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:io';

import '../features/access/application/access_service.dart';
import 'live_event_bus.dart';

/// Upgrades `/api/v1/ws/live` and attaches authenticated clients to [LiveEventBus].
final class LiveApiWebSocket {
  LiveApiWebSocket({
    required this.bus,
    required Future<AccessService> Function() access,
  }) : _access = access;

  static const path = '/api/v1/ws/live';

  final LiveEventBus bus;
  final Future<AccessService> Function() _access;

  Future<void> handle(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }
    final token = _tokenFrom(request);
    if (token == null) {
      await _reject(request, HttpStatus.unauthorized);
      return;
    }
    final account = await (await _access()).authenticate(token);
    if (account == null) {
      await _reject(request, HttpStatus.unauthorized);
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    final adapter = IoWebSocketAdapter(socket);
    final id = '${account.id}-${DateTime.now().microsecondsSinceEpoch}';
    bus.attach(id, adapter);
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
