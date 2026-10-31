// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:cryptography/cryptography.dart';

import '../core/security/secret_store.dart';

/// The tablet's self-signed HTTPS identity: certificate, private key and the
/// SHA-256 fingerprint shown on screen so an admin can confirm they reached
/// the right tablet when the browser warns about the certificate.
final class TlsIdentity {
  const TlsIdentity({
    required this.certificatePem,
    required this.privateKeyPem,
    required this.fingerprint,
  });

  final String certificatePem;
  final String privateKeyPem;

  /// Upper-case hex pairs separated by colons (`AB:CD:...`).
  final String fingerprint;

  SecurityContext toSecurityContext() => SecurityContext()
    ..useCertificateChainBytes(utf8.encode(certificatePem))
    ..usePrivateKeyBytes(utf8.encode(privateKeyPem));
}

/// Creates the identity once and keeps it, so the fingerprint stays the same
/// across restarts. The private key lives in the [SecretStore].
class TlsIdentityStore {
  TlsIdentityStore(this._secrets);

  final SecretStore _secrets;

  static const _certKey = 'tls.certificate';
  static const _keyKey = 'tls.private_key';

  /// Names the certificate is valid for (browsers still warn: it is
  /// self-signed). Tablets have changing IPs, so only names are listed.
  static const _names = ['algoritiq.local', 'localhost'];

  Future<TlsIdentity> loadOrCreate() async {
    final certificate = await _secrets.read(_certKey);
    final key = await _secrets.read(_keyKey);
    if (certificate != null && key != null) {
      return TlsIdentity(
        certificatePem: certificate,
        privateKeyPem: key,
        fingerprint: await _fingerprintOf(certificate),
      );
    }
    final (newCertificate, newKey) = await Isolate.run(_generate);
    await _secrets.write(_keyKey, newKey);
    await _secrets.write(_certKey, newCertificate);
    return TlsIdentity(
      certificatePem: newCertificate,
      privateKeyPem: newKey,
      fingerprint: await _fingerprintOf(newCertificate),
    );
  }

  /// Runs in a background isolate (key generation is CPU heavy).
  static (String, String) _generate() {
    final pair = CryptoUtils.generateEcKeyPair();
    final privateKey = pair.privateKey as ECPrivateKey;
    final publicKey = pair.publicKey as ECPublicKey;
    final csr = X509Utils.generateEccCsrPem(
      {'CN': 'AlgoritiQ', 'O': 'AlgoritiQ'},
      privateKey,
      publicKey,
      san: _names,
    );
    final serial = Random.secure().nextInt(1 << 31).toString();
    final certificate = X509Utils.generateSelfSignedCertificate(
      privateKey,
      csr,
      3650,
      sans: _names,
      serialNumber: serial,
    );
    return (certificate, CryptoUtils.encodeEcPrivateKeyToPem(privateKey));
  }

  static Future<String> _fingerprintOf(String certificatePem) async {
    final der = CryptoUtils.getBytesFromPEMString(certificatePem);
    final digest = await Sha256().hash(der);
    return [
      for (final byte in digest.bytes)
        byte.toRadixString(16).padLeft(2, '0').toUpperCase(),
    ].join(':');
  }
}
