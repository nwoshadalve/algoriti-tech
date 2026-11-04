// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/id_generator.dart';
import '../../access/application/access_providers.dart';
import '../../clinic/application/clinic_providers.dart';
import '../../connectivity/application/printer_controller.dart';
import '../../queue/application/queue_providers.dart';
import '../../../api/live_providers.dart';
import '../application/queue_board_service.dart';
import 'queue_board_repository_provider.dart';
import 'token_print_service.dart';

final queueBoardServiceProvider = Provider<QueueBoardService>(
  (ref) => QueueBoardService(
    boardRepo: ref.watch(queueBoardRepositoryProvider),
    queueService: ref.watch(queueServiceProvider),
    clinic: ref.watch(clinicRepositoryProvider),
    accounts: ref.watch(accountRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
    tvLive: ref.watch(tvLivePublisherProvider),
  ),
);

final tokenPrintServiceProvider = Provider<TokenPrintService>(
  (ref) => TokenPrintService(
    board: ref.watch(queueBoardServiceProvider),
    clinic: ref.watch(clinicRepositoryProvider),
    print: (job) => ref.read(printerControllerProvider.notifier).print(job),
  ),
);
