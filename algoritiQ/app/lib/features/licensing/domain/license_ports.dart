/// Reads the Android device identity used to bind a license.
abstract interface class DeviceIdSource {
  Future<String> androidId();
}

/// Persists the activation key on this device.
///
/// The key is signed, not secret: editing it invalidates the signature.
abstract interface class LicenseStore {
  Future<String?> read();

  Future<void> write(String token);
}
