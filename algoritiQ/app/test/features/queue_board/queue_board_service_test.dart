// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:algoritiq_app/features/access/application/access_service.dart';
import 'package:algoritiq_app/features/access/data/drift_account_repository.dart';
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/queue/application/queue_service.dart';
import 'package:algoritiq_app/features/queue/data/drift_queue_repository.dart';
import 'package:algoritiq_app/features/queue_board/application/queue_board_service.dart';
import 'package:algoritiq_app/features/queue_board/data/drift_queue_board_repository.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

import '../../support/access_kit.dart';
import '../../support/licensing_kit.dart';

void main() {
  test('should load queue board snapshot for a chamber', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final kit = await AccessKit.create();
    addTearDown(kit.close);
    await seedDoctor(kit.database);
    const chamberId = '902abfb3-fcb0-47ca-9315-b37b2e15b955';
    await kit.database
        .into(kit.database.chambers)
        .insertOnConflictUpdate(
          ChambersCompanion.insert(
            id: chamberId,
            doctorId: 'seed-doctor',
            name: 'Room 1',
            createdAt: DateTime.utc(2026).millisecondsSinceEpoch,
          ),
        );

    await kit.registerAdmin();
    final login = await kit.service.login(
      username: 'owner',
      password: AccessKit.password,
      clientKey: 'test',
    );
    final account = switch (login) {
      LoggedIn(:final account) => account,
      _ => throw StateError('login failed'),
    };

    final accounts = DriftAccountRepository(kit.database);
    final queueRepo = DriftQueueRepository(kit.database);
    final queueService = QueueService(
      repository: queueRepo,
      accounts: accounts,
      clock: kit.clock.call,
      newId: () => 'id-${DateTime.now().microsecondsSinceEpoch}',
    );
    final boardRepo = DriftQueueBoardRepository(kit.database, queueRepo);
    final clinic = DriftClinicRepository(kit.database, kit.clock.call);
    final board = QueueBoardService(
      boardRepo: boardRepo,
      queueService: queueService,
      clinic: clinic,
      accounts: accounts,
      clock: kit.clock.call,
      newId: () => 'id-${DateTime.now().microsecondsSinceEpoch}',
    );

    final snapshot = await board.loadBoard(account, chamberId);
    expect(snapshot.chamberId, chamberId);
    expect(snapshot.sessionOpen, isFalse);
  });
}
