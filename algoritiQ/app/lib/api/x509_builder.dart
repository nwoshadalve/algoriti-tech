// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';

/// Builds the two certificates the tablet needs so a phone can trust it: a
/// local certificate authority (CA, installed once on each phone) and a
/// server certificate signed by it that is valid for the tablet's names and
/// IP addresses. basic_utils cannot put IP addresses in a certificate or sign
/// with a separate CA key, so the small DER encoding is done here.
///
/// Keys are P-256, signatures ECDSA with SHA-256.
abstract final class X509Builder {
  static const _ecdsaSha256 = '1.2.840.10045.4.3.2';

  /// A CA certificate for [subjectCommonName], signed with its own key.
  static String certificateAuthority({
    required ECPrivateKey privateKey,
    required ECPublicKey publicKey,
    required String subjectCommonName,
    required int validDays,
    DateTime? now,
  }) {
    final subject = _name(subjectCommonName);
    final keyId = _keyId(publicKey);
    return _certificate(
      signer: privateKey,
      issuer: subject,
      subject: subject,
      publicKey: publicKey,
      validDays: validDays,
      now: now,
      extensions: [
        _extension('2.5.29.19', _seq([_bool()]), critical: true),
        // keyCertSign (bit 5) and cRLSign (bit 6).
        _extension('2.5.29.15', _bits([0x06], unused: 1), critical: true),
        _extension('2.5.29.14', _octet(keyId)),
      ],
    );
  }

  /// A server certificate for [names] and [addresses], signed by the CA.
  static String serverCertificate({
    required ECPrivateKey caPrivateKey,
    required ECPublicKey caPublicKey,
    required String caCommonName,
    required ECPublicKey publicKey,
    required String subjectCommonName,
    required List<String> names,
    required List<String> addresses,
    required int validDays,
    DateTime? now,
  }) {
    final generalNames = <List<int>>[
      for (final name in names) _tlv(0x82, ascii.encode(name)),
      for (final text in addresses)
        if (InternetAddress.tryParse(text) case final address?)
          _tlv(0x87, address.rawAddress),
    ];
    return _certificate(
      signer: caPrivateKey,
      issuer: _name(caCommonName),
      subject: _name(subjectCommonName),
      publicKey: publicKey,
      validDays: validDays,
      now: now,
      extensions: [
        _extension('2.5.29.19', _seq(const [])),
        // digitalSignature (bit 0).
        _extension('2.5.29.15', _bits([0x80], unused: 7), critical: true),
        // serverAuth.
        _extension('2.5.29.37', _seq([_oid('1.3.6.1.5.5.7.3.1')])),
        _extension('2.5.29.17', _seq(generalNames)),
        _extension('2.5.29.14', _octet(_keyId(publicKey))),
        _extension('2.5.29.35', _seq([_tlv(0x80, _keyId(caPublicKey))])),
      ],
    );
  }

  static String _certificate({
    required ECPrivateKey signer,
    required List<int> issuer,
    required List<int> subject,
    required ECPublicKey publicKey,
    required int validDays,
    required List<List<int>> extensions,
    DateTime? now,
  }) {
    final from = (now ?? DateTime.now()).toUtc().subtract(
      // Tolerates a phone whose clock is a little behind the tablet's.
      const Duration(hours: 1),
    );
    final algorithm = _seq([_oid(_ecdsaSha256)]);
    final tbs = _seq([
      _tlv(0xA0, _int(BigInt.two)),
      _int(_serial()),
      algorithm,
      issuer,
      _seq([_time(from), _time(from.add(Duration(days: validDays)))]),
      subject,
      _publicKeyInfo(publicKey),
      _tlv(0xA3, _seq(extensions)),
    ]);
    final signature = CryptoUtils.ecSign(
      signer,
      Uint8List.fromList(tbs),
      algorithmName: 'SHA-256/ECDSA',
    );
    final der = _seq([
      tbs,
      algorithm,
      _bits(_seq([_int(signature.r), _int(signature.s)]), unused: 0),
    ]);
    final lines = <String>[];
    final text = base64.encode(der);
    for (var i = 0; i < text.length; i += 64) {
      lines.add(text.substring(i, min(i + 64, text.length)));
    }
    return '-----BEGIN CERTIFICATE-----\n${lines.join('\n')}\n'
        '-----END CERTIFICATE-----';
  }

  static List<int> _publicKeyInfo(ECPublicKey key) =>
      CryptoUtils.getBytesFromPEMString(
        CryptoUtils.encodeEcPublicKeyToPem(key),
      );

  /// SHA-1 of the public key point, the usual key identifier.
  static List<int> _keyId(ECPublicKey key) => CryptoUtils.getHashPlain(
    Uint8List.fromList(key.Q!.getEncoded(false)),
    algorithmName: 'SHA-1',
  );

  static BigInt _serial() {
    final random = Random.secure();
    var value = BigInt.zero;
    for (var i = 0; i < 8; i++) {
      value = (value << 8) | BigInt.from(random.nextInt(256));
    }
    // Positive, and never zero.
    return (value & ((BigInt.one << 63) - BigInt.one)) | BigInt.one;
  }

  static List<int> _name(String commonName) => _seq([
    _tlv(0x31, _seq([_oid('2.5.4.10'), _tlv(0x0C, utf8.encode('AlgoritiQ'))])),
    _tlv(0x31, _seq([_oid('2.5.4.3'), _tlv(0x0C, utf8.encode(commonName))])),
  ]);

  static List<int> _extension(
    String oid,
    List<int> value, {
    bool critical = false,
  }) => _seq([_oid(oid), if (critical) _bool(), _octet(value)]);

  static List<int> _time(DateTime utc) {
    String two(int n) => n.toString().padLeft(2, '0');
    final rest =
        '${two(utc.month)}${two(utc.day)}${two(utc.hour)}'
        '${two(utc.minute)}${two(utc.second)}Z';
    // UTCTime holds years up to 2049; later ones are GeneralizedTime.
    return utc.year < 2050
        ? _tlv(0x17, ascii.encode('${two(utc.year % 100)}$rest'))
        : _tlv(0x18, ascii.encode('${utc.year}$rest'));
  }

  static List<int> _seq(List<List<int>> items) =>
      _tlv(0x30, [for (final item in items) ...item]);

  static List<int> _bool() => const [0x01, 0x01, 0xFF];

  static List<int> _octet(List<int> bytes) => _tlv(0x04, bytes);

  static List<int> _bits(List<int> bytes, {required int unused}) =>
      _tlv(0x03, [unused, ...bytes]);

  static List<int> _int(BigInt value) {
    var hex = value.toRadixString(16);
    if (hex.length.isOdd) hex = '0$hex';
    final bytes = <int>[
      for (var i = 0; i < hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ];
    // A leading zero keeps a high first bit from reading as negative.
    if (bytes.first & 0x80 != 0) bytes.insert(0, 0);
    return _tlv(0x02, bytes);
  }

  static List<int> _oid(String dotted) {
    final arcs = dotted.split('.').map(int.parse).toList();
    final out = <int>[arcs[0] * 40 + arcs[1]];
    for (final arc in arcs.skip(2)) {
      final chunk = <int>[arc & 0x7F];
      var rest = arc >> 7;
      while (rest > 0) {
        chunk.insert(0, (rest & 0x7F) | 0x80);
        rest >>= 7;
      }
      out.addAll(chunk);
    }
    return _tlv(0x06, out);
  }

  static List<int> _tlv(int tag, List<int> content) {
    final length = content.length;
    final header = <int>[tag];
    if (length < 0x80) {
      header.add(length);
    } else {
      final size = <int>[];
      for (var rest = length; rest > 0; rest >>= 8) {
        size.insert(0, rest & 0xFF);
      }
      header
        ..add(0x80 | size.length)
        ..addAll(size);
    }
    return [...header, ...content];
  }
}
