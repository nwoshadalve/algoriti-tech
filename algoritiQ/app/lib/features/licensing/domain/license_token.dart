// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

import 'base32.dart';
import 'license_payload.dart';

/// Text form of a licence: base32 of `payload (20 B) + Ed25519 signature
/// (64 B)`, shown in groups of five (e.g. `3K9QX-...`).
abstract final class LicenseToken {
  static const signatureLength = 64;
  static const byteLength = LicensePayload.byteLength + signatureLength;

  static String encode(Uint8List payload, Uint8List signature) {
    final text = Base32.encode(Uint8List.fromList([...payload, ...signature]));
    final groups = <String>[
      for (var i = 0; i < text.length; i += 5)
        text.substring(i, i + 5 > text.length ? text.length : i + 5),
    ];
    return groups.join('-');
  }

  /// Throws [FormatException] if [token] is not a well-formed licence key.
  static ({Uint8List payload, Uint8List signature}) decode(String token) {
    final bytes = Base32.decode(token);
    if (bytes.length != byteLength) {
      throw const FormatException('Bad licence key length');
    }
    return (
      payload: Uint8List.fromList(bytes.sublist(0, LicensePayload.byteLength)),
      signature: Uint8List.fromList(bytes.sublist(LicensePayload.byteLength)),
    );
  }
}
