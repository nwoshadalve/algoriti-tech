// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/api/live_event_bus.dart';
import 'package:algoritiq_app/api/local_api_server.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/access_kit.dart';

void main() {
  late AccessKit kit;
  late LiveEventBus bus;
  late LocalApiServer server;
  late HttpClient client;

  setUp(() async {
    kit = await AccessKit.create();
    bus = LiveEventBus();
    server = LocalApiServer(access: () async => kit.service, liveEvents: bus);
    await server.start(port: 0, address: InternetAddress.loopbackIPv4);
    client = HttpClient();
  });

  tearDown(() async {
    client.close(force: true);
    await server.stop();
  });

  test('should serve the test sound to the TV', () async {
    final request = await client.getUrl(
      Uri.parse('http://127.0.0.1:${server.port}/api/v1/tv/test-announcement'),
    );
    final response = await request.close();
    final bytes = await response.fold<List<int>>([], (a, b) => a..addAll(b));

    expect(response.statusCode, 200);
    expect(response.headers.contentType?.mimeType, 'audio/wav');
    expect(utf8.decode(bytes.sublist(0, 4)), 'RIFF');
  });

  test('should let a TV connect to its channel and count it', () async {
    final socket = await WebSocket.connect(
      'ws://127.0.0.1:${server.port}/api/v1/ws/tv',
    );
    final hello = jsonDecode(await socket.first as String) as Map;
    expect(hello['type'], 'hello');
    expect(bus.tvPresence('any-chamber'), isNotNull);

    await socket.close();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(bus.tvPresence('any-chamber'), isNull);
  });

  test('should not let the TV channel be taken for the staff one', () async {
    await expectLater(
      WebSocket.connect('ws://127.0.0.1:${server.port}/api/v1/ws/live'),
      throwsA(isA<WebSocketException>()),
    );
  });

  test('should not offer compression, which the TV client refuses', () async {
    final socket = await Socket.connect('127.0.0.1', server.port);
    socket.write(
      'GET /api/v1/ws/tv HTTP/1.1\r\nHost: x\r\nConnection: Upgrade\r\n'
      'Upgrade: websocket\r\nSec-WebSocket-Version: 13\r\n'
      'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n'
      'Sec-WebSocket-Extensions: permessage-deflate\r\n\r\n',
    );
    final head = utf8.decode(await socket.first);
    socket.destroy();

    expect(head, startsWith('HTTP/1.1 101'));
    expect(head.toLowerCase(), isNot(contains('sec-websocket-extensions')));
  });
}
