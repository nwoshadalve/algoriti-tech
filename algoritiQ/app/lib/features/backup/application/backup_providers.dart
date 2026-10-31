// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../platform/backup_gateway.dart';
import '../../../core/clock.dart';
import 'backup_service.dart';

final backupPreferencesFutureProvider = FutureProvider<BackupPreferences>(
  (ref) => BackupPreferences.open(),
);

final backupServiceProvider = FutureProvider<BackupService>((ref) async {
  final prefs = await ref.watch(backupPreferencesFutureProvider.future);
  return BackupService(
    gateway: ref.watch(backupGatewayProvider),
    prefs: prefs,
    clock: ref.watch(clockProvider),
  );
});
