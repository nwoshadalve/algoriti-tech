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
import 'package:algoritiq_app/features/clinic/application/chamber_service.dart';
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/clinic/domain/doctor.dart';
import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';

typedef Reply = ({int status, Map<String, Object?> json});

LicensePayload _license(
  LicenseType type, {
  int maxChambers = 3,
  int? expiresDay,
}) => LicensePayload(
  keyId: 1,
  type: type,
  maxDoctors: type == LicenseType.doctor ? 1 : 5,
  maxChambers: type == LicenseType.chamber ? 1 : maxChambers,
  issuedDay: 20000,
  expiresDay: expiresDay,
  device: DeviceCode(Uint8List.fromList([0, 1, 2, 3, 4, 5])),
  licenseId: Uint8List.fromList([1, 2, 3, 4]),
);

void main() {
  late AccessKit kit;
  late LocalApiServer server;
  late HttpClient client;
  late String adminToken;
  late DriftClinicRepository clinic;
  var ids = 0;

  Future<Reply> call(
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
    );
  }

  Future<void> start(
    LicenseType type, {
    bool withDoctor = true,
    int maxChambers = 3,
    int? expiresDay,
  }) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    kit = await AccessKit.create();
    clinic = DriftClinicRepository(kit.database, kit.clock);
    final payload = _license(
      type,
      maxChambers: maxChambers,
      expiresDay: expiresDay,
    );
    final users = UserManagementService(
      repository: kit.repository,
      clinic: clinic,
      hasher: kit.hasher,
      clock: kit.clock,
      newId: () => 'u-${ids++}',
      licensePayload: () async => payload,
    );
    final chambers = ChamberService(
      clinic: clinic,
      accounts: kit.repository,
      clock: kit.clock,
      newId: () => 'c-${ids++}',
      licensePayload: () async => payload,
    );
    server = LocalApiServer(
      access: () async => kit.service,
      users: () async => users,
      chambers: () async => chambers,
    );
    await server.start(port: 0, address: InternetAddress.loopbackIPv4);
    client = HttpClient();
    await kit.registerAdmin();
    if (withDoctor) {
      await clinic.saveProfile(const Doctor(id: 'd1', name: 'Dr. Rahim'));
    }
    final login = await call(
      'POST',
      '/api/v1/auth/login',
      json: {'username': 'owner', 'password': AccessKit.password},
    );
    adminToken = login.json['token']! as String;
  }

  tearDown(() async {
    client.close(force: true);
    await server.stop();
    await kit.close();
  });

  Map<String, Object?> chamber(Reply r) =>
      r.json['chamber']! as Map<String, Object?>;

  Future<Reply> add(String name, {String? location, String? phone}) => call(
    'POST',
    '/api/v1/chambers',
    json: {
      'name': name,
      'location': location ?? '12 Lake Road',
      'phone': phone ?? '01711000000',
    },
  );

  String code(Reply r) => (r.json['error']! as Map)['code'] as String;

  group('for a doctor license of three chambers', () {
    setUp(() => start(LicenseType.doctor));

    test('should summarise the license and what is used', () async {
      await add('Main');

      final result = await call('GET', '/api/v1/license');
      final license = result.json['license']! as Map<String, Object?>;

      expect(result.status, 200);
      expect(license['type'], 'doctor');
      expect(license['maxDoctors'], 1);
      expect(license['maxChambers'], 3);
      expect(license['chambersUsed'], 1);
      expect(license['expiresAt'], isNull);
      expect(license['status'], 'active');
    });

    test('should add, list and edit chambers', () async {
      final created = await add('  Main  ', location: ' 12 Lake Road ');
      final id = chamber(created)['id']! as String;

      final edited = await call(
        'PATCH',
        '/api/v1/chambers/$id',
        json: {
          'name': 'Main chamber',
          'location': 'New address',
          'phone': '+880 1711-000000',
        },
      );
      final listed = await call('GET', '/api/v1/chambers');

      expect(created.status, 201);
      expect(chamber(created)['name'], 'Main');
      expect(chamber(created)['location'], '12 Lake Road');
      expect(edited.status, 200);
      expect(chamber(edited)['phone'], '+880 1711-000000');
      final rows = listed.json['chambers']! as List;
      expect(rows, hasLength(1));
      expect((rows.single as Map)['name'], 'Main chamber');
    });

    test('should refuse a fourth chamber with the limit message', () async {
      for (final name in ['A', 'B', 'C']) {
        expect((await add(name)).status, 201);
      }

      final fourth = await add('D');

      expect(fourth.status, 409);
      expect(code(fourth), 'chamber_limit_reached');
      expect(
        ((await call('GET', '/api/v1/chambers')).json['chambers']! as List),
        hasLength(3),
      );
    });

    test('should free a place when a chamber is deleted', () async {
      final ids = <String>[];
      for (final name in ['A', 'B', 'C']) {
        ids.add(chamber(await add(name))['id']! as String);
      }

      final deleted = await call('DELETE', '/api/v1/chambers/${ids.first}');
      final again = await add('D');

      expect(deleted.status, 204);
      expect(again.status, 201);
    });

    test('should never delete the last chamber', () async {
      final id = chamber(await add('Only'))['id']! as String;

      final result = await call('DELETE', '/api/v1/chambers/$id');

      expect(result.status, 409);
      expect(code(result), 'last_chamber');
    });

    test('should take a deleted chamber away from receptionists', () async {
      final keep = chamber(await add('Keep'))['id']! as String;
      final drop = chamber(await add('Drop'))['id']! as String;
      final created = await call(
        'POST',
        '/api/v1/users',
        json: {
          'username': 'desk',
          'firstName': 'Front',
          'lastName': 'Desk',
          'email': 'desk@clinic.test',
          'password': 'a-long-passphrase',
          'scopeIds': [keep, drop],
        },
      );
      expect(
        ((created.json['user']! as Map)['scopeIds'] as List),
        hasLength(2),
      );

      await call('DELETE', '/api/v1/chambers/$drop');

      final listed = await call('GET', '/api/v1/users?search=desk');
      final row = (listed.json['users']! as List).single as Map;
      expect(row['scopeIds'], [keep]);
    });

    test('should refuse blank, long and badly formed values', () async {
      expect(code(await add(' ')), 'chamber_name_missing');
      expect(code(await add('A', location: ' ')), 'chamber_location_missing');
      expect(code(await add('A', phone: ' ')), 'chamber_phone_missing');
      expect(code(await add('A', phone: 'call me')), 'chamber_phone_invalid');
      expect(code(await add('x' * 121)), 'chamber_too_long');
      expect(code(await add('A', location: 'l' * 201)), 'chamber_too_long');
    });

    test('should answer 404 for an unknown chamber', () async {
      final patch = await call(
        'PATCH',
        '/api/v1/chambers/nope',
        json: {'name': 'A', 'location': 'B', 'phone': '1'},
      );
      final delete = await call('DELETE', '/api/v1/chambers/nope');

      expect(patch.status, 404);
      expect(delete.status, 404);
    });

    test('should be for admins only', () async {
      await call(
        'POST',
        '/api/v1/users',
        json: {
          'username': 'desk',
          'firstName': 'Front',
          'lastName': 'Desk',
          'email': 'desk@clinic.test',
          'password': 'a-long-passphrase',
        },
      );
      final login = await call(
        'POST',
        '/api/v1/auth/login',
        json: {'username': 'desk', 'password': 'a-long-passphrase'},
      );
      final token = login.json['token']! as String;

      expect(
        (await call('GET', '/api/v1/chambers', bearer: token)).status,
        403,
      );
      expect((await call('GET', '/api/v1/license', bearer: token)).status, 403);
      expect(
        (await call('GET', '/api/v1/chambers', bearer: 'made-up')).status,
        401,
      );
    });
  });

  group('limits and expiry', () {
    test('should hold to a license of one chamber', () async {
      await start(LicenseType.doctor, maxChambers: 1);

      expect((await add('A')).status, 201);
      expect(code(await add('B')), 'chamber_limit_reached');
    });

    test('should report when the license ends', () async {
      await start(LicenseType.doctor, expiresDay: 40000);

      final license =
          (await call('GET', '/api/v1/license')).json['license']! as Map;

      expect(DateTime.tryParse(license['expiresAt']! as String), isNotNull);
    });
  });

  group('without a doctor license', () {
    test('should have no chambers page for a chamber license', () async {
      await start(LicenseType.chamber);

      final result = await call('GET', '/api/v1/chambers');

      expect(result.status, 404);
      expect(code(result), 'license_unavailable');
      expect((await call('GET', '/api/v1/license')).status, 404);
    });

    test('should have nothing before the doctor is set up', () async {
      await start(LicenseType.doctor, withDoctor: false);

      expect((await call('GET', '/api/v1/chambers')).status, 404);
    });
  });
}
