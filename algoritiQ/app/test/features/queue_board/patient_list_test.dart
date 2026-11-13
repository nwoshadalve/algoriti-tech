// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/queue_board/domain/patient_query.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

void main() {
  Future<QueueDeskKit> deskWithPatients() async {
    final desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
    await desk.board.registerPatient(
      desk.account,
      const PatientInput(
        name: 'করিম',
        phone: '01711000111',
        gender: PatientGender.male,
      ),
      chamberId: deskChamberId,
      commandId: 'a',
    );
    await desk.board.registerPatient(
      desk.account,
      const PatientInput(
        name: 'Ayesha',
        phone: '01711000222',
        gender: PatientGender.female,
        hasPaperFile: true,
      ),
      chamberId: deskChamberId,
      commandId: 'b',
    );
    await desk.board.registerPatient(
      desk.account,
      const PatientInput(name: 'সালমা', phone: '01811000333'),
      chamberId: deskChamberId,
      commandId: 'c',
    );
    return desk;
  }

  Future<List<String>> names(QueueDeskKit desk, PatientQuery query) async => [
    for (final p in (await desk.board.listPatients(desk.account, query)).items)
      p.name,
  ];

  test('should list newest first by default', () async {
    final desk = await deskWithPatients();

    expect(await names(desk, const PatientQuery()), [
      'সালমা',
      'Ayesha',
      'করিম',
    ]);
  });

  test('should search by name and phone', () async {
    final desk = await deskWithPatients();

    expect(await names(desk, const PatientQuery(search: 'করি')), ['করিম']);
    expect(await names(desk, const PatientQuery(search: 'ayesh')), ['Ayesha']);
    expect(await names(desk, const PatientQuery(search: '01811')), ['সালমা']);
  });

  test('should filter by gender and paper file', () async {
    final desk = await deskWithPatients();

    expect(await names(desk, const PatientQuery(gender: PatientGender.male)), [
      'করিম',
    ]);
    expect(await names(desk, const PatientQuery(genderUnset: true)), ['সালমা']);
    expect(await names(desk, const PatientQuery(paperFileOnly: true)), [
      'Ayesha',
    ]);
  });

  test('should sort and page with the total of all matches', () async {
    final desk = await deskWithPatients();

    final page = await desk.board.listPatients(
      desk.account,
      const PatientQuery(
        sort: PatientSort.phone,
        ascending: true,
        limit: 2,
        offset: 1,
      ),
    );

    expect(page.total, 3);
    expect([for (final p in page.items) p.name], ['Ayesha', 'সালমা']);
  });

  test('should report every registered patient whatever the filters', () async {
    final desk = await deskWithPatients();

    final page = await desk.board.listPatients(
      desk.account,
      const PatientQuery(gender: PatientGender.male),
    );

    expect(page.total, 1);
    expect(page.registeredTotal, 3);
  });

  test(
    'should count every token a patient has in a session as a visit',
    () async {
      final desk = await deskWithPatients();
      // Rahim has two tokens, one of them cancelled: both are on a session.
      final first = await desk.addPatient(
        'Rahim',
        '01955000444',
        command: 'v1',
      );
      await desk.board.cancelToken(desk.account, first.token.id, 'mistake');
      await desk.board.issueToken(
        desk.account,
        deskChamberId,
        first.token.patientId,
        'regular',
        commandId: 'v2',
      );

      final seen = await desk.board.listPatients(
        desk.account,
        const PatientQuery(search: 'Rahim'),
      );
      final never = await desk.board.listPatients(
        desk.account,
        const PatientQuery(search: 'Ayesha'),
      );

      expect(seen.items.single.visitCount, 2);
      expect(seen.items.single.lastVisitAt, isNotNull);
      expect(never.items.single.visitCount, 0);
      expect(never.items.single.lastVisitAt, isNull);
    },
  );

  test('should sort by visits and by last visit', () async {
    final desk = await deskWithPatients();
    // Rahim has two tokens, Mina one: Ayesha, Salma and Karim have none.
    final rahim = await desk.addPatient('Rahim', '01955000444', command: 'r1');
    await desk.board.cancelToken(desk.account, rahim.token.id, 'mistake');
    await desk.board.issueToken(
      desk.account,
      deskChamberId,
      rahim.token.patientId,
      'regular',
      commandId: 'r2',
    );
    desk.kit.clock.advance(const Duration(minutes: 5));
    await desk.addPatient('Mina', '01955000555', command: 'm1');

    final byVisits = await names(
      desk,
      const PatientQuery(sort: PatientSort.visits),
    );
    final byLast = await names(
      desk,
      const PatientQuery(sort: PatientSort.lastVisit),
    );

    expect(byVisits.take(2), ['Rahim', 'Mina']);
    expect(byLast.take(2), ['Mina', 'Rahim']);
    final fewestFirst = await names(
      desk,
      const PatientQuery(sort: PatientSort.visits, ascending: true),
    );
    expect(fewestFirst.last, 'Rahim');
  });
}
