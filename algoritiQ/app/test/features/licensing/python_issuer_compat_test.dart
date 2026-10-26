import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keys are issued by `algoritiQ/license/license_tool.py`. This vector comes
/// from that script (its own tests pin the same token), so a format change on
/// either side fails here.
void main() {
  final vector = jsonDecode(
    File('../license/tests/fixtures/python_license_vector.json')
        .readAsStringSync(),
  ) as Map<String, Object?>;

  late LicenseVerifier verifier;
  late DeviceCode device;
  final token = vector['activationKey']! as String;
  final inValidity = DateTime.utc(2026, 11, 1);

  setUpAll(() async {
    verifier = LicenseVerifier(
      publicKeys: {
        vector['keyId']! as int: base64Decode(
          vector['publicKeyBase64']! as String,
        ),
      },
    );
    device = await DeviceCode.fromAndroidId(vector['androidId']! as String);
  });

  test('should derive the same device code as the Python tool', () {
    expect(device.toString(), vector['deviceCode']);
  });

  test('should accept a license issued by the Python tool', () async {
    final check = await verifier.verify(token, device: device, now: inValidity);

    expect(check, isA<LicenseValid>());
    final valid = check as LicenseValid;
    expect(valid.status, LicenseStatus.active);
    expect(valid.payload.type, LicenseType.chamber);
    expect(valid.payload.maxDoctors, 3);
    expect(valid.payload.maxChambers, 1);
    expect(valid.payload.issuedAt, DateTime.utc(2026, 10, 27));
    expect(valid.payload.expiresAt, DateTime.utc(2027, 10, 27));
    expect(valid.payload.licenseIdHex, vector['licenseIdHex']);
  });

  test('should reject the Python-issued license on another device', () async {
    final other = await DeviceCode.fromAndroidId('someone-elses-tablet');
    final check = await verifier.verify(token, device: other, now: inValidity);

    expect((check as LicenseInvalid).reason, LicenseRejection.wrongDevice);
  });
}
