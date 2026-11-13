// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:ui';

import 'package:algoritiq_app/features/queue_board/domain/patient_query.dart';
import 'package:algoritiq_app/features/queue_board/domain/token_query.dart';
import 'package:algoritiq_app/features/queue_board/presentation/queue_desk_format.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

/// A patient ID is shown in Bengali digits when the app is in Bengali, and a
/// receptionist can type it in Bengali digits to find the patient.
void main() {
  group('showing the patient ID', () {
    test('should write the digits in Bengali for a Bengali app', () {
      expect(queueDeskFormatDigits('7761', const Locale('bn')), '৭৭৬১');
      expect(queueDeskFormatDigits('P-000001', const Locale('bn')), 'P-০০০০০১');
    });

    test('should leave the ID as it is for an English app', () {
      expect(queueDeskFormatDigits('7761', const Locale('en')), '7761');
      expect(queueDeskFormatDigits('P-000001', const Locale('en')), 'P-000001');
    });
  });

  group('searching with the ID typed in Bengali digits', () {
    late QueueDeskKit desk;
    late String id;
    late String bengaliId;

    setUp(() async {
      desk = await QueueDeskKit.open();
      await desk.board.startSession(desk.account, deskChamberId);
      final issued = await desk.addPatient('করিম', '01711000111');
      await desk.addPatient('রহিম', '01711000222', command: 'c2');
      id = issued.token.clinicPatientId;
      bengaliId = queueDeskFormatDigits(id, const Locale('bn'));
    });

    test('should have an ID with digits to type', () {
      expect(id, matches(RegExp(r'\d')));
      expect(bengaliId, isNot(id));
    });

    test('should find the patient when adding an existing one', () async {
      expect(await desk.searchNames(bengaliId), ['করিম']);
    });

    test('should find the patient in the session table', () async {
      final page = await desk.board.searchSessionTokens(
        desk.account,
        deskChamberId,
        TokenQuery(search: bengaliId),
      );

      expect([for (final t in page.items) t.patientName], ['করিম']);
    });

    test('should find the patient in the patient list', () async {
      final page = await desk.board.listPatients(
        desk.account,
        PatientQuery(search: bengaliId),
      );

      expect([for (final p in page.items) p.name], ['করিম']);
    });

    test(
      'should find the same patient with the ID typed in English digits',
      () async {
        expect(await desk.searchNames(id), ['করিম']);
      },
    );
  });
}
