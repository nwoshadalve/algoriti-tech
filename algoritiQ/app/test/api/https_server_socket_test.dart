import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/api/https_server_socket.dart';
import 'package:algoritiq_app/api/tls_identity.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_secret_store.dart';

void main() {
  late TlsIdentity identity;
  late HttpsServerSocket socket;
  late HttpServer server;

  setUpAll(() async {
    identity = await TlsIdentityStore(MemorySecretStore()).loadOrCreate();
  });

  Future<void> start({
    Duration sniffTimeout = const Duration(seconds: 5),
  }) async {
    socket = await HttpsServerSocket.bind(
      InternetAddress.loopbackIPv4,
      0,
      identity.toSecurityContext(),
      sniffTimeout: sniffTimeout,
    );
    server = HttpServer.listenOn(socket);
    server.listen((request) {
      request.response
        ..write('hello ${request.uri.path}')
        ..close();
    });
    addTearDown(() async {
      await server.close(force: true);
      await socket.close();
    });
  }

  /// What the server sends back to [request] written straight onto the port,
  /// until it closes the connection.
  Future<String> plain(String request) async {
    final client = await Socket.connect(
      InternetAddress.loopbackIPv4,
      socket.port,
    );
    client.add(utf8.encode(request));
    final reply = await client.cast<List<int>>().transform(utf8.decoder).join();
    client.destroy();
    return reply;
  }

  String? header(String reply, String name) {
    for (final line in reply.split('\r\n')) {
      if (line.toLowerCase().startsWith('${name.toLowerCase()}:')) {
        return line.substring(name.length + 1).trim();
      }
    }
    return null;
  }

  test('should still serve HTTPS on the same port', () async {
    await start();
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => listEquals(
        cert.der,
        CryptoUtils.getBytesFromPEMString(identity.certificatePem),
      );
    addTearDown(client.close);

    final request = await client.getUrl(
      Uri.parse('https://127.0.0.1:${socket.port}/ping'),
    );
    final response = await request.close();

    expect(response.statusCode, 200);
    expect(await utf8.decodeStream(response), 'hello /ping');
  });

  test('should send a plain visit to the same address over https', () async {
    await start();

    final reply = await plain(
      'GET /ping?x=1 HTTP/1.1\r\nHost: 127.0.0.1:${socket.port}\r\n\r\n',
    );

    expect(reply, startsWith('HTTP/1.1 307'));
    expect(
      header(reply, 'Location'),
      'https://127.0.0.1:${socket.port}/ping?x=1',
    );
  });

  test('should use the name the visitor typed, with the real port', () async {
    await start();

    final reply = await plain(
      'GET / HTTP/1.1\r\nHost: algoritiq.local\r\n\r\n',
    );

    expect(
      header(reply, 'Location'),
      'https://algoritiq.local:${socket.port}/',
    );
  });

  test('should replace a port the visitor typed with the real one', () async {
    await start();

    final reply = await plain(
      'GET /a HTTP/1.1\r\nHost: algoritiq.local:80\r\n\r\n',
    );

    expect(
      header(reply, 'Location'),
      'https://algoritiq.local:${socket.port}/a',
    );
  });

  test('should keep an IPv6 address in brackets', () async {
    await start();

    final reply = await plain('GET / HTTP/1.1\r\nHost: [fe80::1]:80\r\n\r\n');

    expect(header(reply, 'Location'), 'https://[fe80::1]:${socket.port}/');
  });

  test(
    'should keep the method for a plain POST (temporary redirect)',
    () async {
      await start();

      final reply = await plain(
        'POST /api/v1/auth/login HTTP/1.1\r\nHost: algoritiq.local\r\n'
        'Content-Length: 0\r\n\r\n',
      );

      expect(reply, startsWith('HTTP/1.1 307'));
      expect(header(reply, 'Cache-Control'), 'no-store');
    },
  );

  test('should refuse a request that names no usable host', () async {
    await start();

    expect(await plain('GET / HTTP/1.1\r\n\r\n'), startsWith('HTTP/1.1 400'));
    expect(
      await plain('GET / HTTP/1.1\r\nHost: evil.com/path\r\n\r\n'),
      startsWith('HTTP/1.1 400'),
    );
    expect(
      await plain('GET / HTTP/1.1\r\nHost: a b\r\n\r\n'),
      startsWith('HTTP/1.1 400'),
    );
  });

  test('should refuse something that is not HTTP at all', () async {
    await start();

    expect(await plain('hello there\r\n\r\n'), startsWith('HTTP/1.1 400'));
  });

  test('should not put a strange path into the redirect', () async {
    await start();

    final reply = await plain(
      'GET http://evil.com/ HTTP/1.1\r\nHost: algoritiq.local\r\n\r\n',
    );

    expect(
      header(reply, 'Location'),
      'https://algoritiq.local:${socket.port}/',
    );
  });

  test('should hang up on a connection that says nothing', () async {
    await start(sniffTimeout: const Duration(milliseconds: 100));
    final client = await Socket.connect(
      InternetAddress.loopbackIPv4,
      socket.port,
    );

    final closed = client.drain<void>().timeout(const Duration(seconds: 2));

    await expectLater(closed, completes);
    client.destroy();
  });

  test('should keep serving after a client breaks the handshake', () async {
    await start();
    final broken = await Socket.connect(
      InternetAddress.loopbackIPv4,
      socket.port,
    );
    broken.add([0x16, 0x03, 0x01, 0x00, 0x05, 0xFF, 0xFF]);
    await broken.flush();
    broken.destroy();

    final reply = await plain('GET / HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n');

    expect(reply, startsWith('HTTP/1.1 307'));
  });

  test('should stop listening when closed', () async {
    await start();
    final port = socket.port;

    await server.close(force: true);
    await socket.close();

    await expectLater(
      Socket.connect(InternetAddress.loopbackIPv4, port),
      throwsA(isA<SocketException>()),
    );
  });
}
