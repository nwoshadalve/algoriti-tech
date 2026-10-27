import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/id_generator.dart';
import '../../../core/security/secure_storage_secret_store.dart';
import '../data/argon2id_password_hasher.dart';
import '../data/drift_account_repository.dart';
import '../domain/account_repository.dart';
import '../domain/password_hasher.dart';
import 'access_service.dart';
import 'claim_codes.dart';
import 'login_throttle.dart';

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

final accessServiceProvider = FutureProvider<AccessService>((ref) async {
  return AccessService(
    repository: ref.watch(accountRepositoryProvider),
    hasher: await ref.watch(passwordHasherProvider.future),
    claimCodes: ref.watch(claimCodesProvider),
    throttle: ref.watch(loginThrottleProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  );
});

/// How many admins exist. Zero means the tablet is waiting for the first one.
final adminCountProvider = StreamProvider<int>(
  (ref) => ref.watch(accountRepositoryProvider).watchAdminCount(),
);
