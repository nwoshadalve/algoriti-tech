// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/application/queue_board_service.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/queue_board/domain/session_history_models.dart';
import 'package:algoritiq_app/features/queue_board/domain/token_query.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

void main() {
  /// A closed session with one patient seen, one cancelled and one never
  /// seen, then a second session that is still open.
  Future<QueueDeskKit> deskWithHistory() async {
    final desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
    final first = await desk.addPatient('করিম', '01711000111', command: 'a');
    final second = await desk.addPatient('রহিম', '01711000222', command: 'b');
    await desk.addPatient('সালমা', '01711000333', command: 'c');
    await desk.board.callNext(desk.account, deskChamberId, 'regular');
    await desk.board.markEntered(desk.account, first.token.id);
    await desk.board.cancelToken(desk.account, second.token.id, 'left');
    await desk.board.endSession(desk.account, deskChamberId);
    await desk.board.startSession(desk.account, deskChamberId);
    return desk;
  }

  test('should list sessions newest first with what happened', () async {
    final desk = await deskWithHistory();

    final page = await desk.board.listSessions(
      desk.account,
      const SessionHistoryQuery(),
    );

    expect(page.total, 2);
    final open = page.items.first;
    final ended = page.items.last;
    expect(open.isOpen, isTrue);
    expect(open.issued, 0);
    expect(ended.isOpen, isFalse);
    expect(ended.chamberName, 'Room 1');
    expect(ended.issued, 3);
    expect(ended.count(TokenStatus.entered), 1);
    expect(ended.count(TokenStatus.cancelled), 1);
    // The third patient was called by itself when the second was cancelled,
    // and the session ended before they came in.
    expect(ended.count(TokenStatus.called), 1);
    expect(ended.firstCalledAt, isNotNull);
    expect(ended.closedByName, isNotNull);
  });

  test('should page and filter by date', () async {
    final desk = await deskWithHistory();

    final firstPage = await desk.board.listSessions(
      desk.account,
      const SessionHistoryQuery(limit: 1),
    );
    final later = await desk.board.listSessions(
      desk.account,
      const SessionHistoryQuery(limit: 1, offset: 1),
    );
    final future = await desk.board.listSessions(
      desk.account,
      SessionHistoryQuery(from: DateTime.now().add(const Duration(days: 400))),
    );

    expect(firstPage.items.single.id, isNot(later.items.single.id));
    expect(firstPage.total, 2);
    expect(future.total, 0);
  });

  test('should count a session per queue and list its tokens', () async {
    final desk = await deskWithHistory();
    final page = await desk.board.listSessions(
      desk.account,
      const SessionHistoryQuery(),
    );
    final ended = page.items.last;

    final detail = await desk.board.sessionDetail(desk.account, ended.id);
    final tokens = await desk.board.searchHistoryTokens(
      desk.account,
      ended.id,
      const TokenQuery(sort: TokenSort.serial, ascending: true),
    );

    expect(detail.queues.single.queueTypeId, 'regular');
    expect(detail.queues.single.issued, 3);
    expect(tokens.items.map((t) => t.patientName), ['করিম', 'রহিম', 'সালমা']);
    expect(tokens.items[1].cancelReason, 'left');
    expect(tokens.counts[TokenStatus.entered], 1);
  });

  test('should refuse an unknown session', () async {
    final desk = await deskWithHistory();

    await expectLater(
      desk.board.sessionDetail(desk.account, 'nope'),
      throwsA(isA<QueueBoardRefused>()),
    );
  });
}
