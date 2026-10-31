// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../platform/backup_gateway.dart';
import '../domain/clinic_onboarding_store.dart';
import '../data/prefs_clinic_onboarding_store.dart';

/// SharedPreferences-backed onboarding persistence.
final clinicOnboardingStoreProvider = Provider<ClinicOnboardingStore>(
  (ref) => const PrefsClinicOnboardingStore(),
);

final clinicOnboardingChosenProvider = FutureProvider<bool>(
  (ref) => ref.watch(clinicOnboardingStoreProvider).isChosen(),
);

final clinicOnboardingControllerProvider =
    NotifierProvider<ClinicOnboardingController, AsyncValue<void>>(
      ClinicOnboardingController.new,
    );

/// Start-new vs restore-from-backup actions before the clinic database is live.
class ClinicOnboardingController extends Notifier<AsyncValue<void>> {
  ClinicOnboardingStore get _store => ref.read(clinicOnboardingStoreProvider);
  BackupGateway get _backup => ref.read(backupGatewayProvider);

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> startNew() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _store.markStartNew();
      ref.invalidate(clinicOnboardingChosenProvider);
    });
  }

  /// Picks a backup zip, imports it, restores clinic data, then restarts the app.
  Future<void> restoreFromBackupZip() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    if (picked == null) return;

    final path = picked.path;
    if (path == null || path.isEmpty) {
      throw StateError('Backup file missing.');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final entry = await _backup.importArchiveFile(path);
      await _backup.restore(entry.id);
      await _backup.restartApp();
    });
    if (state.hasError) {
      final error = state;
      state = const AsyncData(null);
      Error.throwWithStackTrace(error.error!, error.stackTrace!);
    }
  }
}
