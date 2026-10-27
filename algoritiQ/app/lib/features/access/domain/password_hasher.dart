/// Turns passwords into slow, salted hashes and checks them. Passwords are
/// never stored or logged.
abstract interface class PasswordHasher {
  /// A self-describing hash (algorithm, cost and salt included).
  Future<String> hash(String password);

  Future<bool> verify(String password, String encodedHash);
}
