// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

import 'package:algoritiq_app/features/clinic/domain/chamber.dart';
import 'package:algoritiq_app/features/clinic/domain/doctor.dart';
import 'package:algoritiq_app/features/connectivity/application/test_token_service.dart';
import 'package:algoritiq_app/features/connectivity/domain/printer.dart';
import 'package:algoritiq_app/features/connectivity/domain/token_slip.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/clinic_fake.dart';

void main() {
  final at = DateTime(2026, 10, 30, 12, 14);
  TokenSlip? drawn;
  Uint8List? sent;

  TestTokenService service({
    String? scope = 'c1',
    FakeClinic? clinic,
    PrintOutcome result = PrintOutcome.printed,
  }) => TestTokenService(
    clinic: clinic ?? FakeClinic(),
    scopeId: () => scope,
    now: () => at,
    print: (job) async {
      sent = job;
      return result;
    },
    render: (slip) async {
      drawn = slip;
      return Uint8List.fromList([1, 2, 3]);
    },
  );

  setUp(() {
    drawn = null;
    sent = null;
  });

  test(
    'should print a Regular dummy token with the chamber and doctor',
    () async {
      final outcome = await service().run();

      expect(outcome, TestTokenOutcome.printed);
      expect(drawn!.chamberName, testChamber.name);
      expect(drawn!.doctorName, testDoctor.name);
      expect(drawn!.queueType, QueueType.regular);
      expect(drawn!.tokenNumber, 1);
      expect(drawn!.issuedAt, at);
      expect(sent, [1, 2, 3]);
    },
  );

  test('should use the doctor and first chamber for a doctor scope', () async {
    final outcome = await service(scope: 'd1').run();

    expect(outcome, TestTokenOutcome.printed);
    expect(drawn!.doctorName, testDoctor.name);
    expect(drawn!.chamberName, testChamber.name);
  });

  test('should fall back to the doctor workplace with no chamber', () async {
    const doctor = Doctor(
      id: 'd2',
      name: 'ডাঃ আয়েশা',
      workplace: 'চাঁদপুর সদর',
    );

    await service(
      scope: 'd2',
      clinic: FakeClinic(doctors: const [doctor], chambers: const <Chamber>[]),
    ).run();

    expect(drawn!.chamberName, 'চাঁদপুর সদর');
  });

  test('should not print when no chamber or doctor is chosen', () async {
    expect(await service(scope: null).run(), TestTokenOutcome.noDetails);
    expect(await service(scope: 'nope').run(), TestTokenOutcome.noDetails);
    expect(sent, isNull);
  });

  test('should print from the first doctor when admin has no scope', () async {
    final outcome = await service(scope: null).runForAdmin();

    expect(outcome, TestTokenOutcome.printed);
    expect(drawn!.doctorName, testDoctor.name);
    expect(sent, isNotNull);
  });

  test('should report a printer that failed or is not connected', () async {
    expect(
      await service(result: PrintOutcome.failed).run(),
      TestTokenOutcome.failed,
    );
    expect(
      await service(result: PrintOutcome.notConnected).run(),
      TestTokenOutcome.notConnected,
    );
  });
}
