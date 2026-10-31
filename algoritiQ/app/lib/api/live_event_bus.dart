// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:convert';

/// Broadcasts ordered live events to connected WebSocket clients (web, TV).
///
/// Queue features will call [publish]; today the channel carries hello,
/// snapshot, and heartbeat until queue state exists.
class LiveEventBus {
  LiveEventBus({this.heartbeatEvery = const Duration(seconds: 30)});

  final Duration heartbeatEvery;

  int _sequence = 0;
  final _clients = <_Client>[];
  Timer? _heartbeat;

  int get eventSequence => _sequence;

  /// How many clients hold the live channel right now.
  int get clientCount => _clients.length;

  /// Attaches [socket] and sends hello + snapshot. Caller must have authenticated.
  void attach(String socketId, WebSocketLike socket) {
    _clients.add(_Client(socketId, socket));
    _heartbeat ??= Timer.periodic(heartbeatEvery, (_) => _pingAll());
    _sendJson(socket, _hello());
    _sendJson(socket, _snapshot());
  }

  void detach(WebSocketLike socket) {
    _clients.removeWhere((c) => c.socket == socket);
    if (_clients.isEmpty) {
      _heartbeat?.cancel();
      _heartbeat = null;
    }
  }

  /// Publishes a named event to every connected client.
  void publish(String name, Map<String, Object?> payload) {
    final seq = ++_sequence;
    final frame = jsonEncode({
      'type': 'event',
      'eventSequence': seq,
      'name': name,
      'payload': payload,
    });
    for (final client in List<_Client>.from(_clients)) {
      _sendRaw(client.socket, frame);
    }
  }

  void handleClientMessage(WebSocketLike socket, String data) {
    Map<String, Object?> message;
    try {
      final decoded = jsonDecode(data);
      if (decoded is! Map<String, Object?>) return;
      message = decoded;
    } on FormatException {
      return;
    }
    if (message['type'] == 'pong') return;
  }

  Map<String, Object?> _hello() => {
    'type': 'hello',
    'eventSequence': _sequence,
    'serverTime': DateTime.now().toUtc().toIso8601String(),
  };

  Map<String, Object?> _snapshot() => {
    'type': 'snapshot',
    'eventSequence': _sequence,
    'payload': {
      'live': true,
      // Queue/chamber snapshot fields arrive with the queue API.
    },
  };

  void _pingAll() {
    final seq = ++_sequence;
    final frame = jsonEncode({'type': 'ping', 'eventSequence': seq});
    for (final client in List<_Client>.from(_clients)) {
      _sendRaw(client.socket, frame);
    }
  }

  void _sendJson(WebSocketLike socket, Map<String, Object?> body) {
    _sendRaw(socket, jsonEncode(body));
  }

  void _sendRaw(WebSocketLike socket, String frame) {
    try {
      socket.send(frame);
    } on Object {
      detach(socket);
    }
  }
}

final class _Client {
  _Client(this.id, this.socket);
  final String id;
  final WebSocketLike socket;
}

/// Minimal surface so tests can fake a socket without `dart:io` WebSocket.
abstract interface class WebSocketLike {
  void send(String data);
}
