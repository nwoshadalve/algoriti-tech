import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:algoritiq_app/features/access/application/access_service.dart';
import 'package:algoritiq_app/features/access/application/claim_codes.dart';
import 'package:algoritiq_app/features/access/application/login_throttle.dart';
import 'package:algoritiq_app/features/access/data/argon2id_password_hasher.dart';
import 'package:algoritiq_app/features/access/data/drift_account_repository.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';

import 'memory_secret_store.dart';

/// A fake clock the test can move forward.
class TestClock {
  TestClock([DateTime? start]) : now = start ?? DateTime.utc(2026, 10, 27, 9);

  DateTime now;

  DateTime call() => now;

  void advance(Duration by) => now = now.add(by);
}

/// Accounts wired to an in-memory database with cheap password hashing.
class AccessKit {
  AccessKit._(
    this.database,
    this.repository,
    this.claimCodes,
    this.throttle,
    this.service,
    this.clock,
  );

  static Future<AccessKit> create() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final clock = TestClock();
    final database = AppDatabase(NativeDatabase.memory());
    final repository = DriftAccountRepository(database);
    final claimCodes = ClaimCodes(clock: clock.call);
    final throttle = LoginThrottle(clock: clock.call);
    var ids = 0;
    final service = AccessService(
      repository: repository,
      // Far cheaper than production, so tests stay fast.
      hasher: await Argon2idPasswordHasher.create(
        MemorySecretStore(),
        memoryKiB: 64,
        passes: 1,
      ),
      claimCodes: claimCodes,
      throttle: throttle,
      clock: clock.call,
      newId: () => 'id${ids++}',
    );
    return AccessKit._(
      database,
      repository,
      claimCodes,
      throttle,
      service,
      clock,
    );
  }

  final AppDatabase database;
  final DriftAccountRepository repository;
  final ClaimCodes claimCodes;
  final LoginThrottle throttle;
  final AccessService service;
  final TestClock clock;

  static const password = 'a-long-passphrase';

  /// Registers the first admin with the code currently on screen.
  Future<RegisterResult> registerAdmin({
    String username = 'owner',
    String? claimCode,
    String pass = password,
  }) => service.registerAdmin(
    claimCode: claimCode ?? claimCodes.current().code,
    username: username,
    displayName: 'The Owner',
    password: pass,
  );

  Future<void> close() => database.close();
}
