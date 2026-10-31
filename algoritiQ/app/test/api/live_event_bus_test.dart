// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:algoritiq_app/api/live_event_bus.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeSocket implements WebSocketLike {
  final sent = <String>[];

  @override
  void send(String data) => sent.add(data);
}

void main() {
  test('should send hello and snapshot when a client attaches', () {
    final bus = LiveEventBus();
    final socket = _FakeSocket();

    bus.attach('c1', socket);

    expect(socket.sent.length, 2);
    expect(socket.sent[0], contains('"type":"hello"'));
    expect(socket.sent[1], contains('"type":"snapshot"'));
  });

  test('should publish ordered events to every client', () {
    final bus = LiveEventBus();
    final a = _FakeSocket();
    final b = _FakeSocket();
    bus.attach('a', a);
    bus.attach('b', b);

    bus.publish('server.test', {'value': 1});

    expect(a.sent.last, contains('"name":"server.test"'));
    expect(a.sent.last, contains('"eventSequence":'));
    expect(b.sent.last, a.sent.last);
  });

  test('should emit heartbeat pings on a timer', () async {
    final bus = LiveEventBus(heartbeatEvery: const Duration(milliseconds: 20));
    final socket = _FakeSocket();
    bus.attach('c1', socket);

    await Future<void>.delayed(const Duration(milliseconds: 45));

    expect(socket.sent.any((line) => line.contains('"type":"ping"')), isTrue);
  });
}
