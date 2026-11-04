// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:typed_data';

import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/connectivity/domain/printer.dart';
import 'package:algoritiq_app/features/connectivity/domain/token_slip.dart';
import 'package:algoritiq_app/features/queue_board/application/queue_board_service.dart';
import 'package:algoritiq_app/features/queue_board/application/token_print_service.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

void main() {
  late QueueDeskKit desk;
  late IssuedTokenResult issued;
  late List<TokenSlip> slips;

  TokenPrintService service(
    Future<PrintOutcome> Function(Uint8List) print, {
    Duration timeout = TokenPrintService.defaultPrintTimeout,
  }) => TokenPrintService(
    board: desk.board,
    clinic: DriftClinicRepository(desk.kit.database, desk.kit.clock.call),
    print: print,
    printTimeout: timeout,
    render: (slip) async {
      slips.add(slip);
      return Uint8List(0);
    },
  );

  Future<BoardTokenView> tokenInTable() async =>
      (await desk.board.loadBoard(desk.account, deskChamberId)).tokens.single;

  setUp(() async {
    slips = [];
    desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
    issued = await desk.addPatient('করিম', '01711000111');
  });

  test(
    'should mark the token printed and put its details on the slip',
    () async {
      final result = await service((_) async => PrintOutcome.printed)
          .printIssued(
            desk.account,
            issued.token,
            deskChamberId,
            issued.printAttemptId,
          );

      expect(result, TokenPrintResult.sent);
      expect((await tokenInTable()).latestPrintStatus, 'SENT');
      final slip = slips.single;
      expect(slip.tokenNumber, issued.token.serial);
      expect(slip.registrationId, issued.token.clinicPatientId);
      expect(slip.queueText, issued.token.queueBengaliName);
      expect(slip.chamberName, 'Room 1');
      expect(slip.isReprint, isFalse);
    },
  );

  test('should keep the token in the queue when the printer is off', () async {
    final result = await service((_) async => PrintOutcome.notConnected)
        .printIssued(
          desk.account,
          issued.token,
          deskChamberId,
          issued.printAttemptId,
        );

    expect(result, TokenPrintResult.notConnected);
    final token = await tokenInTable();
    expect(token.latestPrintStatus, 'FAILED');
    expect(token.status, TokenStatus.waiting);
  });

  test('should keep the token when printing throws', () async {
    final result = await service((_) async => throw StateError('bluetooth'))
        .printIssued(
          desk.account,
          issued.token,
          deskChamberId,
          issued.printAttemptId,
        );

    expect(result, TokenPrintResult.failed);
    expect((await tokenInTable()).latestPrintStatus, 'FAILED');
  });

  test('should call a printer that never answers unknown', () async {
    final result =
        await service(
          (_) => Completer<PrintOutcome>().future,
          timeout: const Duration(milliseconds: 20),
        ).printIssued(
          desk.account,
          issued.token,
          deskChamberId,
          issued.printAttemptId,
        );

    expect(result, TokenPrintResult.unknown);
    expect((await tokenInTable()).latestPrintStatus, 'UNKNOWN');
  });

  test(
    'should print a failed token again and mark only real reprints',
    () async {
      final failing = service((_) async => PrintOutcome.failed);
      await failing.printIssued(
        desk.account,
        issued.token,
        deskChamberId,
        issued.printAttemptId,
      );

      final first = await service(
        (_) async => PrintOutcome.printed,
      ).printAgain(desk.account, issued.token, deskChamberId, isReprint: false);
      final second = await service(
        (_) async => PrintOutcome.printed,
      ).printAgain(desk.account, issued.token, deskChamberId, isReprint: true);

      expect(first, TokenPrintResult.sent);
      expect(second, TokenPrintResult.sent);
      expect(slips.map((s) => s.isReprint), [false, false, true]);
      expect((await tokenInTable()).latestPrintStatus, 'SENT');
    },
  );

  test('should refuse a second print while one is still running', () async {
    // The token was just issued, so its first print is still pending.
    await expectLater(
      service(
        (_) async => PrintOutcome.printed,
      ).printAgain(desk.account, issued.token, deskChamberId, isReprint: false),
      throwsA(
        isA<QueueBoardRefused>().having(
          (e) => e.problem,
          'problem',
          QueueBoardProblem.printerBusy,
        ),
      ),
    );
  });
}
