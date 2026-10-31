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
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/queue/application/queue_service.dart';
import 'package:algoritiq_app/features/queue/data/drift_queue_repository.dart';
import 'package:algoritiq_app/features/queue/domain/queue_models.dart';
import 'package:algoritiq_app/features/queue_board/application/queue_board_service.dart';
import 'package:algoritiq_app/features/queue_board/data/drift_queue_board_repository.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';
import '../support/licensing_kit.dart';

void main() {
  late AccessKit kit;
  late LocalApiServer server;
  late HttpClient client;
  const chamberId = '902abfb3-fcb0-47ca-9315-b37b2e15b955';

  setUp(() async {
    kit = await AccessKit.create();
    await seedDoctor(kit.database);
    await kit.database
        .into(kit.database.chambers)
        .insertOnConflictUpdate(
          ChambersCompanion.insert(
            id: chamberId,
            doctorId: 'seed-doctor',
            name: 'Room 1',
            createdAt: DateTime.utc(2026).millisecondsSinceEpoch,
          ),
        );

    final accounts = DriftAccountRepository(kit.database);
    final queueRepo = DriftQueueRepository(kit.database);
    final queueService = QueueService(
      repository: queueRepo,
      accounts: accounts,
      clock: kit.clock.call,
      newId: () => 'id-${DateTime.now().microsecondsSinceEpoch}',
    );
    final boardRepo = DriftQueueBoardRepository(kit.database, queueRepo);
    final clinic = DriftClinicRepository(kit.database, kit.clock.call);
    final boardService = QueueBoardService(
      boardRepo: boardRepo,
      queueService: queueService,
      clinic: clinic,
      accounts: accounts,
      clock: kit.clock.call,
      newId: () => 'id-${DateTime.now().microsecondsSinceEpoch}',
    );

    server = LocalApiServer(
      access: () async => kit.service,
      queue: () async => queueService,
      queueBoard: () async => boardService,
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
    String? token,
  }) async {
    final request = await client.openUrl(
      method,
      Uri.parse('http://127.0.0.1:${server.port}$path'),
    );
    if (token != null) {
      request.headers.set('authorization', 'Bearer $token');
    }
    final response = await request.close();
    final text = await utf8.decodeStream(response);
    final body = text.isEmpty
        ? <String, Object?>{}
        : jsonDecode(text) as Map<String, Object?>;
    return (status: response.statusCode, body: body);
  }

  Future<String> signIn() async {
    await kit.registerAdmin();
    final loginRequest = await client.postUrl(
      Uri.parse('http://127.0.0.1:${server.port}/api/v1/auth/login'),
    );
    loginRequest.headers.set('content-type', 'application/json');
    loginRequest.write(
      jsonEncode({
        'username': 'owner',
        'password': AccessKit.password,
        'clientKey': 'test',
      }),
    );
    final loginResponse = await loginRequest.close();
    final loginBody =
        jsonDecode(await utf8.decodeStream(loginResponse)) as Map<String, Object?>;
    return loginBody['token']! as String;
  }

  test('should return board snapshot for a chamber', () async {
    final token = await signIn();
    final result = await call(
      'GET',
      '/api/v1/queue-board/chambers/$chamberId',
      token: token,
    );

    expect(result.status, 200);
    expect(result.body['chamberId'], chamberId);
    expect(result.body['sessionOpen'], isFalse);
  });

  test('should return board snapshot with tokens in session', () async {
    final token = await signIn();
    final queueRepo = DriftQueueRepository(kit.database);
    await queueRepo.ensureClinicDefaultsSeeded();
    final types = await queueRepo.loadTypesForOwner('clinic');
    final enabled = types.where((t) => t.enabled).first;
    await queueRepo.insertSession(
      id: 'session-1',
      chamberId: chamberId,
      businessDate: '2026-11-01',
      status: QueueSessionStatus.open.apiValue,
      openedAt: kit.clock(),
      openedByAccountId: 'admin',
      snapshot: const {},
      types: types,
    );
    final boardRepo = DriftQueueBoardRepository(kit.database, queueRepo);
    final patient = await boardRepo.insertPatient(
      id: 'patient-1',
      patientNumber: 1,
      input: const PatientInput(bengaliName: 'Test', phone: '01712345678'),
      createdAtMs: kit.clock().millisecondsSinceEpoch,
    );
    await boardRepo.issueToken(
      tokenId: 'tok-1',
      sessionId: 'session-1',
      chamberId: chamberId,
      patientId: patient.id,
      queueTypeId: enabled.id,
      feeBdt: 100,
      issuedAtMs: kit.clock().millisecondsSinceEpoch,
    );

    final result = await call(
      'GET',
      '/api/v1/queue-board/chambers/$chamberId',
      token: token,
    );

    expect(result.status, 200);
    expect(result.body['sessionOpen'], isTrue);
    final tokens = result.body['tokens']! as List;
    expect(tokens, isNotEmpty);
  });
}
