// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/api/live_event_bus.dart';
import 'package:algoritiq_app/api/tv_live_publisher_impl.dart';
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/tv_live/application/tv_live_publisher.dart';
import 'package:algoritiq_app/features/tv_live/application/tv_live_snapshot_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';
import '../../support/tv_board.dart';

/// What the waiting-room board shows after each desk action, built the way the
/// tablet builds it for the TV and the cast screen.
void main() {
  late LiveEventBus bus;
  late List<LiveBusEvent> events;
  late QueueDeskKit desk;

  setUp(() async {
    bus = LiveEventBus();
    events = [];
    bus.events.listen(events.add);
    // The desk is opened first so its database can feed the snapshot service;
    // the publisher is wired in through a late-bound proxy.
    desk = await QueueDeskKit.open(tvLive: _LateTv(() => _publisher));
    _publisher = TvLivePublisherImpl(
      bus: bus,
      snapshots: TvLiveSnapshotService(
        clinic: DriftClinicRepository(desk.kit.database, desk.kit.clock.call),
        board: desk.boardRepo,
      ),
    );
  });

  TvBoard lastBoard() {
    final display = events.last.payload['display']! as Map;
    return TvBoard.fromDisplay(Map<String, Object?>.from(display));
  }

  test(
    'should show a patient on the board as soon as they are added',
    () async {
      await desk.board.startSession(desk.account, deskChamberId);
      await Future<void>.delayed(Duration.zero);
      final before = events.length;

      final issued = await desk.addPatient('করিম', '01711000111');
      await Future<void>.delayed(Duration.zero);

      expect(events.length, greaterThan(before));
      final regular = lastBoard().queues.first;
      expect(regular.waiting, [issued.token.serial]);
    },
  );

  test('should drop the called patient from the waiting list', () async {
    await desk.board.startSession(desk.account, deskChamberId);
    final first = await desk.addPatient('করিম', '01711000111');
    final second = await desk.addPatient(
      'রহিম',
      '01711000222',
      command: 'cmd2',
    );

    await desk.board.callNext(desk.account, deskChamberId, 'regular');
    await Future<void>.delayed(Duration.zero);

    final board = lastBoard();
    expect(board.calledSerial, first.token.serial);
    expect(board.queues.first.waiting, [second.token.serial]);
  });

  test('should show the next patient once the first one entered', () async {
    await desk.board.startSession(desk.account, deskChamberId);
    final first = await desk.addPatient('করিম', '01711000111');
    final second = await desk.addPatient(
      'রহিম',
      '01711000222',
      command: 'cmd2',
    );
    await desk.board.callNext(desk.account, deskChamberId, 'regular');

    // The queue calls the second patient by itself.
    await desk.board.markEntered(desk.account, first.token.id);
    await Future<void>.delayed(Duration.zero);

    final board = lastBoard();
    expect(board.calledSerial, second.token.serial);
    expect(board.queues.first.waiting, isEmpty);
  });
}

TvLivePublisherImpl? _publisher;

/// Hands every call to the publisher once it exists.
final class _LateTv implements TvLivePublisher {
  _LateTv(this._get);

  final TvLivePublisherImpl? Function() _get;

  @override
  Future<Map<String, Object?>> buildLiveSnapshot() async => const {};

  @override
  Future<void> notifyQueueUpdated(String chamberId) async =>
      _get()?.notifyQueueUpdated(chamberId);

  @override
  Future<void> notifyTokenCalled({
    required String chamberId,
    required String tokenId,
    required String queueTypeId,
    required int serial,
    required String callId,
    String? announcementUrl,
  }) async => _get()?.notifyTokenCalled(
    chamberId: chamberId,
    tokenId: tokenId,
    queueTypeId: queueTypeId,
    serial: serial,
    callId: callId,
    announcementUrl: announcementUrl,
  );
}
