// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/api/cors_policy.dart';
import 'package:algoritiq_app/api/local_api_server.dart';
import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:algoritiq_app/features/access/data/drift_account_repository.dart';
import 'package:algoritiq_app/features/queue/application/queue_service.dart';
import 'package:algoritiq_app/features/queue/data/drift_queue_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';
import '../support/licensing_kit.dart';

void main() {
  late AccessKit kit;
  late LocalApiServer server;
  late HttpClient client;

  setUp(() async {
    kit = await AccessKit.create();
    final accounts = DriftAccountRepository(kit.database);
    final queueRepo = DriftQueueRepository(kit.database);
    final queueService = QueueService(
      repository: queueRepo,
      accounts: accounts,
      clock: kit.clock.call,
      newId: () => 'id-${DateTime.now().microsecondsSinceEpoch}',
    );
    server = LocalApiServer(
      access: () async => kit.service,
      queue: () async => queueService,
      corsPolicy: CorsPolicy.reflectOrigin,
    );
    await server.start(port: 0, address: InternetAddress.loopbackIPv4);
    client = HttpClient();
  });

  tearDown(() async {
    client.close(force: true);
    await server.stop();
    await kit.close();
  });

  Future<({int status, Map<String, Object?> body})> call(
    String method,
    String path, {
    Map<String, Object?>? json,
    String? token,
  }) async {
    final request = await client.openUrl(
      method,
      Uri.parse('http://127.0.0.1:${server.port}$path'),
    );
    if (token != null) {
      request.headers.set('authorization', 'Bearer $token');
    }
    if (json != null) {
      request.headers.set('content-type', 'application/json; charset=utf-8');
      request.add(utf8.encode(jsonEncode(json)));
    }
    final response = await request.close();
    final text = await utf8.decodeStream(response);
    final body = text.isEmpty
        ? <String, Object?>{}
        : jsonDecode(text) as Map<String, Object?>;
    return (status: response.statusCode, body: body);
  }

  Map<String, Object?> register() => {
    'claimCode': kit.claimCodes.current().code,
    'username': 'owner',
    'firstName': 'The',
    'lastName': 'Owner',
    'email': 'owner@clinic.test',
    'password': AccessKit.password,
  };

  Future<String> signIn() async {
    await call('POST', '/api/v1/setup/admin', json: register());
    final result = await call(
      'POST',
      '/api/v1/auth/login',
      json: {'username': 'owner', 'password': AccessKit.password},
    );
    return result.body['token']! as String;
  }

  test('should load clinic queue defaults for an admin', () async {
    final token = await signIn();

    final result = await call('GET', '/api/v1/queue/defaults', token: token);

    expect(result.status, 200);
    expect(result.body['policy'], isA<Map<String, Object?>>());
    expect(result.body['types'], isA<List<Object?>>());
    expect((result.body['types']! as List).length, 3);
  });

  test('should recover when types exist but policy settings were missing', () async {
    final repo = DriftQueueRepository(kit.database);
    await repo.ensureClinicDefaultsSeeded();
    await kit.database.delete(kit.database.appSettings).go();

    final token = await signIn();
    final result = await call('GET', '/api/v1/queue/defaults', token: token);

    expect(result.status, 200);
    final policy = result.body['policy']! as Map<String, Object?>;
    expect(policy['dayBoundary'], '03:00');
  });

  test('should tolerate invalid stored policy json', () async {
    await kit.database.into(kit.database.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'queue.policy.clinic',
            value: 'not-json',
          ),
        );
    await DriftQueueRepository(kit.database).ensureClinicDefaultsSeeded();

    final token = await signIn();
    final result = await call('GET', '/api/v1/queue/defaults', token: token);

    expect(result.status, 200);
  });

  test('should persist edited queue type serial ranges', () async {
    final token = await signIn();
    final loaded = await call('GET', '/api/v1/queue/defaults', token: token);
    expect(loaded.status, 200);
    final policy = loaded.body['policy']! as Map<String, Object?>;
    final types = [
      for (final raw in loaded.body['types']! as List)
        Map<String, Object?>.from(raw as Map),
    ];
    types[0] = {
      ...types[0],
      'startNumber': 101,
      'endNumber': 199,
    };

    final patched = await call(
      'PATCH',
      '/api/v1/queue/defaults',
      token: token,
      json: {
        'timeZone': policy['timeZone'],
        'dayBoundary': policy['dayBoundary'],
        'autoStart': policy['autoStart'],
        'types': types,
      },
    );
    expect(patched.status, 200);
    final savedTypes = patched.body['types']! as List;
    final regular = savedTypes.first as Map<String, Object?>;
    expect(regular['startNumber'], 101);
    expect(regular['endNumber'], 199);

    final again = await call('GET', '/api/v1/queue/defaults', token: token);
    expect(again.status, 200);
    final reloaded = (again.body['types']! as List).first as Map<String, Object?>;
    expect(reloaded['startNumber'], 101);
    expect(reloaded['endNumber'], 199);
  });

  test('should save queue types for one chamber without changing another', () async {
    const chamberA = 'chamber-a';
    const chamberB = 'chamber-b';
    await seedDoctor(kit.database);
    for (final entry in [
      (chamberA, 'Chamber A'),
      (chamberB, 'Chamber B'),
    ]) {
      await kit.database.into(kit.database.chambers).insertOnConflictUpdate(
            ChambersCompanion.insert(
              id: entry.$1,
              doctorId: 'seed-doctor',
              name: entry.$2,
              createdAt: DateTime.utc(2026).millisecondsSinceEpoch,
            ),
          );
    }

    final token = await signIn();
    final loadedA = await call(
      'GET',
      '/api/v1/queue/chambers/$chamberA',
      token: token,
    );
    expect(loadedA.status, 200);
    final typesA = [
      for (final raw in loadedA.body['types']! as List)
        Map<String, Object?>.from(raw as Map),
    ];
    typesA[0] = {...typesA[0], 'startNumber': 501, 'endNumber': 599};

    final patched = await call(
      'PATCH',
      '/api/v1/queue/chambers/$chamberA',
      token: token,
      json: {'types': typesA},
    );
    expect(patched.status, 200);
    expect(
      (patched.body['settings'] as Map)['useClinicDefaults'],
      isFalse,
    );
    final savedRegular =
        (patched.body['types']! as List).first as Map<String, Object?>;
    expect(savedRegular['startNumber'], 501);

    final loadedB = await call(
      'GET',
      '/api/v1/queue/chambers/$chamberB',
      token: token,
    );
    expect(loadedB.status, 200);
    expect(
      (loadedB.body['settings'] as Map)['useClinicDefaults'],
      isTrue,
    );
    final otherRegular =
        (loadedB.body['types']! as List).first as Map<String, Object?>;
    expect(otherRegular['startNumber'], 1001);
  });

  test('should seed clinic defaults when another owner uses the same type ids', () async {
    await kit.database.into(kit.database.queueTypes).insert(
          QueueTypesCompanion.insert(
            id: 'regular',
            ownerKey: 'chamber-1',
            englishName: 'Regular',
            bengaliName: 'সাধারণ',
            startNumber: 1001,
            endNumber: 1099,
            displayOrder: 1,
          ),
        );

    final token = await signIn();
    final result = await call('GET', '/api/v1/queue/defaults', token: token);

    expect(result.status, 200);
    expect((result.body['types']! as List).length, 3);
  });
}
