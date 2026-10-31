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
import '../data/drift_queue_repository.dart';
import 'queue_service.dart';

final queueRepositoryProvider = Provider<DriftQueueRepository>(
  (ref) => DriftQueueRepository(ref.watch(appDatabaseProvider)),
);

final queueServiceProvider = Provider<QueueService>(
  (ref) => QueueService(
    repository: ref.watch(queueRepositoryProvider),
    accounts: ref.watch(accountRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);
