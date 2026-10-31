// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/api/local_api_server.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';

typedef Reply = ({int status, Map<String, Object?> json});

const _pin = '482913';

void main() {
  late AccessKit kit;
  late LocalApiServer server;
  late HttpClient client;
  late String token;

  Future<Reply> call(
    String method,
    String path, {
    Map<String, Object?>? json,
    String? bearer,
    bool anonymous = false,
  }) async {
    final request = await client.openUrl(
      method,
      Uri.parse('http://127.0.0.1:${server.port}$path'),
    );
    final who = anonymous ? null : (bearer ?? token);
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

  Future<Reply> login({bool remember = false}) => call(
    'POST',
    '/api/v1/auth/login',
    anonymous: true,
    json: {
      'username': 'owner',
      'password': AccessKit.password,
      if (remember) 'remember': true,
    },
  );

  setUp(() async {
    kit = await AccessKit.create();
    server = LocalApiServer(access: () async => kit.service);
    await server.start(port: 0, address: InternetAddress.loopbackIPv4);
    client = HttpClient();
    await kit.registerAdmin();
    token = (await login()).json['token']! as String;
  });

  tearDown(() async {
    client.close(force: true);
    await server.stop();
    await kit.close();
  });

  Future<Reply> setPin({
    String password = AccessKit.password,
    String pin = _pin,
    String? replace,
  }) => call(
    'POST',
    '/api/v1/me/pin',
    json: {
      'password': password,
      'pin': pin,
      'label': 'Laptop',
      if (replace != null) 'replaceDeviceId': replace,
    },
  );

  Future<Reply> pinLogin(String deviceToken, String pin) => call(
    'POST',
    '/api/v1/auth/pin/login',
    anonymous: true,
    json: {'deviceToken': deviceToken, 'pin': pin},
  );

  String code(Reply r) => (r.json['error']! as Map)['code'] as String;

  group('remember', () {
    test(
      'should give a remembered sign-in thirty days and others twelve hours',
      () async {
        final short = await login();
        final long = await login(remember: true);

        Duration lifetime(Reply r) =>
            DateTime.parse(r.json['expiresAt']! as String)
                .difference(kit.clock.now);
        expect(lifetime(short), const Duration(hours: 12));
        expect(lifetime(long), const Duration(days: 30));
      },
    );
  });

  group('setting a PIN', () {
    test('should answer 201 with the secret and list the browser', () async {
      final result = await setPin();
      final list = await call('GET', '/api/v1/me/pin');

      expect(result.status, 201);
      expect(result.json['deviceToken'], isA<String>());
      expect((result.json['device']! as Map)['label'], 'Laptop');
      final devices = list.json['devices']! as List;
      expect(devices, hasLength(1));
      // The secret is never listed again.
      expect((devices.single as Map).containsKey('deviceToken'), isFalse);
    });

    test('should need the password: 403', () async {
      final result = await setPin(password: 'not-the-password');

      expect(result.status, 403);
      expect(code(result), 'current_password_wrong');
    });

    test('should refuse a weak or malformed PIN with 400', () async {
      expect(code(await setPin(pin: '123456')), 'pin_too_easy');
      expect(code(await setPin(pin: '111111')), 'pin_too_easy');
      expect(code(await setPin(pin: '12ab56')), 'pin_invalid');
      expect(code(await setPin(pin: '123')), 'pin_invalid');
    });

    test('should answer 429 after repeated wrong passwords', () async {
      late int last;
      for (var i = 0; i < 6; i++) {
        last = (await setPin(password: 'wrong-guess-$i')).status;
      }

      expect(last, 429);
    });

    test('should need a sign-in', () async {
      expect(
        (await call('GET', '/api/v1/me/pin', bearer: 'made-up')).status,
        401,
      );
      expect(
        (await setPin().then(
          (_) => call('POST', '/api/v1/me/pin', anonymous: true, json: {}),
        )).status,
        401,
      );
    });
  });

  group('signing in with a PIN', () {
    test('should return a session for the right PIN', () async {
      final device = (await setPin()).json['deviceToken']! as String;

      final result = await pinLogin(device, _pin);

      expect(result.status, 200);
      final session = result.json['token']! as String;
      final me = await call('GET', '/api/v1/me', bearer: session);
      expect(me.status, 200);
      expect((me.json['account']! as Map)['username'], 'owner');
    });

    test('should say how many tries are left after a wrong PIN: 401', () async {
      final device = (await setPin()).json['deviceToken']! as String;

      final result = await pinLogin(device, '000111');

      expect(result.status, 401);
      expect(code(result), 'invalid_pin');
      expect((result.json['error']! as Map)['attemptsLeft'], 2);
    });

    test(
      'should lock after three wrong PINs: 403, then 401 for everything',
      () async {
        final device = (await setPin()).json['deviceToken']! as String;
        late Reply last;
        for (var i = 0; i < 3; i++) {
          last = await pinLogin(device, '00011$i');
        }

        expect(last.status, 403);
        expect(code(last), 'pin_locked');
        final right = await pinLogin(device, _pin);
        expect(right.status, 401);
        expect(code(right), 'pin_unavailable');
      },
    );

    test('should answer 401 pin_unavailable for an unknown secret', () async {
      final result = await pinLogin('made-up-secret', _pin);

      expect(result.status, 401);
      expect(code(result), 'pin_unavailable');
    });

    test('should end when the password is changed', () async {
      final device = (await setPin()).json['deviceToken']! as String;

      await call(
        'POST',
        '/api/v1/me/password',
        json: {
          'currentPassword': AccessKit.password,
          'newPassword': 'a-better-passphrase',
        },
      );

      expect(code(await pinLogin(device, _pin)), 'pin_unavailable');
    });
  });

  group('removing a PIN', () {
    test('should remove it with DELETE and 404 the second time', () async {
      final set = await setPin();
      final id = (set.json['device']! as Map)['id'] as String;

      final first = await call('DELETE', '/api/v1/me/pin/$id');
      final second = await call('DELETE', '/api/v1/me/pin/$id');

      expect(first.status, 204);
      expect(second.status, 404);
      expect(
        code(await pinLogin(set.json['deviceToken']! as String, _pin)),
        'pin_unavailable',
      );
    });

    test('should replace this browser’s PIN', () async {
      final old = await setPin();
      final id = (old.json['device']! as Map)['id'] as String;

      await setPin(pin: '902417', replace: id);

      expect(
        ((await call('GET', '/api/v1/me/pin')).json['devices']! as List),
        hasLength(1),
      );
    });

    test('should not touch another person’s browser', () async {
      final set = await setPin();
      final id = (set.json['device']! as Map)['id'] as String;
      // A second admin cannot be made through this server, so use a made-up token.
      final result = await call(
        'DELETE',
        '/api/v1/me/pin/$id',
        bearer: 'made-up',
      );

      expect(result.status, 401);
      expect(
        ((await call('GET', '/api/v1/me/pin')).json['devices']! as List),
        hasLength(1),
      );
    });
  });
}
