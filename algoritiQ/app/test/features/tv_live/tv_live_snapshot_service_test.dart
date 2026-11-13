// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/tv_live/application/tv_live_snapshot_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

void main() {
  test(
    'should build chamber display with called token and waiting serials',
    () async {
      final desk = await QueueDeskKit.open();
      final snapshots = TvLiveSnapshotService(
        clinic: DriftClinicRepository(desk.kit.database, desk.kit.clock.call),
        board: desk.boardRepo,
      );

      final idle = await snapshots.buildChamberDisplay(deskChamberId);
      expect(idle['sessionOpen'], isFalse);
      expect(idle['called'], isNull);

      await desk.board.startSession(desk.account, deskChamberId);
      final issued = await desk.addPatient(
        'রোগী',
        '01700000001',
        command: 'tv-ws',
      );
      await desk.board.callNext(
        desk.account,
        deskChamberId,
        issued.token.queueTypeId,
      );

      final live = await snapshots.buildChamberDisplay(deskChamberId);
      expect(live['sessionOpen'], isTrue);
      expect(live['called'], isNotNull);
      expect((live['called'] as Map)['serial'], issued.token.serial);
      final waiting = live['waiting'] as Map<String, dynamic>;
      expect(waiting[issued.token.queueTypeId], isEmpty);
    },
  );

  test(
    'should list every call going on, one per queue, newest as called',
    () async {
      final desk = await QueueDeskKit.open();
      await desk.board.startSession(desk.account, deskChamberId);
      final regular = await desk.addPatient(
        'রোগী',
        '01700000001',
        command: 'a',
      );
      final report = await desk.addPatient(
        'রোগী দুই',
        '01700000002',
        queue: 'report',
        command: 'b',
      );
      await desk.board.callNext(desk.account, deskChamberId, 'regular');
      await desk.board.callNext(desk.account, deskChamberId, 'report');
      final snapshots = TvLiveSnapshotService(
        clinic: DriftClinicRepository(desk.kit.database, desk.kit.clock.call),
        board: desk.boardRepo,
      );

      final display = await snapshots.buildChamberDisplay(deskChamberId);

      final list = display['calledList'] as List;
      expect(list.map((c) => (c as Map)['queueTypeId']), ['regular', 'report']);
      expect((list.first as Map)['serial'], regular.token.serial);
      expect((list.last as Map)['serial'], report.token.serial);
      // A TV that knows one call still gets the newest.
      expect(display['called'], isNotNull);
    },
  );

  test('should say how long each waiting serial has waited', () async {
    final desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
    final first = await desk.addPatient(
      'রোগী',
      '01700000001',
      command: 'wait-1',
    );
    final second = await desk.addPatient(
      'রোগী দুই',
      '01700000002',
      command: 'wait-2',
    );
    final snapshots = TvLiveSnapshotService(
      clinic: DriftClinicRepository(desk.kit.database, desk.kit.clock.call),
      board: desk.boardRepo,
      clock: () => first.token.issuedAt.add(const Duration(seconds: 90)),
    );

    final display = await snapshots.buildChamberDisplay(deskChamberId);

    final typeId = first.token.queueTypeId;
    final waiting = (display['waiting'] as Map)[typeId] as List;
    final waited = (display['waitedSeconds'] as Map)[typeId] as List;
    expect(waiting, [first.token.serial, second.token.serial]);
    // Same order as the serials; the later one has waited less.
    expect(waited.length, waiting.length);
    expect(waited.first, 90);
    expect(waited.last, lessThanOrEqualTo(90 as num));
  });
}
