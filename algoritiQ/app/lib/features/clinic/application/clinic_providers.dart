// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/id_generator.dart';
import '../../licensing/application/license_controller.dart';
import '../../licensing/domain/license_state.dart';
import '../../access/application/access_providers.dart';
import '../data/app_doctor_photo_files.dart';
import '../data/drift_clinic_repository.dart';
import '../data/image_picker_photo_store.dart';
import '../domain/chamber.dart';
import '../domain/clinic_repository.dart';
import '../domain/doctor.dart';
import '../domain/doctor_photo_files.dart';
import '../domain/photo_store.dart';
import '../domain/setup_stage.dart';
import 'chamber_service.dart';
import 'clinic_actions.dart';
import 'doctor_profile_service.dart';

final clinicRepositoryProvider = Provider<ClinicRepository>(
  (ref) => DriftClinicRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
  ),
);

final photoStoreProvider = Provider<PhotoStore>(
  (ref) => ImagePickerPhotoStore(ref.watch(clockProvider)),
);

final doctorPhotoFilesProvider = Provider<DoctorPhotoFiles>(
  (ref) => AppDoctorPhotoFiles(ref.watch(clockProvider)),
);

/// Editing the doctor from the website.
final doctorProfileServiceProvider = Provider<DoctorProfileService>(
  (ref) => DoctorProfileService(
    clinic: ref.watch(clinicRepositoryProvider),
    photos: ref.watch(doctorPhotoFilesProvider),
    licensePayload: () => readLicensePayload(ref),
  ),
);

/// Keeping the chambers from the website, within the license.
final chamberServiceProvider = Provider<ChamberService>(
  (ref) => ChamberService(
    clinic: ref.watch(clinicRepositoryProvider),
    accounts: ref.watch(accountRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
    licensePayload: () => readLicensePayload(ref),
  ),
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
