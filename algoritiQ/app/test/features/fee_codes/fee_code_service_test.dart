// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/api/cors_policy.dart';
import 'package:algoritiq_app/api/local_api_server.dart';
import 'package:algoritiq_app/features/access/application/access_service.dart';
import 'package:algoritiq_app/features/access/domain/account.dart';
import 'package:algoritiq_app/features/fee_codes/application/fee_code_service.dart';
import 'package:algoritiq_app/features/fee_codes/domain/fee_code.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/access_kit.dart';

void main() {
  group('the rules', () {
    FeeCode fee(String code, int amount) =>
        FeeCode(id: code, code: code, amountBdt: amount);

    test('should accept a normal list and an empty one', () {
      expect(FeeCodes.validate([fee('NEW', 500), fee('FOLLOW', 300)]), isNull);
      expect(FeeCodes.validate(const []), isNull);
    });

    test('should refuse an empty, long or repeated code', () {
      expect(FeeCodes.validate([fee('  ', 100)]), FeeCodeProblem.codeRequired);
      expect(
        FeeCodes.validate([fee('X' * 17, 100)]),
        FeeCodeProblem.codeTooLong,
      );
      expect(
        FeeCodes.validate([fee('New', 100), fee('NEW', 200)]),
        FeeCodeProblem.codeDuplicate,
      );
    });

    test('should refuse an amount that is not a positive whole number', () {
      expect(FeeCodes.validate([fee('A', 0)]), FeeCodeProblem.amountInvalid);
      expect(FeeCodes.validate([fee('A', -5)]), FeeCodeProblem.amountInvalid);
      expect(
        FeeCodes.validate([fee('A', FeeCodes.maxAmountBdt + 1)]),
        FeeCodeProblem.amountInvalid,
      );
    });

    test('should refuse more codes than the limit', () {
      final many = [for (var i = 0; i < 51; i++) fee('C$i', 100)];
      expect(FeeCodes.validate(many), FeeCodeProblem.tooMany);
    });
  });

  group('the service', () {
    late AccessKit kit;
    late FeeCodeService service;
    late Account admin;
    var ids = 0;

    setUp(() async {
      kit = await AccessKit.create();
      admin = (await kit.registerAdmin() as Registered).account;
      ids = 0;
      service = FeeCodeService(
        database: kit.database,
        accounts: kit.repository,
        clock: kit.clock.call,
        newId: () => 'id-${++ids}',
      );
    });

    tearDown(() => kit.close());

    test('should start with no codes', () async {
      expect(await service.list(), isEmpty);
    });

    test('should keep the list in order and give new codes an id', () async {
      await service.replace(admin, const [
        FeeCode(id: '', code: 'NEW', amountBdt: 500),
        FeeCode(id: '', code: 'FOLLOW', amountBdt: 300),
      ]);
      final saved = await service.list();

      expect(saved.map((f) => f.code), ['NEW', 'FOLLOW']);
      expect(saved.map((f) => f.amountBdt), [500, 300]);
      expect(saved.map((f) => f.id), ['id-1', 'id-2']);
    });

    test('should keep the id of a code that is renamed', () async {
      await service.replace(admin, const [
        FeeCode(id: '', code: 'NEW', amountBdt: 500),
      ]);

      await service.replace(admin, const [
        FeeCode(id: 'id-1', code: 'FIRST', amountBdt: 600),
      ]);

      final saved = (await service.list()).single;
      expect(saved.id, 'id-1');
      expect(saved.code, 'FIRST');
      expect(saved.amountBdt, 600);
    });

    test('should clear the list with an empty one', () async {
      await service.replace(admin, const [
        FeeCode(id: '', code: 'NEW', amountBdt: 500),
      ]);

      await service.replace(admin, const []);

      expect(await service.list(), isEmpty);
    });

    test('should refuse a bad list and keep the old one', () async {
      await service.replace(admin, const [
        FeeCode(id: '', code: 'NEW', amountBdt: 500),
      ]);

      await expectLater(
        service.replace(admin, const [
          FeeCode(id: '', code: 'A', amountBdt: 0),
        ]),
        throwsA(isA<FeeCodeRefused>()),
      );

      expect((await service.list()).single.code, 'NEW');
    });
  });

  group('the web route', () {
    late AccessKit kit;
    late LocalApiServer server;
    late HttpClient client;

    setUp(() async {
      kit = await AccessKit.create();
      await kit.registerAdmin();
      server = LocalApiServer(
        access: () async => kit.service,
        feeCodes: FeeCodeService(
          database: kit.database,
          accounts: kit.repository,
          clock: kit.clock.call,
          newId: () => 'fee-${DateTime.now().microsecondsSinceEpoch}',
        ),
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

    Future<String> signIn() async {
      final request = await client.postUrl(
        Uri.parse('http://127.0.0.1:${server.port}/api/v1/auth/login'),
      );
      request.headers.set('content-type', 'application/json');
      request.write(
        jsonEncode({
          'username': 'owner',
          'password': AccessKit.password,
          'clientKey': 'test',
        }),
      );
      final body = jsonDecode(
        await utf8.decodeStream(await request.close()),
      ) as Map<String, Object?>;
      return body['token']! as String;
    }

    Future<({int status, Map<String, Object?> body})> call(
      String method, {
      String? token,
      Object? body,
    }) async {
      final request = await client.openUrl(
        method,
        Uri.parse('http://127.0.0.1:${server.port}/api/v1/fee-codes'),
      );
      if (token != null) request.headers.set('authorization', 'Bearer $token');
      if (body != null) {
        request.headers.set('content-type', 'application/json');
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      final text = await utf8.decodeStream(response);
      return (
        status: response.statusCode,
        body: text.isEmpty
            ? <String, Object?>{}
            : jsonDecode(text) as Map<String, Object?>,
      );
    }

    test('should read nothing, save a list and read it back', () async {
      final token = await signIn();

      expect((await call('GET', token: token)).body['codes'], isEmpty);
      final saved = await call(
        'PUT',
        token: token,
        body: {
          'codes': [
            {'code': 'NEW', 'amountBdt': 500},
          ],
        },
      );
      final read = await call('GET', token: token);

      expect(saved.status, 200);
      expect(read.status, 200);
      final codes = read.body['codes']! as List;
      expect((codes.single as Map)['code'], 'NEW');
      expect((codes.single as Map)['amountBdt'], 500);
      expect((codes.single as Map)['id'], isNotEmpty);
    });

    test('should refuse a request without a sign-in', () async {
      expect((await call('GET')).status, 401);
      expect((await call('PUT', body: {'codes': []})).status, 401);
    });

    test('should name the problem with a bad list', () async {
      final token = await signIn();

      final result = await call(
        'PUT',
        token: token,
        body: {
          'codes': [
            {'code': 'A', 'amountBdt': 10},
            {'code': 'a', 'amountBdt': 20},
          ],
        },
      );

      expect(result.status, 400);
      expect((result.body['error']! as Map)['problem'], 'codeDuplicate');
    });
  });
}
