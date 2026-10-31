// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:algoritiq_app/api/local_api_server.dart';
import 'package:algoritiq_app/api/web_site.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';

/// A web build held in memory.
class _Files implements WebFiles {
  _Files(this.files);

  final Map<String, String> files;

  @override
  Future<Uint8List?> read(String path) async {
    final text = files[path];
    return text == null ? null : Uint8List.fromList(utf8.encode(text));
  }
}

void main() {
  final site = WebSite(
    _Files({
      'index.html': '<!doctype html><title>app</title>',
      'assets/index-abc.js': 'console.log(1)',
      'assets/index-abc.css': 'body{}',
      'favicon.svg': '<svg/>',
      'manifest.webmanifest': '{}',
      'sw.js': 'self',
      '.hidden': 'secret',
    }),
  );

  group('WebSite', () {
    test('should give the app for the home page', () async {
      final asset = (await site.find('/'))!;

      expect(utf8.decode(asset.bytes), contains('<title>app</title>'));
      expect(asset.contentType, 'text/html; charset=utf-8');
    });

    test('should give the app for a page route that has no file', () async {
      final asset = (await site.find('/register'))!;

      expect(utf8.decode(asset.bytes), contains('<title>app</title>'));
    });

    test('should serve a bundled file with its own type', () async {
      expect(
        (await site.find('/assets/index-abc.js'))!.contentType,
        'text/javascript; charset=utf-8',
      );
      expect(
        (await site.find('/assets/index-abc.css'))!.contentType,
        'text/css; charset=utf-8',
      );
      expect((await site.find('/favicon.svg'))!.contentType, 'image/svg+xml');
      expect(
        (await site.find('/manifest.webmanifest'))!.contentType,
        startsWith('application/manifest+json'),
      );
    });

    test('should say "not found" for a missing file, never the app', () async {
      expect(await site.find('/assets/missing.js'), isNull);
      expect(await site.find('/nothing.png'), isNull);
    });

    test('should keep hashed files forever and check the rest again', () async {
      expect(
        (await site.find('/assets/index-abc.js'))!.headers['cache-control'],
        'public, max-age=31536000, immutable',
      );
      expect((await site.find('/'))!.headers['cache-control'], 'no-cache');
      expect((await site.find('/sw.js'))!.headers['cache-control'], 'no-cache');
    });

    test('should protect the pages from other origins and framing', () async {
      final headers = (await site.find('/'))!.headers;

      expect(headers['content-security-policy'], contains("script-src 'self'"));
      expect(headers['content-security-policy'], contains("object-src 'none'"));
      expect(
        headers['content-security-policy'],
        contains("frame-ancestors 'none'"),
      );
      expect(headers['x-frame-options'], 'DENY');
      expect(headers['x-content-type-options'], 'nosniff');
      expect(headers['referrer-policy'], 'no-referrer');
    });

    test('should refuse paths that climb out of the web folder', () async {
      for (final path in [
        '/../secret',
        '/assets/../index.html',
        '/%2e%2e/secret',
        '/..%2fsecret',
        '/assets//x.js',
        r'/assets\x.js',
        '/.hidden',
      ]) {
        expect(await site.find(path), isNull, reason: path);
      }
    });

    test('should say "not found" when no web app is bundled', () async {
      expect(await WebSite(_Files({})).find('/'), isNull);
      expect(await WebSite(_Files({})).find('/register'), isNull);
    });
  });

  group('the server with a web app', () {
    late AccessKit kit;
    late LocalApiServer server;
    late HttpClient client;

    setUp(() async {
      kit = await AccessKit.create();
      server = LocalApiServer(access: () async => kit.service, web: site);
      await server.start(port: 0, address: InternetAddress.loopbackIPv4);
      client = HttpClient();
    });

    tearDown(() async {
      client.close(force: true);
      await server.stop();
      await kit.close();
    });

    Future<(HttpClientResponse, String)> request(
      String method,
      String path,
    ) async {
      final call = await client.openUrl(
        method,
        Uri.parse('http://127.0.0.1:${server.port}$path'),
      );
      final response = await call.close();
      return (response, await utf8.decodeStream(response));
    }

    test('should serve the app at the home address', () async {
      final (response, body) = await request('GET', '/');

      expect(response.statusCode, 200);
      expect(body, contains('<title>app</title>'));
      expect(response.headers.value('content-security-policy'), isNotNull);
    });

    test('should serve the app for /register so a reload works', () async {
      final (response, body) = await request('GET', '/register');

      expect(response.statusCode, 200);
      expect(body, contains('<title>app</title>'));
    });

    test('should serve a script and a stylesheet', () async {
      final (script, _) = await request('GET', '/assets/index-abc.js');
      final (style, _) = await request('GET', '/assets/index-abc.css');

      expect(script.headers.contentType?.mimeType, 'text/javascript');
      expect(style.headers.contentType?.mimeType, 'text/css');
    });

    test('should answer HEAD with the headers and no body', () async {
      final (response, body) = await request('HEAD', '/');

      expect(response.statusCode, 200);
      expect(response.contentLength, greaterThan(0));
      expect(body, isEmpty);
    });

    test('should not accept writes outside the API', () async {
      final (response, _) = await request('POST', '/');

      expect(response.statusCode, 405);
    });

    test('should answer a missing file with a plain not found', () async {
      final (response, body) = await request('GET', '/assets/gone.js');

      expect(response.statusCode, 404);
      expect(body, isNot(contains('<title>app</title>')));
    });

    test('should keep an unknown API path out of the app', () async {
      final (response, body) = await request('GET', '/api/v1/unknown');

      expect(response.statusCode, 404);
      expect(
        jsonDecode(body),
        containsPair('error', isA<Map<String, Object?>>()),
      );
    });

    test('should still serve the API next to the app', () async {
      final (response, body) = await request('GET', '/api/v1/health');

      expect(response.statusCode, 200);
      expect(jsonDecode(body), {'status': 'ok'});
      expect(response.headers.value('cache-control'), 'no-store');
    });
  });

  test('should show a plain page when no web app is bundled', () async {
    final kit = await AccessKit.create();
    final server = LocalApiServer(access: () async => kit.service);
    await server.start(port: 0, address: InternetAddress.loopbackIPv4);
    final client = HttpClient();
    addTearDown(() async {
      client.close(force: true);
      await server.stop();
      await kit.close();
    });

    final response = await (await client.getUrl(
      Uri.parse('http://127.0.0.1:${server.port}/'),
    )).close();

    expect(
      await utf8.decodeStream(response),
      contains('running on this tablet'),
    );
  });
}
