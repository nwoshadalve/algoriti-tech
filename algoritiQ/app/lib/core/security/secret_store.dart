/// Keeps small secrets (keys, certificates) away from the database and logs.
/// On Android it is backed by the hardware Keystore.
abstract interface class SecretStore {
  Future<String?> read(String name);

  Future<void> write(String name, String value);
}
