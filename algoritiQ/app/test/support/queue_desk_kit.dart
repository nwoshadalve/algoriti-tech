// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:algoritiq_app/features/access/application/access_service.dart';
import 'package:algoritiq_app/features/access/data/drift_account_repository.dart';
import 'package:algoritiq_app/features/access/domain/account.dart';
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/queue/application/queue_service.dart';
import 'package:algoritiq_app/features/queue/data/drift_queue_repository.dart';
import 'package:algoritiq_app/features/queue_board/application/queue_board_service.dart';
import 'package:algoritiq_app/features/queue_board/data/drift_queue_board_repository.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

import 'access_kit.dart';
import 'licensing_kit.dart';

const deskChamberId = '902abfb3-fcb0-47ca-9315-b37b2e15b955';

/// An admin at the desk of one chamber, on an in-memory database.
class QueueDeskKit {
  QueueDeskKit(
    this.kit,
    this.account,
    this.board,
    this.queueRepo,
    this.boardRepo,
  );

  final AccessKit kit;
  final Account account;
  final QueueBoardService board;
  final DriftQueueRepository queueRepo;
  final DriftQueueBoardRepository boardRepo;

  static Future<QueueDeskKit> open() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final kit = await AccessKit.create();
    addTearDown(kit.close);
    await seedDoctor(kit.database);
    await kit.database
        .into(kit.database.chambers)
        .insertOnConflictUpdate(
          ChambersCompanion.insert(
            id: deskChamberId,
            doctorId: 'seed-doctor',
            name: 'Room 1',
            patientIdPrefix: '776',
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
    var counter = 0;
    String newId() => 'id-${counter++}';
    final accounts = DriftAccountRepository(kit.database);
    final queueRepo = DriftQueueRepository(kit.database);
    final boardRepo = DriftQueueBoardRepository(kit.database, queueRepo);
    final board = QueueBoardService(
      boardRepo: boardRepo,
      queueService: QueueService(
        repository: queueRepo,
        accounts: accounts,
        clock: kit.clock.call,
        newId: newId,
      ),
      clinic: DriftClinicRepository(kit.database, kit.clock.call),
      accounts: accounts,
      clock: kit.clock.call,
      newId: newId,
    );
    // The first board load seeds the clinic's default queue types.
    await board.loadBoard(account, deskChamberId);
    return QueueDeskKit(kit, account, board, queueRepo, boardRepo);
  }

  Future<IssuedTokenResult> addPatient(
    String bengaliName,
    String phone, {
    String? englishName,
    String queue = 'regular',
    String command = 'cmd',
  }) => board.registerAndIssue(
    account,
    PatientInput(
      bengaliName: bengaliName,
      englishName: englishName,
      phone: phone,
    ),
    queue,
    chamberId: deskChamberId,
    commandId: command,
  );

  Future<List<String>> searchNames(String query) async => [
    for (final p in await board.searchPatients(account, query)) p.bengaliName,
  ];
}
