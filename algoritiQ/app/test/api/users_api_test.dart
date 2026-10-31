// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:algoritiq_app/api/local_api_server.dart';
import 'package:algoritiq_app/features/access/application/user_management_service.dart';
import 'package:algoritiq_app/features/access/data/argon2id_password_hasher.dart';
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/clinic/domain/chamber.dart';
import 'package:algoritiq_app/features/clinic/domain/doctor.dart';
import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';
import '../support/memory_secret_store.dart';

void main() {
  late AccessKit kit;
  late LocalApiServer server;
  late HttpClient client;
  late String adminToken;
  late UserManagementService users;
  var userIds = 0;

  Future<
    ({int status, Map<String, Object?> json, List<int> bytes, String? type})
  >
  call(
    String method,
    String path, {
    Map<String, Object?>? json,
    String? bearer,
  }) async {
    final request = await client.openUrl(
      method,
      Uri.parse('http://127.0.0.1:${server.port}$path'),
    );
    final who = bearer ?? (path.contains('/auth/') ? null : adminToken);
    if (who != null) request.headers.set('authorization', 'Bearer $who');
    if (json != null) {
      request.headers.set('content-type', 'application/json');
      request.write(jsonEncode(json));
    }
    final response = await request.close();
    final body = <int>[for (final chunk in await response.toList()) ...chunk];
    final isJson = response.headers.contentType?.subType == 'json';
    return (
      status: response.statusCode,
      json: isJson && body.isNotEmpty
          ? jsonDecode(utf8.decode(body)) as Map<String, Object?>
          : <String, Object?>{},
      bytes: body,
      type: response.headers.contentType?.mimeType,
    );
  }

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    kit = await AccessKit.create();
    final clinic = DriftClinicRepository(kit.database, kit.clock);
    users = UserManagementService(
      repository: kit.repository,
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
    server = LocalApiServer(
      access: () async => kit.service,
      users: () async => users,
    );
    await server.start(port: 0, address: InternetAddress.loopbackIPv4);
    client = HttpClient();
    await kit.registerAdmin();
    final clinicRepo = DriftClinicRepository(kit.database, kit.clock);
    await clinicRepo.saveProfile(const Doctor(id: 'd1', name: 'Dr. Rahim'));
    await clinicRepo.addChamber(
      const Chamber(id: 'c1', doctorId: 'd1', name: 'Main'),
      limit: 3,
    );
    final login = await call(
      'POST',
      '/api/v1/auth/login',
      json: {'username': 'owner', 'password': AccessKit.password},
      bearer: null,
    );
    adminToken = login.json['token']! as String;
  });

  tearDown(() async {
    client.close(force: true);
    await server.stop();
    await kit.close();
  });

  Map<String, Object?> user(Map<String, Object?> json) =>
      json['user']! as Map<String, Object?>;

  test('should expose user context for admins', () async {
    final result = await call('GET', '/api/v1/users/context');

    expect(result.status, 200);
    expect(result.json['assignmentTarget'], 'chamber');
    expect(
      (result.json['onboarding']! as Map<String, Object?>)['needsAttention'],
      isTrue,
    );
  });

  test('should create and list receptionists', () async {
    final created = await call(
      'POST',
      '/api/v1/users',
      json: {
        'username': 'desk',
        'firstName': 'Front',
        'lastName': 'Desk',
        'email': 'desk@clinic.test',
        'password': 'a-long-passphrase',
        'scopeIds': ['c1'],
      },
    );

    expect(created.status, 201);
    expect(user(created.json)['role'], 'receptionist');
    expect(user(created.json)['scopeIds'], ['c1']);

    final listed = await call('GET', '/api/v1/users');
    expect(listed.status, 200);
    final rows = listed.json['users']! as List<Object?>;
    // The admin who signed in is not in their own list.
    expect(rows, hasLength(1));
    expect(listed.json['total'], 1);
    expect(listed.json['nextCursor'], isNull);
  });

  test('should patch a receptionist status', () async {
    final created = await call(
      'POST',
      '/api/v1/users',
      json: {
        'username': 'desk',
        'firstName': 'Front',
        'lastName': 'Desk',
        'email': 'desk@clinic.test',
        'password': 'a-long-passphrase',
        'scopeIds': ['c1'],
      },
    );
    final id = user(created.json)['id']! as String;

    final patched = await call(
      'PATCH',
      '/api/v1/users/$id',
      json: {
        'firstName': 'Front',
        'lastName': 'Desk',
        'email': 'desk@clinic.test',
        'status': 'inactive',
      },
    );

    expect(patched.status, 200);
    expect(user(patched.json)['status'], 'inactive');
  });
}
