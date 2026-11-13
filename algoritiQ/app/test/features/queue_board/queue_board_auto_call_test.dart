// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/tv_live/application/tv_live_publisher.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

/// Remembers the calls the TV was told about.
final class _RecordingTv implements TvLivePublisher {
  final calls = <int>[];

  @override
  Future<Map<String, Object?>> buildLiveSnapshot() async => const {};

  @override
  Future<void> notifyQueueUpdated(String chamberId) async {}

  @override
  Future<void> notifyTokenCalled({
    required String chamberId,
    required String tokenId,
    required String queueTypeId,
    required int serial,
    required String callId,
    String? announcementUrl,
  }) async => calls.add(serial);
}

/// When a called patient is resolved, the queue's next patient comes up on the
/// board by itself, silently. The receptionist announces it with Call.
void main() {
  late QueueDeskKit desk;
  late _RecordingTv tv;
  late List<IssuedTokenResult> regular;
  late IssuedTokenResult report;

  setUp(() async {
    tv = _RecordingTv();
    desk = await QueueDeskKit.open(tvLive: tv);
    await desk.board.startSession(desk.account, deskChamberId);
    regular = [
      await desk.addPatient('করিম', '01711000111'),
      await desk.addPatient('রহিম', '01711000222', command: 'c2'),
      await desk.addPatient('জামাল', '01711000333', command: 'c3'),
    ];
    report = await desk.addPatient(
      'সালমা',
      '01711000444',
      queue: 'report',
      command: 'c4',
    );
    await desk.board.callNext(desk.account, deskChamberId, 'regular');
    await desk.board.callNext(desk.account, deskChamberId, 'report');
    tv.calls.clear();
  });

  Future<Map<String, int>> calledSerials() async {
    final board = await desk.board.loadBoard(desk.account, deskChamberId);
    return {for (final t in board.calledTokens) t.queueTypeId: t.serial};
  }

  Future<BoardTokenView> calledOf(String queue) async {
    final board = await desk.board.loadBoard(desk.account, deskChamberId);
    return board.calledTokens.firstWhere((t) => t.queueTypeId == queue);
  }

  test(
    'should bring the next patient up once one entered, unannounced',
    () async {
      await desk.board.markEntered(desk.account, regular[0].token.id);

      expect(await calledSerials(), {
        'regular': regular[1].token.serial,
        'report': report.token.serial,
      });
      // Nothing was spoken: the receptionist has the first announcement.
      expect(tv.calls, isEmpty);
      expect((await calledOf('regular')).announced, isFalse);
      // The one that was called by hand was announced.
      expect((await calledOf('report')).announced, isTrue);
    },
  );

  test('should announce the token that came up when Call is pressed', () async {
    await desk.board.markEntered(desk.account, regular[0].token.id);

    await desk.board.recall(desk.account, deskChamberId, 'regular');

    expect(tv.calls, [regular[1].token.serial]);
    expect((await calledOf('regular')).announced, isTrue);
  });

  test('should call the next patient once one is marked missed', () async {
    await desk.board.markSkipped(desk.account, regular[0].token.id);

    expect((await calledSerials())['regular'], regular[1].token.serial);
  });

  test(
    'should call the next patient once the called one is cancelled',
    () async {
      await desk.board.cancelToken(desk.account, regular[0].token.id, 'left');

      expect((await calledSerials())['regular'], regular[1].token.serial);
    },
  );

  test('should not call anyone for a patient who was only waiting', () async {
    await desk.board.cancelToken(desk.account, regular[2].token.id, 'left');

    expect((await calledSerials())['regular'], regular[0].token.serial);
    expect(tv.calls, isEmpty);
  });

  test('should only move the queue of the patient who was resolved', () async {
    await desk.board.markEntered(desk.account, regular[0].token.id);

    expect((await calledSerials())['report'], report.token.serial);
  });

  test('should call nobody and not fail when no one is waiting', () async {
    // The report queue has only the one patient.
    await desk.board.markEntered(desk.account, report.token.id);

    expect((await calledSerials()).containsKey('report'), isFalse);
    expect(tv.calls, isEmpty);
  });

  test('should keep going: each resolved patient brings the next', () async {
    await desk.board.markEntered(desk.account, regular[0].token.id);
    await desk.board.markEntered(desk.account, regular[1].token.id);

    expect((await calledSerials())['regular'], regular[2].token.serial);
  });
}
