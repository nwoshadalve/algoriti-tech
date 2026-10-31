// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/api/cors_policy.dart';
import 'package:algoritiq_app/api/local_api_server.dart';
import 'package:algoritiq_app/api/live_api_web_socket.dart';
import 'package:algoritiq_app/features/monitoring/application/monitoring_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';
import '../support/readiness_kit.dart';
import '../support/system_health_fake.dart';

import 'package:algoritiq_app/platform/system_health_gateway.dart';

void main() {
  late AccessKit kit;
  late LocalApiServer server;
  late HttpClient client;
  late FakeSystemHealth health;

  setUp(() async {
    kit = await AccessKit.create();
    health = FakeSystemHealth();
    server = LocalApiServer(
      access: () async => kit.service,
      monitoring: MonitoringService(
        health: health,
        keepAlive: FakeKeepAliveGateway(),
        clock: DateTime.now,
        retryDelay: const Duration(milliseconds: 50),
      ),
      corsPolicy: CorsPolicy.reflectOrigin,
    );
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
    'firstName': 'The',
    'lastName': 'Owner',
    'email': 'owner@clinic.test',
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

  group('monitoring', () {
    test('should need a sign-in', () async {
      final result = await call('GET', '/api/v1/monitoring');

      expect(result.status, 401);
    });

    test('should report resources and every service to an admin', () async {
      final token = await signIn();

      final result = await call('GET', '/api/v1/monitoring', token: token);

      expect(result.status, 200);
      final resources = result.body['resources']! as Map<String, Object?>;
      expect(resources.keys, ['cpu', 'ram', 'storage', 'bluetooth']);
      final services = (result.body['services']! as List).cast<Map>();
      expect(services.map((s) => s['id']), [
        'api',
        'websocket',
        'androidService',
        'printer',
        'tv',
      ]);
      final printer = services.firstWhere((s) => s['id'] == 'printer');
      expect(printer['status'], 'unavailable');
      expect(printer['reason'], 'printer_not_set_up');
      expect(printer['retryable'], isTrue);
      expect(result.body['deviceUptimeSeconds'], 18000);
    });

    test(
      'should show the retry progress after asking to retry the TV app',
      () async {
        final token = await signIn();

        final result = await call(
          'POST',
          '/api/v1/monitoring/services/tv/retry',
          token: token,
        );

        expect(result.status, 202);
        final services = (result.body['services']! as List).cast<Map>();
        final tv = services.firstWhere((s) => s['id'] == 'tv');
        expect(tv['status'], 'retrying');
        expect(tv['retry'], {'attempt': 1, 'max': 3});
      },
    );

    test('should turn Bluetooth on for an admin', () async {
      health.bluetooth = BluetoothState.off;
      final token = await signIn();

      final result = await call(
        'POST',
        '/api/v1/monitoring/bluetooth/enable',
        token: token,
      );

      expect(result.status, 200);
      expect(result.body['outcome'], 'dialog_shown');
      final bluetooth = (result.body['resources']! as Map)['bluetooth']! as Map;
      expect(bluetooth['detail'], 'on');
    });

    test('should refuse to retry the API and an unknown service', () async {
      final token = await signIn();

      final api = await call(
        'POST',
        '/api/v1/monitoring/services/api/retry',
        token: token,
      );
      final unknown = await call(
        'POST',
        '/api/v1/monitoring/services/toaster/retry',
        token: token,
      );

      expect(api.status, 409);
      expect(unknown.status, 404);
    });
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

  group('verifying the claim code', () {
    test('should accept the code from the tablet without using it', () async {
      final code = kit.claimCodes.current().code;

      final result = await call(
        'POST',
        '/api/v1/setup/claim/verify',
        json: {'claimCode': code},
      );

      expect(result.status, 200);
      expect(result.body, {'valid': true});
    });

    test('should still register after a successful verify', () async {
      final code = kit.claimCodes.current().code;
      await call(
        'POST',
        '/api/v1/setup/claim/verify',
        json: {'claimCode': code},
      );

      final result = await call(
        'POST',
        '/api/v1/setup/admin',
        json: register(),
      );

      expect(result.status, 201);
    });

    test('should refuse a wrong code with 403 and the tries left', () async {
      kit.claimCodes.current();

      final result = await call(
        'POST',
        '/api/v1/setup/claim/verify',
        json: {'claimCode': 'WRONG123'},
      );

      expect(result.status, 403);
      final error = result.body['error']! as Map;
      expect(error['code'], 'claim_code_invalid');
      expect(error['attemptsLeft'], 4);
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

  group('resetting a forgotten password', () {
    const start = '/api/v1/auth/password/reset/start';
    const finish = '/api/v1/auth/password/reset';
    const newPassword = 'a-brand-new-passphrase';

    Map<String, Object?> startBody({String key = AccessKit.activationKey}) => {
      'username': 'owner',
      'activationKey': key,
    };

    Future<String> ticket() async {
      final result = await call('POST', start, json: startBody());
      return result.body['resetToken']! as String;
    }

    setUp(() async {
      await call('POST', '/api/v1/setup/admin', json: register());
    });

    test('should give a ticket for the right key', () async {
      final result = await call('POST', start, json: startBody());

      expect(result.status, 200);
      expect(result.body['resetToken'], isA<String>());
      expect(result.body['expiresAt'], isA<String>());
    });

    test('should set the new password and end old sign-ins', () async {
      final old =
          (await call(
                'POST',
                '/api/v1/auth/login',
                json: {'username': 'owner', 'password': AccessKit.password},
              )).body['token']!
              as String;

      final result = await call(
        'POST',
        finish,
        json: {'resetToken': await ticket(), 'newPassword': newPassword},
      );

      expect(result.status, 204);
      expect((await call('GET', '/api/v1/me', token: old)).status, 401);
      final login = await call(
        'POST',
        '/api/v1/auth/login',
        json: {'username': 'owner', 'password': newPassword},
      );
      expect(login.status, 200);
    });

    test('should refuse a wrong key without saying more', () async {
      final result = await call('POST', start, json: startBody(key: 'WRONG'));

      expect(result.status, 403);
      expect((result.body['error']! as Map)['code'], 'reset_refused');
      expect(result.body.containsKey('resetToken'), isFalse);
    });

    test('should refuse an unknown username the same way', () async {
      final result = await call(
        'POST',
        start,
        json: {'username': 'nobody', 'activationKey': AccessKit.activationKey},
      );

      expect(result.status, 403);
      expect((result.body['error']! as Map)['code'], 'reset_refused');
    });

    test('should refuse a ticket nobody issued', () async {
      final result = await call(
        'POST',
        finish,
        json: {'resetToken': 'made-up', 'newPassword': newPassword},
      );

      expect(result.status, 403);
      expect((result.body['error']! as Map)['code'], 'reset_token_invalid');
    });

    test('should accept a ticket only once', () async {
      final t = await ticket();
      await call(
        'POST',
        finish,
        json: {'resetToken': t, 'newPassword': newPassword},
      );

      final again = await call(
        'POST',
        finish,
        json: {'resetToken': t, 'newPassword': 'another-passphrase-1'},
      );

      expect(again.status, 403);
    });

    test('should refuse a weak new password with the reason', () async {
      final result = await call(
        'POST',
        finish,
        json: {'resetToken': await ticket(), 'newPassword': 'short'},
      );

      expect(result.status, 400);
      expect((result.body['error']! as Map)['code'], 'password_too_short');
    });

    test('should slow down guessing keys with a wait time', () async {
      for (var i = 0; i < 5; i++) {
        await call('POST', start, json: startBody(key: 'guess$i'));
      }

      final result = await call('POST', start, json: startBody());

      expect(result.status, 429);
      expect(result.raw.headers.value('retry-after'), isNotNull);
    });

    test('should insist on JSON and the right method', () async {
      for (final path in [start, finish]) {
        expect(
          (await call(
            'POST',
            path,
            rawBody: 'x',
            contentType: 'text/plain',
          )).status,
          415,
        );
        expect((await call('GET', path)).status, 405);
      }
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
      expect(result.raw.headers.value('access-control-allow-origin'), 'http://localhost:5173');
      expect(result.raw.headers.value('vary'), 'Origin');
      expect(
        result.raw.headers.value('access-control-allow-headers'),
        contains('authorization'),
      );
    });

    test(
      'should answer private-network preflights for queue and chamber routes',
      () async {
        await server.stop();
        server = LocalApiServer(
          access: () async => kit.service,
          corsPolicy: CorsPolicy.allowAnyOrigin,
        );
        await server.start(port: 0, address: InternetAddress.loopbackIPv4);

        for (final path in [
          '/api/v1/queue/chambers/902abfb3-fcb0-47ca-9315-b37b2e15b955',
          '/api/v1/chambers',
        ]) {
          final result = await call(
            'OPTIONS',
            path,
            headers: {
              'origin': 'http://localhost:5173',
              'access-control-request-private-network': 'true',
              'access-control-request-method': 'GET',
            },
          );

          expect(result.status, 204);
          expect(result.raw.headers.value('access-control-allow-origin'), 'http://localhost:5173');
          expect(result.raw.headers.value('access-control-allow-private-network'), 'true');
        }
      },
    );

    test('should reflect the origin on GET for queue defaults in debug CORS mode', () async {
      await server.stop();
      server = LocalApiServer(
        access: () async => kit.service,
        corsPolicy: CorsPolicy.allowAnyOrigin,
      );
      await server.start(port: 0, address: InternetAddress.loopbackIPv4);

      final result = await call(
        'GET',
        '/api/v1/queue/defaults',
        headers: {
          'origin': 'http://192.168.0.20:5173',
          'authorization': 'Bearer fake',
        },
      );

      expect(result.raw.headers.value('access-control-allow-origin'), 'http://192.168.0.20:5173');
      expect(result.raw.headers.value('access-control-allow-private-network'), 'true');
    });

    test('should reflect any origin on preflight in debug CORS mode', () async {
      await server.stop();
      server = LocalApiServer(
        access: () async => kit.service,
        corsPolicy: CorsPolicy.allowAnyOrigin,
      );
      await server.start(port: 0, address: InternetAddress.loopbackIPv4);

      final result = await call(
        'OPTIONS',
        '/api/v1/auth/login',
        headers: {'origin': 'http://localhost:5173'},
      );

      expect(result.status, 204);
      expect(result.raw.headers.value('access-control-allow-origin'), 'http://localhost:5173');
      expect(result.raw.headers.value('vary'), 'Origin');
    });

    test('should reflect a non-local origin on preflight in debug CORS mode', () async {
      await server.stop();
      server = LocalApiServer(
        access: () async => kit.service,
        corsPolicy: CorsPolicy.allowAnyOrigin,
      );
      await server.start(port: 0, address: InternetAddress.loopbackIPv4);

      final result = await call(
        'OPTIONS',
        '/api/v1/auth/login',
        headers: {'origin': 'https://other.example'},
      );

      expect(result.status, 204);
      expect(result.raw.headers.value('access-control-allow-origin'), 'https://other.example');
      expect(result.raw.headers.value('vary'), 'Origin');
      expect(result.raw.headers.value('access-control-allow-private-network'), 'true');
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

  group('live websocket', () {
    test('should refuse a connection without a token', () async {
      expect(
        WebSocket.connect(
          'ws://127.0.0.1:${server.port}${LiveApiWebSocket.path}',
        ),
        throwsA(isA<WebSocketException>()),
      );
    });

    test('should send hello and snapshot after sign-in', () async {
      final token = await signIn();
      final socket = await WebSocket.connect(
        'ws://127.0.0.1:${server.port}${LiveApiWebSocket.path}?token=$token',
      );
      addTearDown(socket.close);

      final frames = <String>[];
      final done = Completer<void>();
      late final StreamSubscription<dynamic> sub;
      sub = socket.listen((event) {
        frames.add(event as String);
        if (frames.length >= 2) {
          unawaited(sub.cancel());
          done.complete();
        }
      });
      await done.future.timeout(const Duration(seconds: 2));

      expect(frames[0], contains('"type":"hello"'));
      expect(frames[1], contains('"type":"snapshot"'));
    });

    test('should deliver published events to the client', () async {
      final token = await signIn();
      final socket = await WebSocket.connect(
        'ws://127.0.0.1:${server.port}${LiveApiWebSocket.path}?token=$token',
      );
      addTearDown(socket.close);

      final frames = <String>[];
      final eventSeen = Completer<void>();
      late final StreamSubscription<dynamic> sub;
      sub = socket.listen((event) {
        final line = event as String;
        frames.add(line);
        if (line.contains('"name":"server.test"')) {
          unawaited(sub.cancel());
          eventSeen.complete();
        }
      });
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      server.liveEvents.publish('server.test', {'ok': true});

      await eventSeen.future.timeout(const Duration(seconds: 2));
      expect(frames.any((line) => line.contains('"type":"event"')), isTrue);
    });
  });
}
