import 'license_core.dart';

/// Why the app is not licensed.
enum LicenseProblem {
  malformed,
  unknownKey,
  badSignature,
  wrongDevice,
  expired,
}

sealed class LicenseState {
  const LicenseState();
}

/// No usable license: show the activation screen.
final class Unlicensed extends LicenseState {
  const Unlicensed(this.deviceCode, {this.problem});

  final DeviceCode deviceCode;

  /// Set when a stored key was rejected or has expired.
  final LicenseProblem? problem;
}

/// A valid license for this device. [status] is `active` or `grace`.
final class Licensed extends LicenseState {
  const Licensed(this.payload, this.status);

  final LicensePayload payload;
  final LicenseStatus status;
}
