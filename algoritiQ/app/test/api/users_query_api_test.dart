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
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/clinic/domain/chamber.dart';
import 'package:algoritiq_app/features/clinic/domain/doctor.dart';
import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';

typedef Reply = ({int status, Map<String, Object?> json});

void main() {
  late AccessKit kit;
  late LocalApiServer server;
  late HttpClient client;
  late String adminToken;
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

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    kit = await AccessKit.create();
    final clinic = DriftClinicRepository(kit.database, kit.clock);
    final users = UserManagementService(
      repository: kit.repository,
      clinic: clinic,
      hasher: kit.hasher,
      clock: kit.clock,
      newId: () => 'u-${ids++}',
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
    await clinic.saveProfile(const Doctor(id: 'd1', name: 'Dr. Rahim'));
    await clinic.addChamber(
      const Chamber(id: 'c1', doctorId: 'd1', name: 'Main'),
      limit: 3,
    );
    final login = await call(
      'POST',
      '/api/v1/auth/login',
      json: {'username': 'owner', 'password': AccessKit.password},
    );
    adminToken = login.json['token']! as String;
  });

  tearDown(() async {
    client.close(force: true);
    await server.stop();
    await kit.close();
  });

  Future<Reply> make(
    String name, {
    String? role,
    List<String> scopes = const [],
  }) => call(
    'POST',
    '/api/v1/users',
    json: {
      if (role != null) 'role': role,
      'username': name,
      'firstName': name[0].toUpperCase() + name.substring(1),
      'lastName': 'Test',
      'email': '$name@clinic.test',
      'password': 'a-long-passphrase',
      'scopeIds': scopes,
    },
  );

  Map<String, Object?> user(Reply reply) =>
      reply.json['user']! as Map<String, Object?>;

  List<String> names(Reply reply) => [
    for (final row in reply.json['users']! as List)
      (row as Map)['username'] as String,
  ];

  Future<void> makeMany() async {
    for (final (name, role) in [
      ('alice', 'receptionist'),
      ('bob', 'receptionist'),
      ('carol', 'admin'),
      ('dave', 'receptionist'),
      ('erin', 'receptionist'),
    ]) {
      await make(name, role: role);
    }
  }

  const patchBase = {'firstName': 'x', 'email': 'x@clinic.test'};

  Future<Reply> setStatus(
    String id,
    String status, {
    String? bearer,
    String? email,
  }) => call(
    'PATCH',
    '/api/v1/users/$id',
    bearer: bearer,
    json: {...patchBase, 'email': email ?? 'x@clinic.test', 'status': status},
  );

  group('creating admins', () {
    test(
      'should create another admin, with no scopes even if some are sent',
      () async {
        final created = await make('second', role: 'admin', scopes: ['c1']);

        expect(created.status, 201);
        expect(user(created)['role'], 'admin');
        expect(user(created)['scopeIds'], isEmpty);
      },
    );

    test('should default to a receptionist', () async {
      final created = await make('desk', scopes: ['c1']);

      expect(user(created)['role'], 'receptionist');
      expect(user(created)['scopeIds'], ['c1']);
      expect(
        DateTime.tryParse(user(created)['createdAt']! as String),
        isNotNull,
      );
    });

    test('should refuse an unknown role', () async {
      expect((await make('odd', role: 'doctor')).status, 400);
    });

    test('should refuse a username already in use', () async {
      await make('desk');

      final again = await make('desk');

      expect(again.status, 409);
      expect((again.json['error']! as Map)['code'], 'username_taken');
    });
  });

  group('disabling users', () {
    test('should disable and enable a user', () async {
      final id = user(await make('desk'))['id']! as String;

      final off = await setStatus(id, 'inactive', email: 'desk@clinic.test');
      final on = await setStatus(id, 'active', email: 'desk@clinic.test');

      expect(user(off)['status'], 'inactive');
      expect(user(on)['status'], 'active');
    });

    test('should not let admins disable themselves', () async {
      final me = await call('GET', '/api/v1/me');
      final id = (me.json['account']! as Map)['id'] as String;
      await make('second', role: 'admin');

      final result = await setStatus(
        id,
        'inactive',
        email: 'owner@clinic.test',
      );

      expect(result.status, 409);
      expect((result.json['error']! as Map)['code'], 'cannot_disable_self');
    });

    test('should end the sessions of a disabled user', () async {
      final id = user(await make('desk'))['id']! as String;
      final login = await call(
        'POST',
        '/api/v1/auth/login',
        json: {'username': 'desk', 'password': 'a-long-passphrase'},
      );
      final token = login.json['token']! as String;
      expect((await call('GET', '/api/v1/me', bearer: token)).status, 200);

      await setStatus(id, 'inactive', email: 'desk@clinic.test');

      expect((await call('GET', '/api/v1/me', bearer: token)).status, 401);
    });

    test(
      'should be allowed for another admin, never for the last one',
      () async {
        final me = await call('GET', '/api/v1/me');
        final firstId = (me.json['account']! as Map)['id'] as String;
        final secondId =
            user(await make('second', role: 'admin'))['id']! as String;
        final login = await call(
          'POST',
          '/api/v1/auth/login',
          json: {'username': 'second', 'password': 'a-long-passphrase'},
        );
        final second = login.json['token']! as String;

        final ok = await setStatus(
          firstId,
          'inactive',
          bearer: second,
          email: 'owner@clinic.test',
        );
        final self = await setStatus(
          secondId,
          'inactive',
          bearer: second,
          email: 'second@clinic.test',
        );

        expect(ok.status, 200);
        expect(self.status, 409);
      },
    );
  });

  group('listing with search, filter, sort and paging', () {
    test(
      'should leave the signed-in admin out, even when searched for',
      () async {
        await makeMany();

        expect(names(await call('GET', '/api/v1/users?search=owner')), isEmpty);
        expect(names(await call('GET', '/api/v1/users?role=admin')), ['carol']);
        expect(
          (await call('GET', '/api/v1/users')).json['total'],
          5,
          reason: 'the total does not count the signed-in admin either',
        );
      },
    );

    test('should search by part of the name, username or email', () async {
      await makeMany();

      expect(names(await call('GET', '/api/v1/users?search=ALI')), ['alice']);
      expect(names(await call('GET', '/api/v1/users?search=carol@')), [
        'carol',
      ]);
      expect(names(await call('GET', '/api/v1/users?search=nobody')), isEmpty);
    });

    test('should treat % and _ in the search as plain text', () async {
      await makeMany();

      expect(names(await call('GET', '/api/v1/users?search=%25')), isEmpty);
      expect(names(await call('GET', '/api/v1/users?search=_')), isEmpty);
    });

    test('should filter by role and status', () async {
      await makeMany();

      expect(
        names(await call('GET', '/api/v1/users?role=admin&sort=username')),
        ['carol'],
      );
      expect(
        names(await call('GET', '/api/v1/users?status=inactive')),
        isEmpty,
      );
    });

    test('should sort both ways', () async {
      await makeMany();

      final up = await call('GET', '/api/v1/users?sort=username&dir=asc');
      final down = await call('GET', '/api/v1/users?sort=username&dir=desc');

      expect(names(up), ['alice', 'bob', 'carol', 'dave', 'erin']);
      expect(names(down), ['erin', 'dave', 'carol', 'bob', 'alice']);
    });

    test('should page with a cursor and report the total', () async {
      await makeMany();

      final first = await call('GET', '/api/v1/users?sort=username&limit=4');
      final cursor = first.json['nextCursor']! as String;
      final second = await call(
        'GET',
        '/api/v1/users?sort=username&limit=4&cursor=$cursor',
      );

      expect(names(first), ['alice', 'bob', 'carol', 'dave']);
      expect(first.json['total'], 5);
      expect(names(second), ['erin']);
      expect(second.json['nextCursor'], isNull);
    });

    test('should keep the filter and total across pages', () async {
      await makeMany();
      const base = '/api/v1/users?role=receptionist&sort=username&limit=2';

      final first = await call('GET', base);
      final second = await call(
        'GET',
        '$base&cursor=${first.json['nextCursor']}',
      );

      expect(first.json['total'], 4);
      expect(names(second), ['dave', 'erin']);
      expect(second.json['nextCursor'], isNull);
    });

    test('should cap the page size', () async {
      await makeMany();

      final result = await call('GET', '/api/v1/users?limit=9999');

      expect(result.status, 200);
      expect(names(result), hasLength(5));
    });

    test('should refuse bad query values', () async {
      for (final query in [
        'role=doctor',
        'status=gone',
        'sort=password',
        'dir=sideways',
        'limit=abc',
        'cursor=%21%21',
      ]) {
        expect(
          (await call('GET', '/api/v1/users?$query')).status,
          400,
          reason: query,
        );
      }
    });

    test('should be for admins only', () async {
      await makeMany();
      final login = await call(
        'POST',
        '/api/v1/auth/login',
        json: {'username': 'alice', 'password': 'a-long-passphrase'},
      );

      final result = await call(
        'GET',
        '/api/v1/users',
        bearer: login.json['token']! as String,
      );

      expect(result.status, 403);
    });
  });
}
