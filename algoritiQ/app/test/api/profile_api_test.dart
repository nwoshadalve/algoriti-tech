// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/api/cors_policy.dart';
import 'package:algoritiq_app/api/local_api_server.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';

const _jpeg = [0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3];

void main() {
  late AccessKit kit;
  late LocalApiServer server;
  late HttpClient client;
  late String token;

  Future<
    ({int status, Map<String, Object?> json, List<int> bytes, String? type})
  >
  call(
    String method,
    String path, {
    Map<String, Object?>? json,
    List<int>? bytes,
    String? contentType,
    String? bearer,
  }) async {
    final request = await client.openUrl(
      method,
      Uri.parse('http://127.0.0.1:${server.port}$path'),
    );
    final who = bearer ?? (path.contains('/auth/') ? null : token);
    if (who != null) request.headers.set('authorization', 'Bearer $who');
    if (json != null) {
      request.headers.set('content-type', 'application/json');
      request.write(jsonEncode(json));
    } else if (bytes != null) {
      request.headers.set('content-type', contentType ?? 'image/jpeg');
      request.add(bytes);
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
    kit = await AccessKit.create();
    server = LocalApiServer(
      access: () async => kit.service,
      corsPolicy: CorsPolicy.reflectOrigin,
    );
    await server.start(port: 0, address: InternetAddress.loopbackIPv4);
    client = HttpClient();
    await kit.registerAdmin();
    final login = await call(
      'POST',
      '/api/v1/auth/login',
      json: {'username': 'owner', 'password': AccessKit.password},
    );
    token = login.json['token']! as String;
  });

  tearDown(() async {
    client.close(force: true);
    await server.stop();
    await kit.close();
  });

  Map<String, Object?> profile({
    String first = 'Rafi',
    String email = 'rafi@clinic.test',
  }) => {
    'firstName': first,
    'lastName': 'Ahmed',
    'email': email,
    'phone': '01711000000',
  };

  Map<String, Object?> account(Map<String, Object?> json) =>
      json['account']! as Map<String, Object?>;

  group('the profile', () {
    test('should show the name parts and no photo yet', () async {
      final me = await call('GET', '/api/v1/me');

      expect(account(me.json)['firstName'], 'The');
      expect(account(me.json)['lastName'], 'Owner');
      expect(account(me.json)['phone'], '');
      expect(account(me.json)['photoVersion'], 0);
    });

    test('should be changed with PATCH', () async {
      final result = await call('PATCH', '/api/v1/me', json: profile());

      expect(result.status, 200);
      expect(account(result.json)['displayName'], 'Rafi Ahmed');
      expect(account(result.json)['phone'], '01711000000');
      final me = await call('GET', '/api/v1/me');
      expect(account(me.json)['email'], 'rafi@clinic.test');
    });

    test('should need a sign-in', () async {
      final result = await call(
        'PATCH',
        '/api/v1/me',
        json: profile(),
        bearer: 'made-up',
      );

      expect(result.status, 401);
    });

    test('should refuse a bad email with 400', () async {
      final result = await call(
        'PATCH',
        '/api/v1/me',
        json: profile(email: 'x'),
      );

      expect(result.status, 400);
      expect((result.json['error']! as Map)['code'], 'email_invalid');
    });

    test('should refuse a missing first name with 400', () async {
      final result = await call(
        'PATCH',
        '/api/v1/me',
        json: profile(first: ' '),
      );

      expect((result.json['error']! as Map)['code'], 'first_name_missing');
    });

    test('should allow the CORS preflight for PATCH, PUT and DELETE', () async {
      final request = await client.openUrl(
        'OPTIONS',
        Uri.parse('http://127.0.0.1:${server.port}/api/v1/me'),
      );
      request.headers
        ..set('origin', 'http://laptop.test')
        ..set('access-control-request-method', 'PATCH');
      final response = await request.close();
      await response.drain<void>();

      final methods = response.headers.value('access-control-allow-methods');
      expect(
        methods,
        allOf(contains('PATCH'), contains('PUT'), contains('DELETE')),
      );
    });
  });

  group('the photo', () {
    test('should be 404 before one is uploaded', () async {
      expect((await call('GET', '/api/v1/me/photo')).status, 404);
    });

    test('should be stored, served back and show in the account', () async {
      final put = await call('PUT', '/api/v1/me/photo', bytes: _jpeg);

      expect(put.status, 200);
      expect(account(put.json)['photoVersion'], greaterThan(0));
      final get = await call('GET', '/api/v1/me/photo');
      expect(get.status, 200);
      expect(get.type, 'image/jpeg');
      expect(get.bytes, _jpeg);
    });

    test('should refuse a file that is not a picture', () async {
      final put = await call('PUT', '/api/v1/me/photo', bytes: [1, 2, 3]);

      expect(put.status, 415);
    });

    test('should refuse one that is too big', () async {
      // The server may drop the connection while the upload is still going,
      // so a client sees either the 413 or a closed connection; never a save.
      try {
        final put = await call(
          'PUT',
          '/api/v1/me/photo',
          bytes: [..._jpeg, ...List.filled(600 * 1024, 0)],
        );
        expect(put.status, 413);
      } on HttpException {
        // Closed early: also a refusal.
      }

      expect((await call('GET', '/api/v1/me/photo')).status, 404);
    });

    test('should be removed with DELETE', () async {
      await call('PUT', '/api/v1/me/photo', bytes: _jpeg);

      final del = await call('DELETE', '/api/v1/me/photo');

      expect(del.status, 200);
      expect(account(del.json)['photoVersion'], 0);
      expect((await call('GET', '/api/v1/me/photo')).status, 404);
    });

    test('should need a sign-in', () async {
      expect(
        (await call('GET', '/api/v1/me/photo', bearer: 'nope')).status,
        401,
      );
      expect(
        (await call(
          'PUT',
          '/api/v1/me/photo',
          bytes: _jpeg,
          bearer: 'nope',
        )).status,
        401,
      );
    });
  });

  group('changing the password', () {
    Future<
      ({int status, Map<String, Object?> json, List<int> bytes, String? type})
    >
    change(String current, String next, {String? bearer}) => call(
      'POST',
      '/api/v1/me/password',
      json: {'currentPassword': current, 'newPassword': next},
      bearer: bearer,
    );

    test('should answer 204 and use the new password from then on', () async {
      final result = await change(AccessKit.password, 'a-better-passphrase');

      expect(result.status, 204);
      final login = await call(
        'POST',
        '/api/v1/auth/login',
        json: {'username': 'owner', 'password': 'a-better-passphrase'},
      );
      expect(login.status, 200);
      // This sign-in stays valid.
      expect((await call('GET', '/api/v1/me')).status, 200);
    });

    test('should answer 403 for a wrong current password', () async {
      final result = await change('not-it-at-all', 'a-better-passphrase');

      expect(result.status, 403);
      expect((result.json['error']! as Map)['code'], 'current_password_wrong');
    });

    test('should answer 400 for a weak or unchanged password', () async {
      final weak = await change(AccessKit.password, 'short');
      final same = await change(AccessKit.password, AccessKit.password);

      expect((weak.json['error']! as Map)['code'], 'password_too_short');
      expect((same.json['error']! as Map)['code'], 'password_unchanged');
    });

    test('should answer 429 after repeated wrong passwords', () async {
      late int last;
      for (var i = 0; i < 6; i++) {
        last = (await change('wrong-guess-$i', 'a-better-passphrase')).status;
      }

      expect(last, 429);
    });

    test('should need a sign-in', () async {
      final result = await change(
        AccessKit.password,
        'a-better-passphrase',
        bearer: 'made-up',
      );

      expect(result.status, 401);
    });
  });
}
