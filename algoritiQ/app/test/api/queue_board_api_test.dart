// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:algoritiq_app/api/cors_policy.dart';
import 'package:algoritiq_app/api/local_api_server.dart';
import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:algoritiq_app/features/access/data/drift_account_repository.dart';
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/clinic/domain/doctor.dart';
import 'package:algoritiq_app/features/queue/application/queue_service.dart';
import 'package:algoritiq_app/features/queue/data/drift_queue_repository.dart';
import 'package:algoritiq_app/features/queue/domain/queue_models.dart';
import 'package:algoritiq_app/features/queue_board/application/queue_board_service.dart';
import 'package:algoritiq_app/features/queue_board/application/token_print_service.dart';
import 'package:algoritiq_app/features/connectivity/domain/printer.dart';
import 'package:algoritiq_app/features/queue_board/data/drift_queue_board_repository.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/access/application/access_service.dart';
import 'package:algoritiq_app/features/access/application/user_management_service.dart';
import 'package:algoritiq_app/features/access/domain/account.dart';
import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';
import '../support/licensing_kit.dart';

void main() {
  late AccessKit kit;
  late LocalApiServer server;
  late HttpClient client;
  late UserManagementService userMgmt;
  late Account adminAccount;
  const chamberId = '902abfb3-fcb0-47ca-9315-b37b2e15b955';
  const deskPassword = 'desk-pass-phrase-12';

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
            patientIdPrefix: '776',
            createdAt: DateTime.utc(2026).millisecondsSinceEpoch,
          ),
        );
    const otherChamberId = '11111111-1111-1111-1111-111111111111';
    await kit.database
        .into(kit.database.chambers)
        .insertOnConflictUpdate(
          ChambersCompanion.insert(
            id: otherChamberId,
            doctorId: 'seed-doctor',
            name: 'Room 2',
            patientIdPrefix: '777',
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
    await clinic.saveProfile(const Doctor(id: 'seed-doctor', name: 'Dr Test'));
    final boardService = QueueBoardService(
      boardRepo: boardRepo,
      queueService: queueService,
      clinic: clinic,
      accounts: accounts,
      clock: kit.clock.call,
      newId: () => 'id-${DateTime.now().microsecondsSinceEpoch}',
    );
    userMgmt = UserManagementService(
      repository: kit.repository,
      clinic: clinic,
      hasher: kit.hasher,
      clock: kit.clock.call,
      newId: () => 'recv-${DateTime.now().microsecondsSinceEpoch}',
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
      queue: () async => queueService,
      queueBoard: () async => boardService,
      tokenPrint: () async => TokenPrintService(
        board: boardService,
        clinic: clinic,
        print: (_) async => PrintOutcome.printed,
      ),
      corsPolicy: CorsPolicy.reflectOrigin,
    );
    await server.start(port: 0, address: InternetAddress.loopbackIPv4);
    client = HttpClient();
    final reg = await kit.registerAdmin();
    adminAccount = switch (reg) {
      Registered(:final account) => account,
      _ => throw StateError('expected admin registration'),
    };
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

  Future<String> signIn({
    String username = 'owner',
    String password = AccessKit.password,
  }) async {
    final loginRequest = await client.postUrl(
      Uri.parse('http://127.0.0.1:${server.port}/api/v1/auth/login'),
    );
    loginRequest.headers.set('content-type', 'application/json');
    loginRequest.write(
      jsonEncode({
        'username': username,
        'password': password,
        'clientKey': 'test',
      }),
    );
    final loginResponse = await loginRequest.close();
    final loginBody = jsonDecode(
      await utf8.decodeStream(loginResponse),
    ) as Map<String, Object?>;
    return loginBody['token']! as String;
  }

  test('should return board snapshot for a chamber', () async {
    final token = await signIn();
    final result = await call(
      'GET',
      '/api/v1/queue-desk/chambers/$chamberId',
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
      clinicPatientId: 'P-000001',
      patientIdPrefix: '',
      patientIdSequence: 1,
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
      '/api/v1/queue-desk/chambers/$chamberId',
      token: token,
    );

    expect(result.status, 200);
    expect(result.body['sessionOpen'], isTrue);
    final tokens = result.body['tokens']! as List;
    expect(tokens, isNotEmpty);
  });

  test('should omit tokens when includeTokens is false', () async {
    final token = await signIn();
    final queueRepo = DriftQueueRepository(kit.database);
    await queueRepo.ensureClinicDefaultsSeeded();
    final types = await queueRepo.loadTypesForOwner('clinic');
    await queueRepo.insertSession(
      id: 'session-2',
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
      id: 'patient-include-false',
      patientNumber: 9,
      clinicPatientId: 'P-000009',
      patientIdPrefix: '',
      patientIdSequence: 9,
      input: const PatientInput(bengaliName: 'NoList', phone: '01712345670'),
      createdAtMs: kit.clock().millisecondsSinceEpoch,
    );
    await boardRepo.issueToken(
      tokenId: 'tok-2',
      sessionId: 'session-2',
      chamberId: chamberId,
      patientId: patient.id,
      queueTypeId: types.first.id,
      feeBdt: null,
      issuedAtMs: kit.clock().millisecondsSinceEpoch,
    );

    final result = await call(
      'GET',
      '/api/v1/queue-desk/chambers/$chamberId?includeTokens=false',
      token: token,
    );

    expect(result.status, 200);
    expect(result.body['tokens'], isEmpty);
    expect(result.body['sessionOpen'], isTrue);
  });

  test('should page session tokens', () async {
    final token = await signIn();
    final queueRepo = DriftQueueRepository(kit.database);
    await queueRepo.ensureClinicDefaultsSeeded();
    final types = await queueRepo.loadTypesForOwner('clinic');
    final enabled = types.where((t) => t.enabled).first;
    await queueRepo.insertSession(
      id: 'session-3',
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
      id: 'patient-2',
      patientNumber: 2,
      clinicPatientId: 'P-000002',
      patientIdPrefix: '',
      patientIdSequence: 2,
      input: const PatientInput(bengaliName: 'Paged', phone: '01712345679'),
      createdAtMs: kit.clock().millisecondsSinceEpoch,
    );
    await boardRepo.issueToken(
      tokenId: 'tok-3',
      sessionId: 'session-3',
      chamberId: chamberId,
      patientId: patient.id,
      queueTypeId: enabled.id,
      feeBdt: null,
      issuedAtMs: kit.clock().millisecondsSinceEpoch,
    );

    final result = await call(
      'GET',
      '/api/v1/queue-desk/chambers/$chamberId/session/tokens?limit=10',
      token: token,
    );

    expect(result.status, 200);
    expect(result.body['total'], 1);
    final items = result.body['items']! as List;
    expect(items, hasLength(1));
    expect(result.body['counts'], isA<Map>());
  });

  test('should allow a scoped receptionist on the desk API', () async {
    await signIn();
    final created = await userMgmt.createUser(
      admin: adminAccount,
      role: Role.receptionist,
      username: 'desk1',
      firstName: 'Desk',
      lastName: 'One',
      email: 'desk1@clinic.test',
      password: deskPassword,
      scopeIds: [chamberId],
    );
    expect(created, isA<UserCreated>());

    final deskToken = await signIn(username: 'desk1', password: deskPassword);
    final result = await call(
      'GET',
      '/api/v1/queue-desk/chambers/$chamberId',
      token: deskToken,
    );

    expect(result.status, 200);
    expect(result.body['chamberId'], chamberId);
  });

  test('should refuse a receptionist outside the chamber scope', () async {
    await signIn();
    const otherChamberId = '11111111-1111-1111-1111-111111111111';
    await userMgmt.createUser(
      admin: adminAccount,
      role: Role.receptionist,
      username: 'desk2',
      firstName: 'Desk',
      lastName: 'Two',
      email: 'desk2@clinic.test',
      password: deskPassword,
      scopeIds: [otherChamberId],
    );

    final deskToken = await signIn(username: 'desk2', password: deskPassword);
    final result = await call(
      'GET',
      '/api/v1/queue-desk/chambers/$chamberId',
      token: deskToken,
    );

    expect(result.status, 403);
    expect((result.body['error']! as Map)['code'], 'forbidden');
  });
}
