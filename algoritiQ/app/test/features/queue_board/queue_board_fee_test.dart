// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/application/queue_board_service.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

/// Editing a patient in an open session can also change the fee on their token.
void main() {
  late QueueDeskKit desk;
  late IssuedTokenResult issued;
  late IssuedTokenResult other;

  setUp(() async {
    desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
    issued = await desk.addPatient('করিম', '01711000111');
    other = await desk.addPatient('রহিম', '01711000222', command: 'c2');
  });

  Future<int?> feeOf(String tokenId) async =>
      (await desk.boardRepo.tokenById(tokenId))!.feeBdt;

  PatientInput input({String name = 'করিম'}) =>
      PatientInput(name: name, phone: '01711000111');

  test('should set the fee on the patient\'s token with the edit', () async {
    await desk.board.updatePatient(
      desk.account,
      issued.token.patientId,
      input(name: 'করিম হোসেন'),
      fee: TokenFeeChange(tokenId: issued.token.id, feeBdt: 500),
    );

    expect(await feeOf(issued.token.id), 500);
    // The patient was saved in the same step.
    expect(await desk.searchNames('হোসেন'), ['করিম হোসেন']);
    // Another patient's token is untouched.
    expect(await feeOf(other.token.id), isNull);
  });

  test('should change a fee that was set before', () async {
    await desk.board.updatePatient(
      desk.account,
      issued.token.patientId,
      input(),
      fee: TokenFeeChange(tokenId: issued.token.id, feeBdt: 500),
    );

    await desk.board.updatePatient(
      desk.account,
      issued.token.patientId,
      input(),
      fee: TokenFeeChange(tokenId: issued.token.id, feeBdt: 700),
    );

    expect(await feeOf(issued.token.id), 700);
  });

  test('should clear the fee when it is emptied', () async {
    await desk.board.updatePatient(
      desk.account,
      issued.token.patientId,
      input(),
      fee: TokenFeeChange(tokenId: issued.token.id, feeBdt: 500),
    );

    await desk.board.updatePatient(
      desk.account,
      issued.token.patientId,
      input(),
      fee: TokenFeeChange(tokenId: issued.token.id),
    );

    expect(await feeOf(issued.token.id), isNull);
  });

  test(
    'should leave the fee alone when the edit does not mention it',
    () async {
      await desk.board.updatePatient(
        desk.account,
        issued.token.patientId,
        input(),
        fee: TokenFeeChange(tokenId: issued.token.id, feeBdt: 500),
      );

      await desk.board.updatePatient(
        desk.account,
        issued.token.patientId,
        input(name: 'করিম উদ্দিন'),
      );

      expect(await feeOf(issued.token.id), 500);
    },
  );

  test('should refuse a token that belongs to another patient', () async {
    await expectLater(
      desk.board.updatePatient(
        desk.account,
        issued.token.patientId,
        input(name: 'বদলানো'),
        fee: TokenFeeChange(tokenId: other.token.id, feeBdt: 500),
      ),
      throwsA(
        isA<QueueBoardRefused>().having(
          (e) => e.problem,
          'problem',
          QueueBoardProblem.validation,
        ),
      ),
    );

    // Nothing was saved: not the name, not the fee.
    expect(await desk.searchNames('বদলানো'), isEmpty);
    expect(await feeOf(other.token.id), isNull);
  });

  test('should refuse a fee once the session has ended', () async {
    await desk.board.endSession(desk.account, deskChamberId);

    await expectLater(
      desk.board.updatePatient(
        desk.account,
        issued.token.patientId,
        input(),
        fee: TokenFeeChange(tokenId: issued.token.id, feeBdt: 500),
      ),
      throwsA(
        isA<QueueBoardRefused>().having(
          (e) => e.problem,
          'problem',
          QueueBoardProblem.sessionClosed,
        ),
      ),
    );
    expect(await feeOf(issued.token.id), isNull);
  });

  test('should refuse a fee that cannot be right', () async {
    for (final amount in [-1, QueueBoardService.maxFeeBdt + 1]) {
      await expectLater(
        desk.board.updatePatient(
          desk.account,
          issued.token.patientId,
          input(),
          fee: TokenFeeChange(tokenId: issued.token.id, feeBdt: amount),
        ),
        throwsA(isA<QueueBoardRefused>()),
        reason: '$amount',
      );
    }
    expect(await feeOf(issued.token.id), isNull);
  });

  test('should still edit a patient with no fee given, as before', () async {
    final saved = await desk.board.updatePatient(
      desk.account,
      issued.token.patientId,
      input(name: 'নতুন নাম'),
    );

    expect(saved.name, 'নতুন নাম');
  });
}
