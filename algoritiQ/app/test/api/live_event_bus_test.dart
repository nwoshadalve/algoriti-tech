// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:convert';

import 'package:algoritiq_app/api/live_event_bus.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeSocket implements WebSocketLike {
  final sent = <String>[];

  @override
  void send(String data) => sent.add(data);
}

void main() {
  test('should send hello and snapshot when a client attaches', () async {
    final bus = LiveEventBus(
      snapshotPayload: () async => {
        'displays': [
          {'chamberId': 'c1', 'sessionOpen': false},
        ],
      },
    );
    final socket = _FakeSocket();

    bus.attach('c1', socket);
    await Future<void>.delayed(Duration.zero);

    expect(socket.sent.length, 2);
    expect(socket.sent[0], contains('"type":"hello"'));
    expect(socket.sent[1], contains('"type":"snapshot"'));
    expect(socket.sent[1], contains('"displays"'));
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

  group('TV clients', () {
    const tv1 = TvClientInfo(deviceId: 'd1', chamberId: 'c1', name: 'Lobby');
    final snapshot = {
      'displays': [
        {'chamberId': 'c1', 'sessionOpen': true},
        {'chamberId': 'c2', 'sessionOpen': false},
      ],
    };

    Map<String, Object?> frame(String line) =>
        jsonDecode(line) as Map<String, Object?>;

    test('should send a TV only the display of its chamber', () async {
      final bus = LiveEventBus(snapshotPayload: () async => snapshot);
      final tv = _FakeSocket();

      bus.attach('t', tv, tv: tv1);
      await Future<void>.delayed(Duration.zero);

      final payload = frame(tv.sent[1])['payload']! as Map;
      final displays = payload['displays']! as List;
      expect(displays, hasLength(1));
      expect((displays.single as Map)['chamberId'], 'c1');
    });

    test('should send a TV only the events of its chamber', () {
      final bus = LiveEventBus();
      final tv = _FakeSocket();
      final staff = _FakeSocket();
      bus.attach('t', tv, tv: tv1);
      bus.attach('s', staff);

      bus.publish('queue.updated', {'chamberId': 'c2'});
      bus.publish('queue.updated', {'chamberId': 'c1'});

      expect(tv.sent.where((l) => l.contains('queue.updated')), hasLength(1));
      expect(
        staff.sent.where((l) => l.contains('queue.updated')),
        hasLength(2),
      );
    });

    test('should number the events of a TV without gaps', () {
      final bus = LiveEventBus();
      final tv = _FakeSocket();
      bus.attach('t', tv, tv: tv1);

      bus.publish('queue.updated', {'chamberId': 'c2'});
      bus.publish('queue.updated', {'chamberId': 'c1'});
      bus.publish('queue.updated', {'chamberId': 'c1'});

      final numbers = [
        for (final line in tv.sent.where((l) => l.contains('queue.updated')))
          frame(line)['eventSequence'],
      ];
      expect(numbers, [1, 2]);
    });

    test('should not use up an event number for a heartbeat', () async {
      final bus = LiveEventBus(
        heartbeatEvery: const Duration(milliseconds: 10),
      );
      final tv = _FakeSocket();
      bus.attach('t', tv, tv: tv1);
      await Future<void>.delayed(const Duration(milliseconds: 25));
      tv.sent.clear();

      bus.publish('queue.updated', {'chamberId': 'c1'});

      expect(frame(tv.sent.single)['eventSequence'], 1);
    });

    test('should know when the TV of a chamber is connected', () {
      final bus = LiveEventBus();
      final tv = _FakeSocket();
      expect(bus.tvPresence('c1'), isNull);

      bus.attach('t', tv, tv: tv1);
      expect(bus.tvPresence('c1')?.name, 'Lobby');
      expect(bus.tvPresence('c2'), isNull);
      expect(bus.tvClientCount, 1);

      bus.detach(tv);
      expect(bus.tvPresence('c1'), isNull);
      expect(bus.tvClientCount, 0);
    });

    test('should not count a staff client as a TV', () {
      final bus = LiveEventBus();

      bus.attach('s', _FakeSocket());

      expect(bus.tvClientCount, 0);
      expect(bus.tvPresence('c1'), isNull);
    });

    test('should announce when a TV connects or leaves', () async {
      final bus = LiveEventBus();
      final changes = <String>[];
      bus.tvChanges.listen(changes.add);
      final tv = _FakeSocket();

      bus.attach('t', tv, tv: tv1);
      bus.detach(tv);
      await Future<void>.delayed(Duration.zero);

      expect(changes, ['c1', 'c1']);
    });

    test('should drop a TV that stops answering heartbeats', () async {
      final bus = LiveEventBus(
        heartbeatEvery: const Duration(milliseconds: 20),
      );
      final silent = _FakeSocket();
      bus.attach('t', silent, tv: tv1);

      await Future<void>.delayed(const Duration(milliseconds: 120));

      expect(bus.tvPresence('c1'), isNull);
    });

    test('should keep a TV that answers heartbeats', () async {
      final bus = LiveEventBus(
        heartbeatEvery: const Duration(milliseconds: 20),
      );
      final tv = _FakeSocket();
      bus.attach('t', tv, tv: tv1);

      for (var i = 0; i < 6; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        bus.handleClientMessage(tv, '{"type":"pong"}');
      }

      expect(bus.tvPresence('c1'), isNotNull);
    });

    test('should send a command only to the TV of that chamber', () {
      final bus = LiveEventBus();
      final mine = _FakeSocket();
      final other = _FakeSocket();
      final staff = _FakeSocket();
      bus.attach('t1', mine, tv: tv1);
      bus.attach(
        't2',
        other,
        tv: const TvClientInfo(deviceId: 'd2', chamberId: 'c2', name: 'Other'),
      );
      bus.attach('s', staff);

      final sent = bus.sendToTv('c1', 'tv.test', {'testId': 'x'});

      expect(sent, 1);
      expect(mine.sent.last, contains('"name":"tv.test"'));
      expect(other.sent.where((l) => l.contains('tv.test')), isEmpty);
      expect(staff.sent.where((l) => l.contains('tv.test')), isEmpty);
    });

    test('should send a command to nobody when no TV is connected', () {
      expect(LiveEventBus().sendToTv('c1', 'tv.test', {}), 0);
    });

    test('should pass on what a TV reports about a test', () async {
      final bus = LiveEventBus();
      final tv = _FakeSocket();
      bus.attach('t', tv, tv: tv1);
      final acks = <TvTestAck>[];
      bus.testAcks.listen(acks.add);

      bus.handleClientMessage(
        tv,
        '{"type":"ack","name":"tv.test","testId":"x","display":"shown",'
        '"audio":"failed","error":"decode"}',
      );
      await Future<void>.delayed(Duration.zero);

      expect(acks.single.testId, 'x');
      expect(acks.single.chamberId, 'c1');
      expect(acks.single.displayShown, isTrue);
      expect(acks.single.audio, TvAudioResult.failed);
    });

    test('should ignore a report from a client that is not a TV', () async {
      final bus = LiveEventBus();
      final staff = _FakeSocket();
      bus.attach('s', staff);
      final acks = <TvTestAck>[];
      bus.testAcks.listen(acks.add);

      bus.handleClientMessage(
        staff,
        '{"type":"ack","name":"tv.test","testId":"x","display":"shown"}',
      );
      await Future<void>.delayed(Duration.zero);

      expect(acks, isEmpty);
    });
  });
}
