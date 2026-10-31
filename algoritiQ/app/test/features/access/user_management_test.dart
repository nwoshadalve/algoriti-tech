// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:algoritiq_app/features/access/application/user_management_service.dart';
import 'package:algoritiq_app/features/access/data/argon2id_password_hasher.dart';
import 'package:algoritiq_app/features/access/data/drift_account_repository.dart';
import 'package:algoritiq_app/features/access/domain/account.dart';
import 'package:algoritiq_app/features/access/domain/user_query.dart';
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/clinic/domain/chamber.dart';
import 'package:algoritiq_app/features/clinic/domain/doctor.dart';

import 'dart:typed_data';

import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

import '../../support/access_kit.dart';
import '../../support/memory_secret_store.dart';

void main() {
  late AppDatabase database;
  late DriftAccountRepository accounts;
  late DriftClinicRepository clinic;
  late UserManagementService service;
  late Account admin;
  var userIds = 0;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final kit = await AccessKit.create();
    database = kit.database;
    accounts = kit.repository;
    clinic = DriftClinicRepository(database, kit.clock);
    service = UserManagementService(
      repository: accounts,
      clinic: clinic,
      hasher: await Argon2idPasswordHasher.create(
        MemorySecretStore(),
        memoryKiB: 64,
        passes: 1,
      ),
      clock: kit.clock,
      newId: () => 'recv-${userIds++}',
      licensePayload: () async => LicensePayload(
        keyId: 1,
        type: LicenseType.doctor,
        maxDoctors: 1,
        maxChambers: 3,
        issuedDay: 1,
        expiresDay: null,
        device: DeviceCode(Uint8List.fromList([0, 1, 2, 3, 4, 5])),
        licenseId: Uint8List.fromList([1, 2, 3, 4]),
      ),
    );
    await kit.registerAdmin();
    admin = (await accounts.findCredentials('owner'))!.account;
    await clinic.saveProfile(const Doctor(id: 'd1', name: 'Dr. Rahim'));
    await clinic.addChamber(
      const Chamber(id: 'c1', doctorId: 'd1', name: 'Main'),
      limit: 3,
    );
  });

  tearDown(() => database.close());

  test('should flag onboarding when no receptionist exists', () async {
    final context = await service.loadContext(admin);

    expect(context.assignmentTarget, AssignmentTarget.chamber);
    expect(context.targets.single.id, 'c1');
    expect(context.onboarding.needsAttention, isTrue);
  });

  test('should create a receptionist with chamber scopes', () async {
    final result = await service.createUser(
      admin: admin,
      role: Role.receptionist,
      username: 'desk',
      firstName: 'Front',
      lastName: 'Desk',
      email: 'desk@clinic.test',
      password: 'a-long-passphrase',
      scopeIds: ['c1'],
    );

    expect(result, isA<UserCreated>());
    final page = await service.listUsers(
      admin,
      query: const UserQuery(role: Role.receptionist),
    );
    expect(page.users, hasLength(1));
    expect(page.users.single.scopeIds, ['c1']);
    final context = await service.loadContext(admin);
    expect(context.onboarding.needsAttention, isFalse);
  });

  test('should refuse scopes that are not clinic chambers', () async {
    final result = await service.createUser(
      admin: admin,
      role: Role.receptionist,
      username: 'desk',
      firstName: 'Front',
      lastName: 'Desk',
      email: 'desk@clinic.test',
      password: 'a-long-passphrase',
      scopeIds: ['missing'],
    );

    expect(result, isA<CreateUserRefused>());
  });

  test('should deactivate a receptionist without deleting them', () async {
    final created = await service.createUser(
      admin: admin,
      role: Role.receptionist,
      username: 'desk',
      firstName: 'Front',
      lastName: 'Desk',
      email: 'desk@clinic.test',
      password: 'a-long-passphrase',
      scopeIds: ['c1'],
    );
    final userId = (created as UserCreated).user.account.id;

    final updated = await service.updateUser(
      admin: admin,
      userId: userId,
      firstName: 'Front',
      lastName: 'Desk',
      email: 'desk@clinic.test',
      phone: '',
      status: 'inactive',
    );

    expect(updated, isA<UserUpdated>());
    expect((updated as UserUpdated).user.status, 'inactive');
    expect(await accounts.findCredentials('desk'), isNull);
    expect(await accounts.findAccountById(userId), isNotNull);
  });

  test('should let any admin set a receptionist password', () async {
    final created = await service.createUser(
      admin: admin,
      role: Role.receptionist,
      username: 'desk',
      firstName: 'Front',
      lastName: 'Desk',
      email: 'desk@clinic.test',
      password: 'a-long-passphrase',
      scopeIds: ['c1'],
    );
    final userId = (created as UserCreated).user.account.id;

    final result = await service.setUserPassword(
      admin: admin,
      userId: userId,
      password: 'another-long-pass',
    );

    expect(result, isA<UserPasswordSet>());
    expect(await accounts.findCredentials('desk'), isNotNull);
  });

  test('should let the first admin set another admin password', () async {
    final second = await service.createUser(
      admin: admin,
      role: Role.admin,
      username: 'second',
      firstName: 'Second',
      lastName: 'Admin',
      email: 'second@clinic.test',
      password: 'a-long-passphrase',
      scopeIds: [],
    );
    final userId = (second as UserCreated).user.account.id;

    final result = await service.setUserPassword(
      admin: admin,
      userId: userId,
      password: 'replacement-pass',
    );

    expect(result, isA<UserPasswordSet>());
  });

  test(
    'should refuse when a later admin sets another admin password',
    () async {
      final second = await service.createUser(
        admin: admin,
        role: Role.admin,
        username: 'second',
        firstName: 'Second',
        lastName: 'Admin',
        email: 'second@clinic.test',
        password: 'a-long-passphrase',
        scopeIds: [],
      );
      final userId = (second as UserCreated).user.account.id;
      final third = await service.createUser(
        admin: admin,
        role: Role.admin,
        username: 'third',
        firstName: 'Third',
        lastName: 'Admin',
        email: 'third@clinic.test',
        password: 'a-long-passphrase',
        scopeIds: [],
      );
      final laterAdmin = (third as UserCreated).user.account;

      final result = await service.setUserPassword(
        admin: laterAdmin,
        userId: userId,
        password: 'replacement-pass',
      );

      expect(result, isA<SetUserPasswordRefused>());
      expect(
        (result as SetUserPasswordRefused).problem,
        SetUserPasswordProblem.forbidden,
      );
    },
  );

  test('should refuse disabling the first administrator', () async {
    final second = await service.createUser(
      admin: admin,
      role: Role.admin,
      username: 'second',
      firstName: 'Second',
      lastName: 'Admin',
      email: 'second@clinic.test',
      password: 'a-long-passphrase',
      scopeIds: [],
    );
    final laterAdmin = (second as UserCreated).user.account;

    final result = await service.updateUser(
      admin: laterAdmin,
      userId: admin.id,
      firstName: admin.firstName,
      lastName: admin.lastName,
      email: admin.email,
      phone: admin.phone,
      status: 'inactive',
    );

    expect(result, isA<UpdateUserRefused>());
    expect(
      (result as UpdateUserRefused).problem,
      UpdateUserProblem.cannotDisableInitialAdmin,
    );
  });
}
