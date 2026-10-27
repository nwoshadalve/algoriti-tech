import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/api/local_api_server.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';

void main() {
  late AccessKit kit;
  late LocalApiServer server;
  late HttpClient client;

  setUp(() async {
    kit = await AccessKit.create();
    server = LocalApiServer(access: () async => kit.service);
    // Plain HTTP on a free local port: HTTPS itself is tested separately.
    await server.start(port: 0, address: InternetAddress.loopbackIPv4);
    client = HttpClient();
  });

  tearDown(() async {
    client.close(force: true);
    await server.stop();
    await kit.close();
  });

  Future<({int status, Map<String, Object?> body, HttpClientResponse raw})>
  call(
    String method,
    String path, {
    Map<String, Object?>? json,
    String? token,
    String? rawBody,
    String contentType = 'application/json',
    Map<String, String> headers = const {},
  }) async {
    final request = await client.openUrl(
      method,
      Uri.parse('http://127.0.0.1:${server.port}$path'),
    );
    if (token != null) request.headers.set('authorization', 'Bearer $token');
    headers.forEach(request.headers.set);
    if (json != null || rawBody != null) {
      request.headers.set('content-type', contentType);
      request.write(rawBody ?? jsonEncode(json));
    }
    final response = await request.close();
    final text = await utf8.decodeStream(response);
    Map<String, Object?> body = {};
    if (text.isNotEmpty && response.headers.contentType?.subType == 'json') {
      body = jsonDecode(text) as Map<String, Object?>;
    }
    return (status: response.statusCode, body: body, raw: response);
  }

  Map<String, Object?> register({
    String? code,
    String password = AccessKit.password,
  }) => {
    'claimCode': code ?? kit.claimCodes.current().code,
    'username': 'owner',
    'displayName': 'The Owner',
    'password': password,
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

  test('should report it is healthy', () async {
    final result = await call('GET', '/api/v1/health');

    expect(result.status, 200);
    expect(result.body, {'status': 'ok'});
  });

  group('setup status', () {
    test('should say a claim code is needed before the first admin', () async {
      final result = await call('GET', '/api/v1/setup/status');

      expect(result.body, {
        'adminRegistered': false,
        'claimCodeRequired': true,
      });
    });

    test('should say no code is needed once an admin exists', () async {
      await call('POST', '/api/v1/setup/admin', json: register());

      final result = await call('GET', '/api/v1/setup/status');

      expect(result.body, {
        'adminRegistered': true,
        'claimCodeRequired': false,
      });
    });

    test('should never reveal the claim code', () async {
      final code = kit.claimCodes.current().code;

      final result = await call('GET', '/api/v1/setup/status');

      expect(jsonEncode(result.body), isNot(contains(code)));
    });
  });

  group('registering the admin', () {
    test('should register with the claim code from the tablet', () async {
      final result = await call(
        'POST',
        '/api/v1/setup/admin',
        json: register(),
      );

      expect(result.status, 201);
      final account = result.body['account']! as Map;
      expect(account['username'], 'owner');
      expect(account['role'], 'admin');
      expect(account.containsKey('password'), isFalse);
    });

    test(
      'should refuse a wrong claim code with 403 and the tries left',
      () async {
        kit.claimCodes.current();

        final result = await call(
          'POST',
          '/api/v1/setup/admin',
          json: register(code: 'WRONG123'),
        );

        expect(result.status, 403);
        final error = result.body['error']! as Map;
        expect(error['code'], 'claim_code_invalid');
        expect(error['attemptsLeft'], 4);
      },
    );

    test('should lock the code after five wrong tries', () async {
      kit.claimCodes.current();
      late Map<String, Object?> last;
      for (var i = 0; i < 5; i++) {
        last = (await call(
          'POST',
          '/api/v1/setup/admin',
          json: register(code: 'WRONG123'),
        )).body;
      }

      expect((last['error']! as Map)['code'], 'claim_code_locked');
    });

    test('should close registration after the first admin with 409', () async {
      await call('POST', '/api/v1/setup/admin', json: register());

      final result = await call(
        'POST',
        '/api/v1/setup/admin',
        json: register(),
      );

      expect(result.status, 409);
      expect(
        (result.body['error']! as Map)['code'],
        'admin_already_registered',
      );
    });

    test('should say what is wrong with a weak password', () async {
      final result = await call(
        'POST',
        '/api/v1/setup/admin',
        json: register(password: 'short'),
      );

      expect(result.status, 400);
      expect((result.body['error']! as Map)['code'], 'password_too_short');
    });

    test('should refuse a body that is not the expected JSON', () async {
      for (final body in ['not json', '[]', '{"claimCode": 1}']) {
        final result = await call('POST', '/api/v1/setup/admin', rawBody: body);
        expect(result.status, 400, reason: body);
      }
    });

    test('should refuse a body that is not JSON content', () async {
      final result = await call(
        'POST',
        '/api/v1/setup/admin',
        rawBody: 'x=1',
        contentType: 'text/plain',
      );

      expect(result.status, 415);
    });

    test('should refuse an oversized body', () async {
      // The server may answer 413 or simply close the connection; either way
      // nothing is registered and it keeps running.
      try {
        final result = await call(
          'POST',
          '/api/v1/setup/admin',
          rawBody: jsonEncode({'claimCode': 'x' * 20000}),
        );
        expect(result.status, 413);
      } on HttpException {
        // Connection closed by the server.
      }

      expect((await call('GET', '/api/v1/health')).status, 200);
      expect(await kit.service.hasAdmin, isFalse);
    });
  });

  group('signing in', () {
    test('should return a token and the account', () async {
      await call('POST', '/api/v1/setup/admin', json: register());

      final result = await call(
        'POST',
        '/api/v1/auth/login',
        json: {'username': 'owner', 'password': AccessKit.password},
      );

      expect(result.status, 200);
      expect(result.body['token'], isA<String>());
      expect(result.body['expiresAt'], isA<String>());
      expect((result.body['account']! as Map)['username'], 'owner');
    });

    test('should answer 401 for a wrong password', () async {
      await call('POST', '/api/v1/setup/admin', json: register());

      final result = await call(
        'POST',
        '/api/v1/auth/login',
        json: {'username': 'owner', 'password': 'nope-nope-nope'},
      );

      expect(result.status, 401);
      expect((result.body['error']! as Map)['code'], 'invalid_credentials');
    });

    test(
      'should answer 429 with Retry-After after repeated failures',
      () async {
        await call('POST', '/api/v1/setup/admin', json: register());
        late ({int status, Map<String, Object?> body, HttpClientResponse raw})
        last;
        for (var i = 0; i < 6; i++) {
          last = await call(
            'POST',
            '/api/v1/auth/login',
            json: {'username': 'owner', 'password': 'nope-nope-$i'},
          );
        }

        expect(last.status, 429);
        expect(last.raw.headers.value('retry-after'), isNotNull);
      },
    );

    test('should show who is signed in, and refuse without a token', () async {
      final token = await signIn();

      final me = await call('GET', '/api/v1/me', token: token);
      final anonymous = await call('GET', '/api/v1/me');
      final bogus = await call('GET', '/api/v1/me', token: 'made-up');

      expect(me.status, 200);
      expect((me.body['account']! as Map)['username'], 'owner');
      expect(anonymous.status, 401);
      expect(bogus.status, 401);
    });

    test('should end the session on logout', () async {
      final token = await signIn();

      final out = await call('POST', '/api/v1/auth/logout', token: token);
      final after = await call('GET', '/api/v1/me', token: token);

      expect(out.status, 204);
      expect(after.status, 401);
    });
  });

  group('every response', () {
    test('should not be cached and should not be sniffed', () async {
      final result = await call('GET', '/api/v1/health');

      expect(result.raw.headers.value('cache-control'), 'no-store');
      expect(result.raw.headers.value('x-content-type-options'), 'nosniff');
    });

    test('should answer a browser preflight for the web app', () async {
      final result = await call(
        'OPTIONS',
        '/api/v1/auth/login',
        headers: {'origin': 'http://localhost:5173'},
      );

      expect(result.status, 204);
      expect(
        result.raw.headers.value('access-control-allow-origin'),
        'http://localhost:5173',
      );
      expect(
        result.raw.headers.value('access-control-allow-headers'),
        contains('authorization'),
      );
    });

    test(
      'should answer 404 for unknown paths and 405 for the wrong method',
      () async {
        expect((await call('GET', '/api/v1/nothing')).status, 404);
        expect((await call('GET', '/api/v1/auth/login')).status, 405);
      },
    );

    test('should never leak internals when something breaks', () async {
      server = LocalApiServer(
        access: () async => throw StateError('db path /secret'),
      );
      await server.start(port: 0, address: InternetAddress.loopbackIPv4);

      final result = await call('GET', '/api/v1/setup/status');

      expect(result.status, 500);
      expect(jsonEncode(result.body), isNot(contains('secret')));
    });
  });
}
