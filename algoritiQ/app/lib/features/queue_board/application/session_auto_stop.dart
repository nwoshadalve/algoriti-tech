// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'queue_board_service_provider.dart';

/// How often the tablet checks whether a session reached its stop time.
const sessionAutoStopCheckEvery = Duration(seconds: 30);

/// Ends sessions at their automatic stop time ([queue-configuration.md]).
/// Watched once by the app, so it runs for as long as the app does: once at
/// start, which also catches a stop time passed while the app was off, then
/// every [sessionAutoStopCheckEvery].
final sessionAutoStopProvider = Provider<void>((ref) {
  final service = ref.watch(queueBoardServiceProvider);

  Future<void> check() async {
    try {
      await service.closeSessionsDueForAutoStop();
    } on Object {
      // The next check tries again; a failure must never stop the timer.
    }
  }

  unawaited(check());
  final timer = Timer.periodic(
    sessionAutoStopCheckEvery,
    (_) => unawaited(check()),
  );
  ref.onDispose(timer.cancel);
});
