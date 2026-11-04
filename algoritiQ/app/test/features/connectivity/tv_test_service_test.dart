// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:convert';

import 'package:algoritiq_app/api/live_event_bus.dart';
import 'package:algoritiq_app/features/connectivity/application/tv_test_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// A TV that answers every test command the way the test says.
final class _FakeTv implements WebSocketLike {
  _FakeTv(this.bus, {this.display = 'shown', this.audio = 'played'});

  final LiveEventBus bus;
  String? display;
  String audio;
  final commands = <Map<String, Object?>>[];

  @override
  void send(String data) {
    final frame = jsonDecode(data) as Map<String, Object?>;
    if (frame['name'] != 'tv.test') return;
    final payload = frame['payload']! as Map<String, Object?>;
    commands.add(payload);
    if (display == null) return; // a TV that never answers
    scheduleMicrotask(
      () => bus.handleClientMessage(
        this,
        jsonEncode({
          'type': 'ack',
          'name': 'tv.test',
          'testId': payload['testId'],
          'display': display,
          'audio': payload.containsKey('announcementUrl') ? audio : 'skipped',
        }),
      ),
    );
  }
}

void main() {
  late LiveEventBus bus;
  var ids = 0;

  TvTestService service({String? scope = 'c1', String? firstChamber = 'c1'}) =>
      TvTestService(
        bus: bus,
        scopeId: () => scope,
        firstChamberId: () async => firstChamber,
        newTestId: () => 'test-${ids++}',
        replyWithin: const Duration(milliseconds: 200),
      );

  TvClientInfo tvOf(String chamber) =>
      TvClientInfo(deviceId: 'd-$chamber', chamberId: chamber, name: 'TV');

  setUp(() {
    bus = LiveEventBus();
    ids = 0;
  });

  test('should report no TV when none is connected', () async {
    expect(await service().testDisplay(), TvTestOutcome.notConnected);
  });

  test('should not count a staff browser as the TV', () async {
    bus.attach('s', _FakeTv(bus));

    expect(await service().testDisplay(), TvTestOutcome.notConnected);
  });

  test('should report no details when the chamber is not known', () async {
    expect(await service(scope: null).testDisplay(), TvTestOutcome.noDetails);
  });

  test(
    'should confirm the screen test once the TV says it showed it',
    () async {
      final tv = _FakeTv(bus);
      bus.attach('t', tv, tv: tvOf('c1'));

      expect(await service().testDisplay(), TvTestOutcome.shown);
      expect(tv.commands.single.containsKey('announcementUrl'), isFalse);
    },
  );

  test('should ask the TV to fetch the sound for a sound test', () async {
    final tv = _FakeTv(bus);
    bus.attach('t', tv, tv: tvOf('c1'));

    expect(await service().testSound(), TvTestOutcome.played);
    expect(
      tv.commands.single['announcementUrl'],
      '/api/v1/tv/test-announcement',
    );
  });

  test('should say so when the TV could not play the sound', () async {
    bus.attach('t', _FakeTv(bus, audio: 'failed'), tv: tvOf('c1'));

    expect(await service().testSound(), TvTestOutcome.soundFailed);
  });

  test('should not blame the sound for a screen-only test', () async {
    bus.attach('t', _FakeTv(bus, audio: 'failed'), tv: tvOf('c1'));

    expect(await service().testDisplay(), TvTestOutcome.shown);
  });

  test('should report no reply when the TV stays silent', () async {
    bus.attach('t', _FakeTv(bus, display: null), tv: tvOf('c1'));

    expect(await service().testDisplay(), TvTestOutcome.noReply);
  });

  test('should only test the TV of the chosen chamber', () async {
    final mine = _FakeTv(bus);
    final other = _FakeTv(bus);
    bus.attach('t1', mine, tv: tvOf('c1'));
    bus.attach('t2', other, tv: tvOf('c2'));

    await service().testDisplay();

    expect(mine.commands, hasLength(1));
    expect(other.commands, isEmpty);
  });

  test('should use the first chamber for an admin without a scope', () async {
    final tv = _FakeTv(bus);
    bus.attach('t', tv, tv: tvOf('c9'));

    final outcome = await service(
      scope: null,
      firstChamber: 'c9',
    ).testDisplayForAdmin();

    expect(outcome, TvTestOutcome.shown);
  });

  test('should ignore a reply to another test', () async {
    final tv = _FakeTv(bus, display: null);
    bus.attach('t', tv, tv: tvOf('c1'));

    final pending = service().testDisplay();
    await Future<void>.delayed(Duration.zero);
    bus.handleClientMessage(
      tv,
      '{"type":"ack","name":"tv.test","testId":"old","display":"shown"}',
    );

    expect(await pending, TvTestOutcome.noReply);
  });
}
