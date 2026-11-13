// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/domain/session_history_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

void main() {
  late QueueDeskKit desk;

  Future<SessionSummary> onlySession() async {
    final page = await desk.board.listSessions(
      desk.account,
      const SessionHistoryQuery(),
    );
    return page.items.single;
  }

  setUp(() async {
    desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
  });

  Future<String> issue(String name, String phone, int? fee) async {
    final first = await desk.addPatient(name, phone, command: 'c-$phone');
    // The kit issues without a fee; set the fee the way the desk edit does.
    await desk.boardRepo.setTokenFee(first.token.id, fee);
    return first.token.id;
  }

  test(
    'should add up the fees of a session, cancelled tokens left out',
    () async {
      await issue('Rahim', '01955000444', 500);
      final cancelled = await issue('Mina', '01955000555', 300);
      await issue('Salma', '01955000666', null);
      await desk.board.cancelToken(desk.account, cancelled, 'mistake');

      final session = await onlySession();

      expect(session.totalFeeBdt, 500);
    },
  );

  test('should show fees per queue in the session detail', () async {
    await issue('Rahim', '01955000444', 500);
    await issue('Mina', '01955000555', 250);

    final session = await onlySession();
    final detail = await desk.board.sessionDetail(desk.account, session.id);

    expect(detail.summary.totalFeeBdt, 750);
    expect(detail.queues.single.feeBdt, 750);
  });

  test(
    'should count the patients and how long they waited to be called',
    () async {
      await issue('Rahim', '01955000444', null);
      await issue('Mina', '01955000555', null);
      desk.kit.clock.advance(const Duration(minutes: 10));
      await desk.board.callNext(desk.account, deskChamberId, 'regular');

      final session = await onlySession();
      final detail = await desk.board.sessionDetail(desk.account, session.id);

      expect(detail.patientCount, 2);
      expect(detail.averageWaitSeconds, 600);
      expect(detail.longestWaitSeconds, 600);
    },
  );

  test('should have no waits when nobody was called', () async {
    await issue('Rahim', '01955000444', 100);

    final session = await onlySession();
    final detail = await desk.board.sessionDetail(desk.account, session.id);

    expect(detail.averageWaitSeconds, isNull);
    expect(detail.longestWaitSeconds, isNull);
  });
}
