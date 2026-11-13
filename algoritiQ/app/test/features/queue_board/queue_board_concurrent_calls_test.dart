// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/application/queue_board_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

/// One called token per queue: three queues can have a patient called at once.
void main() {
  late QueueDeskKit desk;

  setUp(() async {
    desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
    await desk.addPatient('করিম', '01711000111');
    await desk.addPatient(
      'রহিম',
      '01711000222',
      queue: 'report',
      command: 'cmd2',
    );
    await desk.addPatient(
      'সালমা',
      '01711000333',
      queue: 'dressing',
      command: 'cmd3',
    );
    await desk.addPatient('জামাল', '01711000444', command: 'cmd4');
  });

  Future<void> call(String queue) =>
      desk.board.callNext(desk.account, deskChamberId, queue);

  test('should call one token from each queue at the same time', () async {
    await call('regular');
    await call('report');
    await call('dressing');

    final board = await desk.board.loadBoard(desk.account, deskChamberId);

    expect(board.calledTokens.map((t) => t.queueTypeId), [
      'regular',
      'report',
      'dressing',
    ]);
  });

  test('should refuse a second call in a queue that is already calling', () {
    return call('regular').then(
      (_) => expectLater(
        call('regular'),
        throwsA(
          isA<QueueBoardRefused>().having(
            (e) => e.problem,
            'problem',
            QueueBoardProblem.unresolvedCalledToken,
          ),
        ),
      ),
    );
  });

  test('should block Call next only in the queue that is calling', () async {
    await call('regular');

    final board = await desk.board.loadBoard(desk.account, deskChamberId);
    final controls = {for (final c in board.queueControls) c.queueTypeId: c};

    expect(controls['regular']!.canCallNext, isFalse);
    expect(controls['regular']!.canRecall, isTrue);
    expect(controls['report']!.canCallNext, isTrue);
    expect(controls['report']!.canRecall, isFalse);
  });

  test(
    'should move a queue on to its next patient once its patient entered',
    () async {
      await call('regular');
      await call('report');
      final regular = (await desk.board.loadBoard(
        desk.account,
        deskChamberId,
      )).calledTokens.first;

      await desk.board.markEntered(desk.account, regular.id);

      final board = await desk.board.loadBoard(desk.account, deskChamberId);
      expect(board.calledTokens, hasLength(2));
      expect(
        board.calledTokens.firstWhere((t) => t.queueTypeId == 'regular').serial,
        isNot(regular.serial),
      );
    },
  );

  test('should recall the token of the queue that is asked', () async {
    await call('regular');
    await call('report');

    await desk.board.recall(desk.account, deskChamberId, 'report');
  });
}
