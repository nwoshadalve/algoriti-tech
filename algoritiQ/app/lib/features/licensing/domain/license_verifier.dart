// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'device_code.dart';
import 'license_payload.dart';
import 'license_token.dart';

enum LicenseRejection {
  /// Not a licence key (wrong characters or length, unsupported version).
  malformed,

  /// Signed with a key this app does not know.
  unknownKey,

  /// Content was changed or not signed by the vendor.
  badSignature,

  /// Valid key, but issued for another device.
  wrongDevice,
}

sealed class LicenseCheck {
  const LicenseCheck();
}

/// Signature and device match. [status] says whether it is still in date.
final class LicenseValid extends LicenseCheck {
  const LicenseValid(this.payload, this.status);

  final LicensePayload payload;
  final LicenseStatus status;
}

final class LicenseInvalid extends LicenseCheck {
  const LicenseInvalid(this.reason);

  final LicenseRejection reason;
}

/// Verifies licence keys offline against the vendor's public key(s).
///
/// Holds public keys only; it cannot create licences.
final class LicenseVerifier {
  LicenseVerifier({
    required Map<int, Uint8List> publicKeys,
    this.grace = const Duration(days: 14),
  }) : _publicKeys = Map.unmodifiable(publicKeys);

  /// Public keys by `keyId`, so keys can be rotated without breaking old keys.
  final Map<int, Uint8List> _publicKeys;
  final Duration grace;

  Future<LicenseCheck> verify(
    String token, {
    required DeviceCode device,
    required DateTime now,
  }) async {
    final LicensePayload payload;
    final Uint8List payloadBytes;
    final Uint8List signature;
    try {
      final parts = LicenseToken.decode(token);
      payloadBytes = parts.payload;
      signature = parts.signature;
      payload = LicensePayload.decode(payloadBytes);
    } on FormatException {
      return const LicenseInvalid(LicenseRejection.malformed);
    }

    final publicKey = _publicKeys[payload.keyId];
    if (publicKey == null) {
      return const LicenseInvalid(LicenseRejection.unknownKey);
    }

    final signatureOk = await Ed25519().verify(
      payloadBytes,
      signature: Signature(
        signature,
        publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
      ),
    );
    if (!signatureOk) {
      return const LicenseInvalid(LicenseRejection.badSignature);
    }
    if (payload.device != device) {
      return const LicenseInvalid(LicenseRejection.wrongDevice);
    }
    return LicenseValid(payload, payload.statusAt(now, grace: grace));
  }
}
