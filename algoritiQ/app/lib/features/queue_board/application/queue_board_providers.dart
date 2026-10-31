// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/id_generator.dart';
import '../../access/application/access_providers.dart';
import '../../clinic/application/clinic_providers.dart';
import '../../queue/application/queue_providers.dart';
import '../application/queue_board_service.dart';
import '../data/drift_queue_board_repository.dart';

final queueBoardRepositoryProvider = Provider<DriftQueueBoardRepository>(
  (ref) => DriftQueueBoardRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(queueRepositoryProvider),
  ),
);

final queueBoardServiceProvider = Provider<QueueBoardService>(
  (ref) => QueueBoardService(
    boardRepo: ref.watch(queueBoardRepositoryProvider),
    queueService: ref.watch(queueServiceProvider),
    clinic: ref.watch(clinicRepositoryProvider),
    accounts: ref.watch(accountRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);
