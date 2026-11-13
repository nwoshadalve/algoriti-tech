// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/api/tls_identity.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_secret_store.dart';

/// Serves "hello" over TLS with [identity] and fetches it from a client that
/// trusts only the CA, exactly what a phone with the CA installed does.
Future<String> _fetchTrustingOnlyCa(TlsIdentity identity, String host) async {
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
  final client = HttpClient(
    context: SecurityContext(withTrustedRoots: false)
      ..setTrustedCertificatesBytes(utf8.encode(identity.caCertificatePem)),
  );
  addTearDown(client.close);
  final request = await client.getUrl(
    Uri.parse('https://$host:${server.port}/'),
  );
  final response = await request.close();
  return response.transform(utf8.decoder).join();
}

void main() {
  test(
    'should serve HTTPS that a client trusting only the CA accepts',
    () async {
      final identity = await TlsIdentityStore(MemorySecretStore())
          .loadOrCreate(addresses: ['127.0.0.1']);

      // By IP address (an IP SAN) and by name (a DNS SAN).
      expect(await _fetchTrustingOnlyCa(identity, '127.0.0.1'), 'hello');
      expect(await _fetchTrustingOnlyCa(identity, 'localhost'), 'hello');
      expect(
        identity.fingerprint,
        matches(RegExp(r'^([0-9A-F]{2}:){31}[0-9A-F]{2}$')),
      );
    },
  );

  test('should refuse an address the certificate does not cover', () async {
    final identity = await TlsIdentityStore(MemorySecretStore())
        .loadOrCreate(addresses: ['192.168.1.22']);

    // 127.0.0.1 is not among the covered addresses.
    await expectLater(
      _fetchTrustingOnlyCa(identity, '127.0.0.1'),
      throwsA(isA<HandshakeException>()),
    );
  });

  test('should describe the CA and list names and addresses', () async {
    final identity = await TlsIdentityStore(MemorySecretStore())
        .loadOrCreate(addresses: ['192.168.1.22']);

    final ca = X509Utils.x509CertificateFromPem(identity.caCertificatePem);
    expect(ca.tbsCertificate!.extensions!.cA, isTrue);
    final server = X509Utils.x509CertificateFromPem(identity.certificatePem);
    expect(
      server.tbsCertificate!.extensions!.subjectAlternativNames,
      containsAll(['algoritiq.local', 'localhost', '192.168.1.22']),
    );
    expect(server.tbsCertificate!.extensions!.cA, isNot(true));
  });

  test('should keep the CA across restarts and remake only the server '
      'certificate for a new address', () async {
    final secrets = MemorySecretStore();

    final first = await TlsIdentityStore(secrets)
        .loadOrCreate(addresses: ['192.168.1.22']);
    final same = await TlsIdentityStore(secrets)
        .loadOrCreate(addresses: ['192.168.1.22']);
    final moved = await TlsIdentityStore(secrets)
        .loadOrCreate(addresses: ['172.20.10.3']);

    expect(same.certificatePem, first.certificatePem);
    expect(moved.caCertificatePem, first.caCertificatePem);
    expect(moved.fingerprint, first.fingerprint);
    expect(moved.certificatePem, isNot(first.certificatePem));
    // The earlier address still works after moving.
    final sans = X509Utils.x509CertificateFromPem(moved.certificatePem)
        .tbsCertificate!
        .extensions!
        .subjectAlternativNames;
    expect(sans, containsAll(['172.20.10.3', '192.168.1.22']));
    expect(
      secrets.values.keys,
      containsAll(['tls.certificate', 'tls.private_key', 'tls.ca_certificate']),
    );
  });

  test('should replace a certificate from before the CA existed', () async {
    final secrets = MemorySecretStore()
      ..values['tls.certificate'] = 'old'
      ..values['tls.private_key'] = 'old';

    final identity = await TlsIdentityStore(secrets)
        .loadOrCreate(addresses: ['127.0.0.1']);

    expect(await _fetchTrustingOnlyCa(identity, '127.0.0.1'), 'hello');
  });
}
