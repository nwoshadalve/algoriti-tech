import 'dart:typed_data';

import 'package:algoritiq_app/features/licensing/domain/base32.dart';
import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:algoritiq_app/features/licensing/domain/license_token.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_vendor_key.dart';

void main() {
  final now = DateTime.utc(2026, 10, 27);
  late TestVendorKey key;
  late TestVendorKey otherKey;
  late DeviceCode device;
  late LicenseVerifier verifier;

  setUpAll(() async {
    key = await TestVendorKey.generate();
    otherKey = await TestVendorKey.generate();
    device = await DeviceCode.fromAndroidId('android-id-1');
    verifier = LicenseVerifier(publicKeys: {1: key.publicKey});
  });

  Future<String> issue({
    LicenseType type = LicenseType.doctor,
    int doctors = 1,
    int chambers = 2,
    DateTime? expiresAt,
    TestVendorKey? signer,
  }) => (signer ?? key).issue(
    type: type,
    maxDoctors: doctors,
    maxChambers: chambers,
    device: device,
    issuedAt: now,
    expiresAt: expiresAt,
  );

  Future<LicenseCheck> verify(String token, {DeviceCode? on, DateTime? at}) =>
      verifier.verify(token, device: on ?? device, now: at ?? now);

  group('base32', () {
    test('should round-trip bytes', () {
      final bytes = Uint8List.fromList(List.generate(84, (i) => i * 3 % 256));
      expect(Base32.decode(Base32.encode(bytes)), bytes);
    });

    test('should ignore case, dashes and confusable characters', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final text = Base32.encode(bytes);
      final messy = text
          .toLowerCase()
          .replaceAll('0', 'o')
          .replaceAll('1', 'l');
      expect(
        Base32.decode(' ${messy.substring(0, 4)}-${messy.substring(4)} '),
        bytes,
      );
    });

    test('should reject invalid characters', () {
      expect(() => Base32.decode('ABC!'), throwsFormatException);
    });
  });

  group('device code', () {
    test('should be stable and formatted XXXXX-XXXXX', () async {
      final again = await DeviceCode.fromAndroidId('android-id-1');
      expect(again, device);
      expect(device.toString(), matches(RegExp(r'^[0-9A-Z]{5}-[0-9A-Z]{5}$')));
    });

    test('should differ per device and survive parse round-trip', () async {
      final other = await DeviceCode.fromAndroidId('android-id-2');
      expect(other, isNot(device));
      expect(DeviceCode.parse(device.toString().toLowerCase()), device);
    });
  });

  group('verification', () {
    test('should accept a valid license for this device', () async {
      final check = await verify(await issue());
      expect(check, isA<LicenseValid>());
      final valid = check as LicenseValid;
      expect(valid.status, LicenseStatus.active);
      expect(valid.payload.type, LicenseType.doctor);
      expect(valid.payload.maxChambers, 2);
    });

    test('should accept a chamber license with several doctors', () async {
      final check = await verify(
        await issue(type: LicenseType.chamber, doctors: 4, chambers: 1),
      );
      final valid = check as LicenseValid;
      expect(valid.payload.type, LicenseType.chamber);
      expect(valid.payload.maxDoctors, 4);
    });

    test('should accept a license typed with lowercase and spaces', () async {
      final token = (await issue()).toLowerCase().replaceAll('-', ' ');
      expect(await verify(token), isA<LicenseValid>());
    });

    // regression: a license must only work on the device it was issued for.
    test('should reject a license issued for another device', () async {
      final other = await DeviceCode.fromAndroidId('someone-elses-tablet');
      final check = await verify(await issue(), on: other);
      expect((check as LicenseInvalid).reason, LicenseRejection.wrongDevice);
    });

    // regression: editing any byte (e.g. extending expiry or limits) must fail.
    test('should reject a tampered license', () async {
      final token = await issue(expiresAt: DateTime.utc(2027, 1, 1));
      final parts = LicenseToken.decode(token);
      final forged = Uint8List.fromList(parts.payload)..[4] = 99;
      final check = await verify(LicenseToken.encode(forged, parts.signature));
      expect((check as LicenseInvalid).reason, LicenseRejection.badSignature);
    });

    test('should reject a license signed by another vendor key', () async {
      final check = await verify(await issue(signer: otherKey));
      expect((check as LicenseInvalid).reason, LicenseRejection.badSignature);
    });

    test('should reject an unknown key id', () async {
      final unknown = await TestVendorKey.generate(7);
      final check = await verify(await issue(signer: unknown));
      expect((check as LicenseInvalid).reason, LicenseRejection.unknownKey);
    });

    test('should reject malformed input', () async {
      for (final text in ['', 'hello world', 'ABCDE-FGHJK', '!!!!!']) {
        final check = await verify(text);
        expect((check as LicenseInvalid).reason, LicenseRejection.malformed);
      }
    });
  });

  group('expiry', () {
    final expires = DateTime.utc(2027, 10, 27);

    test('should be perpetual when no expiry is set', () async {
      final check = await verify(await issue(), at: DateTime.utc(2060, 1, 1));
      expect((check as LicenseValid).status, LicenseStatus.active);
    });

    test('should be active through the last valid day', () async {
      final token = await issue(expiresAt: expires);
      final check = await verify(token, at: DateTime.utc(2027, 10, 27, 23, 59));
      expect((check as LicenseValid).status, LicenseStatus.active);
    });

    test('should be in grace after expiry, then expired', () async {
      final token = await issue(expiresAt: expires);
      final grace = await verify(token, at: DateTime.utc(2027, 11, 5));
      final expired = await verify(token, at: DateTime.utc(2027, 11, 20));
      expect((grace as LicenseValid).status, LicenseStatus.grace);
      expect((expired as LicenseValid).status, LicenseStatus.expired);
    });
  });

  group('payload rules', () {
    test('should not allow a doctor license for several doctors', () {
      expect(() => issue(doctors: 2, chambers: 2), throwsArgumentError);
    });

    test('should not allow a chamber license for several chambers', () {
      expect(
        issue(type: LicenseType.chamber, doctors: 3, chambers: 2),
        throwsArgumentError,
      );
    });
  });
}
