// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../queue/application/queue_providers.dart';
import '../data/drift_queue_board_repository.dart';

final queueBoardRepositoryProvider = Provider<DriftQueueBoardRepository>(
  (ref) => DriftQueueBoardRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(queueRepositoryProvider),
  ),
);
