// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:algoritiq_app/features/licensing/domain/license_token.dart';
import 'package:cryptography/cryptography.dart';

/// Throwaway vendor key that signs licenses **for tests only**.
///
/// Real licenses are issued by `algoritiQ/license/license_tool.py`; the app
/// itself can only verify.
class TestVendorKey {
  TestVendorKey._(this.keyId, this._pair, this.publicKey);

  static Future<TestVendorKey> generate([int keyId = 1]) async {
    final pair = await Ed25519().newKeyPair();
    final publicKey = await pair.extractPublicKey();
    return TestVendorKey._(keyId, pair, Uint8List.fromList(publicKey.bytes));
  }

  final int keyId;
  final SimpleKeyPair _pair;
  final Uint8List publicKey;

  Future<String> issue({
    required LicenseType type,
    required int maxDoctors,
    required int maxChambers,
    required DeviceCode device,
    required DateTime issuedAt,
    DateTime? expiresAt,
  }) async {
    final payload = LicensePayload(
      keyId: keyId,
      type: type,
      maxDoctors: maxDoctors,
      maxChambers: maxChambers,
      issuedDay: LicensePayload.dayOf(issuedAt),
      expiresDay: expiresAt == null ? null : LicensePayload.dayOf(expiresAt),
      device: device,
      licenseId: Uint8List.fromList([1, 2, 3, 4]),
    );
    final bytes = payload.encode();
    final signature = await Ed25519().sign(bytes, keyPair: _pair);
    return LicenseToken.encode(bytes, Uint8List.fromList(signature.bytes));
  }
}
