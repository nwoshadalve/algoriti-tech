// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/id_generator.dart';
import '../../../core/security/secure_storage_secret_store.dart';
import '../../clinic/application/clinic_providers.dart';
import '../../licensing/application/license_controller.dart';
import '../../licensing/domain/license_core.dart';
import '../data/argon2id_password_hasher.dart';
import '../data/drift_account_repository.dart';
import '../data/pin_client_store.dart';
import '../data/remembered_session_store.dart';
import '../data/sign_in_preference_store.dart';
import '../domain/account_repository.dart';
import '../domain/password_hasher.dart';
import 'access_service.dart';
import 'claim_codes.dart';
import 'login_throttle.dart';
import 'user_management_service.dart';

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => DriftAccountRepository(ref.watch(appDatabaseProvider)),
);

final passwordHasherProvider = FutureProvider<PasswordHasher>(
  (ref) => Argon2idPasswordHasher.create(ref.watch(secretStoreProvider)),
);

/// The code shown on the tablet for registering the first admin.
final claimCodesProvider = Provider<ClaimCodes>(
  (ref) => ClaimCodes(clock: ref.watch(clockProvider)),
);

final loginThrottleProvider = Provider<LoginThrottle>(
  (ref) => LoginThrottle(clock: ref.watch(clockProvider)),
);

final pinClientStoreProvider = Provider<PinClientStore>(
  (ref) => const PinClientStore(),
);

final signInPreferenceStoreProvider = Provider<SignInPreferenceStore>(
  (ref) => const SignInPreferenceStore(),
);

final rememberedSessionStoreProvider = Provider<RememberedSessionStore>(
  (ref) => const RememberedSessionStore(),
);

final accessServiceProvider = FutureProvider<AccessService>((ref) async {
  return AccessService(
    repository: ref.watch(accountRepositoryProvider),
    hasher: await ref.watch(passwordHasherProvider.future),
    claimCodes: ref.watch(claimCodesProvider),
    throttle: ref.watch(loginThrottleProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
    licenseKey: () => ref.read(licenseStoreProvider).read(),
  );
});

/// How many admins exist. Zero means the tablet is waiting for the first one.
final adminCountProvider = StreamProvider<int>(
  (ref) => ref.watch(accountRepositoryProvider).watchAdminCount(),
);

/// The tablet's valid, unexpired license, or null.
Future<LicensePayload?> readLicensePayload(Ref ref) async {
  final stored = await ref.read(licenseStoreProvider).read();
  if (stored == null) return null;
  final device = await DeviceCode.fromAndroidId(
    await ref.read(deviceIdSourceProvider).androidId(),
  );
  final check = await ref
      .read(licenseVerifierProvider)
      .verify(stored, device: device, now: ref.read(clockProvider)());
  return switch (check) {
    LicenseValid(:final payload, :final status)
        when status != LicenseStatus.expired =>
      payload,
    _ => null,
  };
}

final userManagementServiceProvider = FutureProvider<UserManagementService>((
  ref,
) async {
  return UserManagementService(
    repository: ref.watch(accountRepositoryProvider),
    clinic: ref.watch(clinicRepositoryProvider),
    hasher: await ref.watch(passwordHasherProvider.future),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
    licensePayload: () => readLicensePayload(ref),
  );
});
