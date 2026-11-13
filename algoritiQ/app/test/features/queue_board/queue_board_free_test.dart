// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/queue_board/domain/session_history_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

/// A patient can be seen free: the token has no fee and the session history
/// counts such patients.
void main() {
  late QueueDeskKit desk;
  late String sessionId;

  setUp(() async {
    desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
    sessionId = (await desk.boardRepo.openSessionForChamber(deskChamberId))!.id;
  });

  Future<int> freeCount() async => (await desk.board.sessionDetail(
    desk.account,
    sessionId,
  )).summary.freeCount;

  test('should register a new patient as free with no fee kept', () async {
    final issued = await desk.board.registerAndIssue(
      desk.account,
      const PatientInput(name: 'করিম', phone: '01711000111'),
      'regular',
      chamberId: deskChamberId,
      commandId: 'c1',
      feeBdt: 500,
      isFree: true,
    );

    final row = (await desk.boardRepo.tokenById(issued.token.id))!;
    expect(row.isFree, isTrue);
    expect(row.feeBdt, isNull);
    expect(issued.token.isFree, isTrue);
  });

  test('should issue an existing patient a free token', () async {
    final first = await desk.addPatient('রহিম', '01711000222');
    // A patient holds one active token at a time.
    await desk.board.cancelToken(desk.account, first.token.id, 'test');

    final again = await desk.board.issueToken(
      desk.account,
      deskChamberId,
      first.token.patientId,
      'regular',
      isFree: true,
      commandId: 'c2',
    );

    expect((await desk.boardRepo.tokenById(again.token.id))!.isFree, isTrue);
  });

  test('should keep a paid patient not free', () async {
    final issued = await desk.addPatient('করিম', '01711000111');

    expect((await desk.boardRepo.tokenById(issued.token.id))!.isFree, isFalse);
    expect(await freeCount(), 0);
  });

  test('should count free patients and leave cancelled ones out', () async {
    for (final (i, phone) in ['01711000001', '01711000002'].indexed) {
      await desk.board.registerAndIssue(
        desk.account,
        PatientInput(name: 'ফ্রি $i', phone: phone),
        'regular',
        chamberId: deskChamberId,
        commandId: 'free$i',
        isFree: true,
      );
    }
    final cancelled = await desk.board.registerAndIssue(
      desk.account,
      const PatientInput(name: 'বাতিল', phone: '01711000003'),
      'regular',
      chamberId: deskChamberId,
      commandId: 'free-cancelled',
      isFree: true,
    );
    await desk.addPatient('পেইড', '01711000004', command: 'paid');
    await desk.board.cancelToken(desk.account, cancelled.token.id, 'test');

    expect(await freeCount(), 2);
    final page = await desk.board.listSessions(
      desk.account,
      const SessionHistoryQuery(),
    );
    expect(page.items.single.freeCount, 2);
  });

  test('should make a token free when editing and drop its fee', () async {
    final issued = await desk.addPatient('করিম', '01711000111');
    const input = PatientInput(name: 'করিম', phone: '01711000111');
    await desk.board.updatePatient(
      desk.account,
      issued.token.patientId,
      input,
      fee: TokenFeeChange(tokenId: issued.token.id, feeBdt: 500),
    );

    await desk.board.updatePatient(
      desk.account,
      issued.token.patientId,
      input,
      fee: TokenFeeChange(tokenId: issued.token.id, feeBdt: 500, isFree: true),
    );

    var row = (await desk.boardRepo.tokenById(issued.token.id))!;
    expect(row.isFree, isTrue);
    expect(row.feeBdt, isNull);

    // And back to a paid visit.
    await desk.board.updatePatient(
      desk.account,
      issued.token.patientId,
      input,
      fee: TokenFeeChange(tokenId: issued.token.id, feeBdt: 300),
    );
    row = (await desk.boardRepo.tokenById(issued.token.id))!;
    expect(row.isFree, isFalse);
    expect(row.feeBdt, 300);
  });
}
