import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/id_generator.dart';
import '../../licensing/application/license_controller.dart';
import '../../licensing/domain/license_state.dart';
import '../data/drift_clinic_repository.dart';
import '../data/image_picker_photo_store.dart';
import '../domain/chamber.dart';
import '../domain/clinic_repository.dart';
import '../domain/doctor.dart';
import '../domain/photo_store.dart';
import '../domain/setup_stage.dart';
import 'clinic_actions.dart';

final clinicRepositoryProvider = Provider<ClinicRepository>(
  (ref) => DriftClinicRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
  ),
);

final photoStoreProvider = Provider<PhotoStore>(
  (ref) => ImagePickerPhotoStore(ref.watch(clockProvider)),
);

final setupStageProvider = StreamProvider<SetupStage>(
  (ref) => ref.watch(clinicRepositoryProvider).watchStage(),
);

final doctorsProvider = StreamProvider<List<Doctor>>(
  (ref) => ref.watch(clinicRepositoryProvider).watchDoctors(),
);

final chambersProvider = StreamProvider<List<Chamber>>(
  (ref) => ref.watch(clinicRepositoryProvider).watchChambers(),
);

/// How many chambers the license covers (0 until licensed).
final chamberLimitProvider = Provider<int>(
  (ref) => switch (ref.watch(licenseControllerProvider).value) {
    Licensed(:final payload) => payload.maxChambers,
    _ => 0,
  },
);

final clinicActionsProvider = Provider<ClinicActions>(
  (ref) => ClinicActions(
    repository: ref.watch(clinicRepositoryProvider),
    newId: ref.watch(idGeneratorProvider),
    maxChambers: ref.watch(chamberLimitProvider),
  ),
);
