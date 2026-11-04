// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:convert';

/// The waiting-room TV on the other end of a live socket. It is not tied to
/// a chamber: it shows whatever the tablet's chambers publish.
final class TvClientInfo {
  const TvClientInfo({
    required this.deviceId,
    required this.chamberId,
    required this.name,
  });

  /// The one kind of TV there is.
  static const waitingRoom = TvClientInfo(
    deviceId: 'tv',
    chamberId: anyChamber,
    name: 'TV',
  );

  /// Stands for every chamber.
  static const anyChamber = '*';

  final String deviceId;
  final String chamberId;
  final String name;

  bool matches(Object? chamber) =>
      chamberId == TvClientInfo.anyChamber || chamberId == chamber;
}

/// A TV of a chamber that is connected right now.
final class TvPresence {
  const TvPresence({
    required this.deviceId,
    required this.name,
    required this.connectedAt,
    required this.lastHeardAt,
  });

  final String deviceId;
  final String name;
  final DateTime connectedAt;
  final DateTime lastHeardAt;
}

enum TvAudioResult {
  played,
  failed,

  /// The test did not ask for sound.
  skipped;

  static TvAudioResult parse(Object? value) => switch (value) {
    'played' => played,
    'failed' => failed,
    _ => skipped,
  };
}

/// What a TV reports after a `tv.test` command: whether it put the test
/// screen up and whether it played the sound.
final class TvTestAck {
  const TvTestAck({
    required this.testId,
    required this.chamberId,
    required this.displayShown,
    required this.audio,
    this.error,
  });

  final String testId;
  final String chamberId;
  final bool displayShown;
  final TvAudioResult audio;
  final String? error;
}

/// Broadcasts live events to the connected WebSocket clients: staff browsers
/// and the paired waiting-room TVs.
///
/// Every connection numbers its own events (1, 2, 3 ...), so a TV that is only
/// sent the events of its own chamber still sees no gaps. A TV counts as
/// connected only while it keeps answering heartbeats; a TV that lost power
/// would otherwise look connected until the OS closed its socket.
class LiveEventBus {
  LiveEventBus({
    this.heartbeatEvery = const Duration(seconds: 30),
    Future<Map<String, Object?>> Function()? snapshotPayload,
    DateTime Function() clock = DateTime.now,
  }) : _snapshotPayload = snapshotPayload,
       _clock = clock;

  final Duration heartbeatEvery;
  final Future<Map<String, Object?>> Function()? _snapshotPayload;
  final DateTime Function() _clock;

  /// How many heartbeats a TV may miss before it counts as gone.
  static const _missedHeartbeats = 2.5;

  int _published = 0;
  final _clients = <_Client>[];
  Timer? _heartbeat;
  final _tvChanges = StreamController<String>.broadcast();
  final _testAcks = StreamController<TvTestAck>.broadcast();

  /// Fires with the chamber id whenever its TV connects or leaves.
  Stream<String> get tvChanges => _tvChanges.stream;

  /// What connected TVs report after a test command.
  Stream<TvTestAck> get testAcks => _testAcks.stream;

  /// How many events were published (heartbeats do not count).
  int get eventSequence => _published;

  /// How many clients hold the live channel right now (browsers and TVs).
  int get clientCount => _clients.length;

  /// How many of them are paired TVs.
  int get tvClientCount => _clients.where((c) => c.tv != null).length;

  /// The TV of [chamberId], or null when none is connected.
  TvPresence? tvPresence(String chamberId) {
    final client = _clients
        .where((c) => c.tv?.matches(chamberId) ?? false)
        .firstOrNull;
    final tv = client?.tv;
    if (client == null || tv == null) return null;
    return TvPresence(
      deviceId: tv.deviceId,
      name: tv.name,
      connectedAt: client.connectedAt,
      lastHeardAt: client.lastHeardAt,
    );
  }

  /// Attaches [socket] and sends hello + snapshot. Caller must have
  /// authenticated; pass [tv] when the client is a paired TV.
  void attach(String socketId, WebSocketLike socket, {TvClientInfo? tv}) {
    final now = _clock();
    final client = _Client(socketId, socket, tv, now);
    _clients.add(client);
    if (tv != null) _tvChanged(tv.chamberId);
    _heartbeat ??= Timer.periodic(heartbeatEvery, (_) => _pingAll());
    _sendJson(client, {
      'type': 'hello',
      'eventSequence': 0,
      'serverTime': now.toUtc().toIso8601String(),
    });
    unawaited(_sendSnapshot(client));
  }

  void detach(WebSocketLike socket) {
    final gone = _clients.where((c) => c.socket == socket).toList();
    if (gone.isEmpty) return;
    _clients.removeWhere((c) => c.socket == socket);
    for (final client in gone) {
      final tv = client.tv;
      if (tv != null) _tvChanged(tv.chamberId);
    }
    if (_clients.isEmpty) {
      _heartbeat?.cancel();
      _heartbeat = null;
    }
  }

  /// Sends an event to every client. A TV only gets the events of its own
  /// chamber.
  void publish(String name, Map<String, Object?> payload) {
    _published++;
    final chamberId = payload['chamberId'];
    for (final client in List<_Client>.from(_clients)) {
      final tv = client.tv;
      if (tv != null && !tv.matches(chamberId)) continue;
      _sendEvent(client, name, payload);
    }
  }

  /// Sends a command to the TV of [chamberId] only. Returns how many TVs it
  /// went to (0 when none is connected).
  int sendToTv(String chamberId, String name, Map<String, Object?> payload) {
    var sent = 0;
    for (final client in List<_Client>.from(_clients)) {
      if (!(client.tv?.matches(chamberId) ?? false)) continue;
      _sendEvent(client, name, payload);
      sent++;
    }
    return sent;
  }

  void handleClientMessage(WebSocketLike socket, String data) {
    final client = _clients.where((c) => c.socket == socket).firstOrNull;
    if (client == null) return;
    Object? decoded;
    try {
      decoded = jsonDecode(data);
    } on FormatException {
      return;
    }
    if (decoded is! Map<String, Object?>) return;
    client.lastHeardAt = _clock();
    if (decoded['type'] != 'ack' || decoded['name'] != 'tv.test') return;
    final tv = client.tv;
    final testId = decoded['testId'];
    if (tv == null || testId is! String) return;
    final error = decoded['error'];
    _testAcks.add(
      TvTestAck(
        testId: testId,
        chamberId: tv.chamberId,
        displayShown: decoded['display'] == 'shown',
        audio: TvAudioResult.parse(decoded['audio']),
        error: error is String ? error : null,
      ),
    );
  }

  void _tvChanged(String chamberId) {
    if (!_tvChanges.isClosed) _tvChanges.add(chamberId);
  }

  Future<void> _sendSnapshot(_Client client) async {
    Map<String, Object?> payload;
    try {
      payload = _snapshotPayload != null
          ? await _snapshotPayload()
          : const {'live': true};
    } on Object {
      payload = const {'live': true, 'snapshotError': true};
    }
    final tv = client.tv;
    final displays = payload['displays'];
    if (tv != null &&
        tv.chamberId != TvClientInfo.anyChamber &&
        displays is List) {
      payload = {
        ...payload,
        'displays': [
          for (final d in displays)
            if (d is Map && d['chamberId'] == tv.chamberId) d,
        ],
      };
    }
    _sendJson(client, {
      'type': 'snapshot',
      'eventSequence': client.sequence,
      'payload': payload,
    });
  }

  void _pingAll() {
    final now = _clock();
    final patience = heartbeatEvery * _missedHeartbeats;
    for (final client in List<_Client>.from(_clients)) {
      if (client.tv != null && now.difference(client.lastHeardAt) > patience) {
        detach(client.socket);
      }
    }
    for (final client in List<_Client>.from(_clients)) {
      // A heartbeat carries the current number but does not use one up.
      _sendJson(client, {'type': 'ping', 'eventSequence': client.sequence});
    }
  }

  void _sendEvent(_Client client, String name, Map<String, Object?> payload) {
    _sendJson(client, {
      'type': 'event',
      'eventSequence': ++client.sequence,
      'name': name,
      'payload': payload,
    });
  }

  void _sendJson(_Client client, Map<String, Object?> body) {
    try {
      client.socket.send(jsonEncode(body));
    } on Object {
      detach(client.socket);
    }
  }
}

final class _Client {
  _Client(this.id, this.socket, this.tv, DateTime now)
    : connectedAt = now,
      lastHeardAt = now;

  final String id;
  final WebSocketLike socket;
  final TvClientInfo? tv;
  final DateTime connectedAt;
  DateTime lastHeardAt;

  /// The number of the last event sent on this connection.
  int sequence = 0;
}

/// Minimal surface so tests can fake a socket without `dart:io` WebSocket.
abstract interface class WebSocketLike {
  void send(String data);
}
