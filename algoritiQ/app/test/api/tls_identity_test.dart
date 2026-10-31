// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/api/tls_identity.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_secret_store.dart';

void main() {
  test('should create an identity that serves HTTPS', () async {
    final identity = await TlsIdentityStore(MemorySecretStore()).loadOrCreate();
    final server = await HttpServer.bindSecure(
      InternetAddress.loopbackIPv4,
      0,
      identity.toSecurityContext(),
    );
    addTearDown(() => server.close(force: true));
    server.listen((request) {
      request.response
        ..write('hello')
        ..close();
    });

    final client = HttpClient()
      // Self-signed: accept it, but only this exact certificate.
      ..badCertificateCallback = (cert, host, port) => listEquals(
        cert.der,
        CryptoUtils.getBytesFromPEMString(identity.certificatePem),
      );
    addTearDown(client.close);
    final request = await client.getUrl(
      Uri.parse('https://127.0.0.1:${server.port}/'),
    );
    final response = await request.close();

    expect(await response.transform(utf8.decoder).join(), 'hello');
    expect(
      identity.fingerprint,
      matches(RegExp(r'^([0-9A-F]{2}:){31}[0-9A-F]{2}$')),
    );
  });

  test('should keep the same identity across restarts', () async {
    final secrets = MemorySecretStore();

    final first = await TlsIdentityStore(secrets).loadOrCreate();
    final second = await TlsIdentityStore(secrets).loadOrCreate();

    expect(second.fingerprint, first.fingerprint);
    expect(
      secrets.values.keys,
      containsAll(['tls.certificate', 'tls.private_key']),
    );
  });
}
