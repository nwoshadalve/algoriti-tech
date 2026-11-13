// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/domain/session_history_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

/// The test clock starts at 2026-10-27 09:00 UTC, 15:00 in Dhaka, so the
/// default stop time (03:00) falls at 21:00 UTC the same day.
void main() {
  late QueueDeskKit desk;

  Future<bool> isOpen() async =>
      await desk.boardRepo.openSessionForChamber(deskChamberId) != null;

  setUp(() async {
    desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
  });

  test('should keep the session open before the automatic stop time', () async {
    desk.kit.clock.advance(const Duration(hours: 11, minutes: 59));

    await desk.board.closeSessionsDueForAutoStop();

    expect(await isOpen(), isTrue);
  });

  test('should close the session once the stop time has passed', () async {
    desk.kit.clock.advance(const Duration(hours: 12));

    await desk.board.closeSessionsDueForAutoStop();

    expect(await isOpen(), isFalse);
  });

  test('should close a session that was left open for days', () async {
    desk.kit.clock.advance(const Duration(days: 3));

    await desk.board.closeSessionsDueForAutoStop();

    expect(await isOpen(), isFalse);
  });

  test('should keep the patients of the session as history', () async {
    await desk.addPatient('Rahim', '01955000444');
    desk.kit.clock.advance(const Duration(hours: 13));

    await desk.board.closeSessionsDueForAutoStop();

    final page = await desk.board.listSessions(
      desk.account,
      const SessionHistoryQuery(),
    );
    // Opened at 15:00 Dhaka: it ended at the 03:00 stop time, not when it was noticed.
    expect(page.items.single.closedAt, DateTime.utc(2026, 10, 27, 21));
    expect(page.items.single.closeReason, isNull);
  });

  test('should allow a new session after the automatic stop', () async {
    desk.kit.clock.advance(const Duration(hours: 13));
    await desk.board.closeSessionsDueForAutoStop();

    await desk.board.startSession(desk.account, deskChamberId);

    expect(await isOpen(), isTrue);
  });
}
