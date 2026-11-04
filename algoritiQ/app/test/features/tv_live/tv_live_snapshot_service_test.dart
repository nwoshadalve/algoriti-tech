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
}
