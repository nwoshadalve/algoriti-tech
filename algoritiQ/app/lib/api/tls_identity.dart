// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:cryptography/cryptography.dart';

import '../core/security/secret_store.dart';
import 'x509_builder.dart';

/// The tablet's HTTPS identity: a local certificate authority (CA) made on
/// this tablet, and a server certificate signed by it for the tablet's names
/// and IP addresses.
///
/// A phone installs the CA once ([caCertificatePem], served at `/ca.crt`) and
/// then trusts the tablet without a browser warning, which is what lets
/// Chrome offer to install the web app. [fingerprint] is the SHA-256 of the
/// CA, shown on the tablet so it can be compared with the file on the phone.
final class TlsIdentity {
  const TlsIdentity({
    required this.certificatePem,
    required this.privateKeyPem,
    required this.caCertificatePem,
    required this.fingerprint,
  });

  /// The server certificate.
  final String certificatePem;
  final String privateKeyPem;

  /// The CA certificate phones install (no private key: that never leaves).
  final String caCertificatePem;

  /// Upper-case hex pairs separated by colons (`AB:CD:...`).
  final String fingerprint;

  SecurityContext toSecurityContext() => SecurityContext()
    ..useCertificateChainBytes(utf8.encode(certificatePem))
    ..usePrivateKeyBytes(utf8.encode(privateKeyPem));
}

/// Creates the CA once and keeps it, so phones that installed it keep
/// trusting the tablet. The server certificate is remade whenever the
/// tablet gets an IP address it does not cover (the CA, and so the phones,
/// are unaffected). Private keys live in the [SecretStore].
class TlsIdentityStore {
  TlsIdentityStore(this._secrets);

  final SecretStore _secrets;

  static const _certKey = 'tls.certificate';
  static const _keyKey = 'tls.private_key';
  static const _caCertKey = 'tls.ca_certificate';
  static const _caKeyKey = 'tls.ca_private_key';
  static const _namesKey = 'tls.certificate_names';

  /// Names the server certificate is valid for.
  static const _names = ['algoritiq.local', 'localhost'];

  /// Addresses the tablet had recently stay valid, so a Wi-Fi that hands out
  /// the same few addresses does not remake the certificate each time.
  static const _maxAddresses = 8;

  static const _caDays = 3650;
  static const _serverDays = 825;
  static const _renewBeforeDays = 30;

  /// The identity for the tablet's current [addresses] (IPv4/IPv6 text).
  Future<TlsIdentity> loadOrCreate({List<String> addresses = const []}) async {
    final ca = await _loadOrCreateCa();
    final (certificate, key) = await _loadOrCreateServer(ca, addresses);
    return TlsIdentity(
      certificatePem: certificate,
      privateKeyPem: key,
      caCertificatePem: ca.$1,
      fingerprint: await _fingerprintOf(ca.$1),
    );
  }

  Future<(String, String)> _loadOrCreateCa() async {
    final certificate = await _secrets.read(_caCertKey);
    final key = await _secrets.read(_caKeyKey);
    if (certificate != null && key != null) return (certificate, key);
    final created = await Isolate.run(_generateCa);
    await _secrets.write(_caKeyKey, created.$2);
    await _secrets.write(_caCertKey, created.$1);
    // A server certificate from before the CA existed is not signed by it.
    await _secrets.write(_namesKey, '[]');
    return created;
  }

  Future<(String, String)> _loadOrCreateServer(
    (String, String) ca,
    List<String> addresses,
  ) async {
    final certificate = await _secrets.read(_certKey);
    final key = await _secrets.read(_keyKey);
    final stored = _storedNames(await _secrets.read(_namesKey));
    if (certificate != null &&
        key != null &&
        stored.isNotEmpty &&
        addresses.every(stored.contains) &&
        !_expiresSoon(certificate)) {
      return (certificate, key);
    }
    final names = [..._names, ..._addressesToCover(addresses, stored)];
    final created = await Isolate.run(() => _generateServer(ca, names));
    await _secrets.write(_keyKey, created.$2);
    await _secrets.write(_certKey, created.$1);
    await _secrets.write(_namesKey, jsonEncode(names));
    return created;
  }

  static List<String> _storedNames(String? json) {
    if (json == null) return const [];
    try {
      return (jsonDecode(json) as List<Object?>).whereType<String>().toList();
    } on FormatException {
      return const [];
    }
  }

  /// Current addresses first, then recent ones, up to [_maxAddresses].
  static List<String> _addressesToCover(
    List<String> current,
    List<String> stored,
  ) {
    final previous = stored.where(
      (name) => !_names.contains(name) && !current.contains(name),
    );
    return [...current, ...previous].take(_maxAddresses).toList();
  }

  static bool _expiresSoon(String certificatePem) {
    try {
      final notAfter = X509Utils.x509CertificateFromPem(certificatePem)
          .tbsCertificate
          ?.validity
          .notAfter;
      if (notAfter == null) return true;
      return notAfter.isBefore(
        DateTime.now().add(const Duration(days: _renewBeforeDays)),
      );
    } on Object {
      return true;
    }
  }

  /// Runs in a background isolate (key generation is CPU heavy).
  static (String, String) _generateCa() {
    final pair = CryptoUtils.generateEcKeyPair();
    final privateKey = pair.privateKey as ECPrivateKey;
    final publicKey = pair.publicKey as ECPublicKey;
    return (
      X509Builder.certificateAuthority(
        privateKey: privateKey,
        publicKey: publicKey,
        subjectCommonName: 'AlgoritiQ Local CA',
        validDays: _caDays,
      ),
      CryptoUtils.encodeEcPrivateKeyToPem(privateKey),
    );
  }

  static (String, String) _generateServer(
    (String, String) ca,
    List<String> namesAndAddresses,
  ) {
    final pair = CryptoUtils.generateEcKeyPair();
    final privateKey = pair.privateKey as ECPrivateKey;
    final publicKey = pair.publicKey as ECPublicKey;
    final isAddress = namesAndAddresses.map(
      (name) => InternetAddress.tryParse(name) != null,
    );
    final dns = <String>[];
    final ips = <String>[];
    var i = 0;
    for (final isIp in isAddress) {
      (isIp ? ips : dns).add(namesAndAddresses[i++]);
    }
    return (
      X509Builder.serverCertificate(
        caPrivateKey: CryptoUtils.ecPrivateKeyFromPem(ca.$2),
        caPublicKey: _publicKeyOf(ca.$1),
        caCommonName: 'AlgoritiQ Local CA',
        publicKey: publicKey,
        subjectCommonName: 'AlgoritiQ',
        names: dns,
        addresses: ips,
        validDays: _serverDays,
      ),
      CryptoUtils.encodeEcPrivateKeyToPem(privateKey),
    );
  }

  /// The public key inside a certificate (the CA's, to name it as issuer).
  static ECPublicKey _publicKeyOf(String certificatePem) {
    final info = X509Utils.x509CertificateFromPem(certificatePem)
        .tbsCertificate!
        .subjectPublicKeyInfo;
    final hex = info.bytes!;
    return CryptoUtils.ecPublicKeyFromDerBytes(
      Uint8List.fromList([
        for (var i = 0; i < hex.length; i += 2)
          int.parse(hex.substring(i, i + 2), radix: 16),
      ]),
    );
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
