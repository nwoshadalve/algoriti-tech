// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:algoritiq_app/api/api_host.dart';
import 'package:algoritiq_app/core/clock.dart';
import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:algoritiq_app/core/l10n/locale_controller.dart';
import 'package:algoritiq_app/core/l10n/locale_store.dart';
import 'package:algoritiq_app/core/security/secure_storage_secret_store.dart';
import 'package:algoritiq_app/features/access/application/access_providers.dart';
import 'package:algoritiq_app/features/access/application/tablet_session.dart';
import 'package:algoritiq_app/features/access/application/user_management_service.dart';
import 'package:algoritiq_app/features/access/domain/account.dart';
import 'package:algoritiq_app/features/home/application/receptionist_scope_service.dart';
import 'package:algoritiq_app/features/home/application/receptionist_work.dart';
import 'package:algoritiq_app/features/access/data/argon2id_password_hasher.dart';
import 'package:algoritiq_app/features/clinic_onboarding/application/clinic_onboarding_controller.dart';
import 'package:algoritiq_app/features/readiness/application/readiness_controller.dart';
import 'package:algoritiq_app/features/connectivity/application/printer_controller.dart';
import 'package:algoritiq_app/platform/keep_alive_gateway.dart';
import 'package:algoritiq_app/platform/printer_gateway.dart';
import 'package:algoritiq_app/platform/system_health_gateway.dart';
import 'package:algoritiq_app/features/licensing/application/license_controller.dart';
import 'package:algoritiq_app/features/licensing/domain/license_ports.dart';
import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'printer_fake.dart';

import 'clinic_onboarding_kit.dart';
import 'memory_locale_store.dart';
import 'memory_secret_store.dart';
import 'readiness_kit.dart';
import 'system_health_fake.dart';

import 'test_vendor_key.dart';

final testNow = DateTime.utc(2026, 10, 27, 9);

class FakeDeviceIdSource implements DeviceIdSource {
  FakeDeviceIdSource(this.id);

  final String? id;

  @override
  Future<String> androidId() async => id ?? (throw StateError('no device id'));
}

class MemoryLicenseStore implements LicenseStore {
  MemoryLicenseStore([this.token]);

  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async => this.token = token;
}

/// A throwaway vendor key plus helpers to issue licenses in tests.
class LicensingKit {
  LicensingKit._(this.key, this.deviceId);

  static Future<LicensingKit> create({String deviceId = 'test-device'}) async =>
      LicensingKit._(await TestVendorKey.generate(), deviceId);

  final TestVendorKey key;
  final String deviceId;

  Future<String> issue({
    LicenseType type = LicenseType.doctor,
    int doctors = 1,
    int chambers = 2,
    DateTime? expiresAt,
    String? forDeviceId,
  }) async {
    return key.issue(
      type: type,
      maxDoctors: doctors,
      maxChambers: chambers,
      device: await DeviceCode.fromAndroidId(forDeviceId ?? deviceId),
      issuedAt: testNow,
      expiresAt: expiresAt,
    );
  }

  List<Override> overrides({
    LicenseStore? store,
    bool deviceIdUnavailable = false,

    /// Skip first-time setup, so a licensed device opens straight to home.
    bool setupDone = true,

    /// An admin account exists, so the app is past the admin guide.
    bool adminRegistered = true,

    /// Someone is signed in on the tablet, so screens past sign-in can be
    /// tested. Turn off to test sign-in itself.
    bool signedIn = true,

    /// Stands in for the real HTTPS server (no ports are opened in tests).
    ApiHost? apiHost,

    /// The user already went past the "keep the tablet ready" guide.
    bool readinessAcknowledged = true,

    /// The user already chose start new or restored (skip restore/start screen).
    bool clinicDataChosen = true,

    /// Stands in for Android's settings.
    KeepAliveGateway? keepAlive,

    /// Stands in for Bluetooth and other tablet readings.
    SystemHealthGateway? systemHealth,

    /// Fills the in-memory database before the app reads it.
    Future<void> Function(AppDatabase database)? seed,
    LocaleStore? localeStore,
  }) => [
    deviceIdSourceProvider.overrideWithValue(
      FakeDeviceIdSource(deviceIdUnavailable ? null : deviceId),
    ),
    licenseStoreProvider.overrideWithValue(store ?? MemoryLicenseStore()),
    licenseVerifierProvider.overrideWithValue(
      LicenseVerifier(publicKeys: {key.keyId: key.publicKey}),
    ),
    clockProvider.overrideWithValue(() => testNow),
    localeStoreProvider.overrideWithValue(localeStore ?? MemoryLocaleStore()),
    apiHostProvider.overrideWithValue(apiHost ?? FakeApiHost()),
    if (signedIn) tabletSessionProvider.overrideWith(_SignedInSession.new),
    if (signedIn)
      receptionistWorkProvider.overrideWith(_SignedInWorkScopeReady.new),
    secretStoreProvider.overrideWithValue(MemorySecretStore()),
    keepAliveGatewayProvider.overrideWithValue(
      keepAlive ?? FakeKeepAliveGateway(),
    ),
    systemHealthGatewayProvider.overrideWithValue(
      systemHealth ?? FakeSystemHealth(),
    ),
    // No Bluetooth in a test: a printer with nothing paired.
    printerGatewayProvider.overrideWithValue(FakePrinterGateway()),
    printerStoreProvider.overrideWithValue(MemoryPrinterStore()),
    readinessStoreProvider.overrideWithValue(
      MemoryReadinessStore(acknowledged: readinessAcknowledged),
    ),
    clinicOnboardingStoreProvider.overrideWithValue(
      MemoryClinicOnboardingStore(chosen: clinicDataChosen),
    ),
    // Far cheaper than production, so tests stay fast.
    passwordHasherProvider.overrideWith(
      (ref) => Argon2idPasswordHasher.create(
        MemorySecretStore(),
        memoryKiB: 64,
        passes: 1,
      ),
    ),
    appDatabaseProvider.overrideWith((ref) {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final database = AppDatabase(NativeDatabase.memory());
      ref.onDispose(database.close);
      if (setupDone) unawaited(seedStage(database, 'done'));
      if (adminRegistered) unawaited(seedAdmin(database));
      if (signedIn) unawaited(seedSignedInReceptionist(database));
      if (seed != null) unawaited(seed(database));
      return database;
    }),
  ];
}

/// Saves the setup stage ('profile', 'chambers', 'ready' or 'done').
Future<void> seedStage(AppDatabase database, String stage) async {
  await database
      .into(database.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: 'setup.stage', value: stage),
      );
}

/// A doctor on record, for screens that need one (chambers hang under it).
Future<void> seedDoctor(
  AppDatabase database, {
  String id = 'seed-doctor',
}) async {
  await database
      .into(database.doctors)
      .insert(
        // A complete profile: it can be saved again without filling anything.
        DoctorsCompanion.insert(
          id: id,
          name: 'Seeded doctor',
          designation: const Value('Professor'),
          specialty: const Value('Orthopaedics'),
          degrees: const Value('["MBBS"]'),
        ),
      );
}

/// An admin account, so screens past the admin guide can be tested.
Future<void> seedAdmin(AppDatabase database) async {
  await database
      .into(database.users)
      .insert(
        UsersCompanion.insert(
          id: 'seed-admin',
          username: 'admin',
          displayName: 'Admin',
          email: const Value('admin@clinic.test'),
          role: 'admin',
          passwordHash: 'unused',
          createdAt: testNow.millisecondsSinceEpoch,
        ),
      );
}

/// Desk receptionist with one chamber scope — matches [_SignedInSession].
Future<void> seedSignedInReceptionist(AppDatabase database) async {
  await seedDoctor(database);
  const chamberId = 'seed-chamber';
  await database
      .into(database.chambers)
      .insertOnConflictUpdate(
        ChambersCompanion.insert(
          id: chamberId,
          doctorId: 'seed-doctor',
          name: 'Main chamber',
          createdAt: testNow.millisecondsSinceEpoch,
        ),
      );
  await database
      .into(database.users)
      .insertOnConflictUpdate(
        UsersCompanion.insert(
          id: 'seed-desk',
          username: 'desk',
          displayName: 'Front Desk',
          email: const Value('desk@clinic.test'),
          role: 'receptionist',
          passwordHash: 'unused',
          createdAt: testNow.millisecondsSinceEpoch,
        ),
      );
  await database
      .into(database.userScopeAssignments)
      .insertOnConflictUpdate(
        UserScopeAssignmentsCompanion.insert(
          userId: 'seed-desk',
          scopeId: chamberId,
        ),
      );
}

/// A server stand-in that reports a fixed address, or fails on demand.
class FakeApiHost implements ApiHost {
  FakeApiHost({this.addresses = const ['192.168.0.20'], this.fails = false});

  List<String> addresses;
  bool fails;
  int starts = 0;

  final _names = StreamController<String?>.broadcast();

  /// Pretends the tablet claimed (or lost) its local network name.
  void claimName(String? name) => _names.add(name);

  @override
  Stream<String?> get localNames => _names.stream;

  @override
  Future<ApiEndpoint> start() async {
    starts++;
    if (fails) throw const FormatException('no port');
    return ApiEndpoint(
      port: 8443,
      addresses: addresses,
      fingerprint: 'AB:CD:EF',
    );
  }

  @override
  Future<List<String>> currentAddresses() async => addresses;

  @override
  Future<void> stop() async {}
}

/// A tablet that already has someone signed in.
class _SignedInSession extends TabletSession {
  @override
  TabletSignIn? build() => TabletSignIn(
    Account(
      id: 'seed-desk',
      username: 'desk',
      displayName: 'Front Desk',
      email: 'desk@clinic.test',
      role: Role.receptionist,
      createdAt: testNow,
    ),
    'seed-token',
  );
}

/// Skips the async work-scope load in widget tests; matches [seedSignedInReceptionist].
class _SignedInWorkScopeReady extends ReceptionistWorkController {
  @override
  ReceptionistWorkState? build() {
    final session = ref.read(tabletSessionProvider);
    if (session?.account.role != Role.receptionist) return null;
    return ReceptionistWorkReady(
      const WorkScopeOption(id: 'seed-chamber', name: 'Main chamber'),
    );
  }
}
