import '../domain/license_core.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../data/android_device_id_source.dart';
import '../data/license_public_keys.dart';
import '../data/prefs_license_store.dart';
import '../domain/license_ports.dart';
import '../domain/license_state.dart';

final deviceIdSourceProvider = Provider<DeviceIdSource>(
  (ref) => const AndroidDeviceIdSource(),
);

final licenseStoreProvider = Provider<LicenseStore>(
  (ref) => const PrefsLicenseStore(),
);

final licenseVerifierProvider = Provider<LicenseVerifier>(
  (ref) => LicenseVerifier(publicKeys: licensePublicKeys),
);

final licenseControllerProvider =
    AsyncNotifierProvider<LicenseController, LicenseState>(
      LicenseController.new,
      // No silent retries: a failure shows the "Try again" screen at once.
      retry: (_, _) => null,
    );

/// Decides whether this device may run the app.
///
/// Checked when the app starts (never in the middle of a clinic session).
class LicenseController extends AsyncNotifier<LicenseState> {
  @override
  Future<LicenseState> build() async {
    final device = await _deviceCode();
    final stored = await ref.read(licenseStoreProvider).read();
    if (stored == null) return Unlicensed(device);
    return _evaluate(stored, device);
  }

  /// Verifies [token] and, if valid, stores it and unlocks the app.
  /// Returns why it was rejected, or null when activated.
  Future<LicenseProblem?> activate(String token) async {
    final device = await _deviceCode();
    final result = await _evaluate(token.trim(), device);
    switch (result) {
      case Licensed():
        await ref.read(licenseStoreProvider).write(token.trim());
        state = AsyncData(result);
        return null;
      case Unlicensed(:final problem):
        return problem;
    }
  }

  Future<DeviceCode> _deviceCode() async => DeviceCode.fromAndroidId(
    await ref.read(deviceIdSourceProvider).androidId(),
  );

  Future<LicenseState> _evaluate(String token, DeviceCode device) async {
    final check = await ref
        .read(licenseVerifierProvider)
        .verify(token, device: device, now: ref.read(clockProvider)());
    return switch (check) {
      LicenseValid(:final status) when status == LicenseStatus.expired =>
        Unlicensed(device, problem: LicenseProblem.expired),
      LicenseValid(:final payload, :final status) => Licensed(payload, status),
      LicenseInvalid(:final reason) => Unlicensed(
        device,
        problem: switch (reason) {
          LicenseRejection.malformed => LicenseProblem.malformed,
          LicenseRejection.unknownKey => LicenseProblem.unknownKey,
          LicenseRejection.badSignature => LicenseProblem.badSignature,
          LicenseRejection.wrongDevice => LicenseProblem.wrongDevice,
        },
      ),
    };
  }
}
