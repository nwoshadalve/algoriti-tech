import 'package:algoritiq_app/core/clock.dart';
import 'package:algoritiq_app/core/l10n/locale_controller.dart';
import 'package:algoritiq_app/features/licensing/application/license_controller.dart';
import 'package:algoritiq_app/features/licensing/domain/license_ports.dart';
import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'memory_locale_store.dart';

import 'test_vendor_key.dart';

final testNow = DateTime.utc(2026, 10, 27, 9);

class FakeDeviceIdSource implements DeviceIdSource {
  FakeDeviceIdSource(this.id);

  final String? id;

  @override
  Future<String> androidId() async => id ?? (throw StateError('no device id'));
}

class MemoryLicenseStore implements LicenseStore {
  MemoryLicenseStore([this.token]);

  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async => this.token = token;
}

/// A throwaway vendor key plus helpers to issue licenses in tests.
class LicensingKit {
  LicensingKit._(this.key, this.deviceId);

  static Future<LicensingKit> create({String deviceId = 'test-device'}) async =>
      LicensingKit._(await TestVendorKey.generate(), deviceId);

  final TestVendorKey key;
  final String deviceId;

  Future<String> issue({
    LicenseType type = LicenseType.doctor,
    int doctors = 1,
    int chambers = 2,
    DateTime? expiresAt,
    String? forDeviceId,
  }) async {
    return key.issue(
      type: type,
      maxDoctors: doctors,
      maxChambers: chambers,
      device: await DeviceCode.fromAndroidId(forDeviceId ?? deviceId),
      issuedAt: testNow,
      expiresAt: expiresAt,
    );
  }

  List<Override> overrides({
    LicenseStore? store,
    bool deviceIdUnavailable = false,
  }) => [
    deviceIdSourceProvider.overrideWithValue(
      FakeDeviceIdSource(deviceIdUnavailable ? null : deviceId),
    ),
    licenseStoreProvider.overrideWithValue(store ?? MemoryLicenseStore()),
    licenseVerifierProvider.overrideWithValue(
      LicenseVerifier(publicKeys: {key.keyId: key.publicKey}),
    ),
    clockProvider.overrideWithValue(() => testNow),
    localeStoreProvider.overrideWithValue(MemoryLocaleStore()),
  ];
}
