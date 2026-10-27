/// Why a username or password was refused.
enum CredentialProblem {
  usernameInvalid,
  passwordTooShort,
  passwordTooLong,
  passwordContainsUsername,
}

/// Rules for usernames and passwords. There is no email offline, so the
/// username is the identity; passwords must be long rather than complex.
abstract final class AccessPolicy {
  static const minPasswordLength = 10;
  static const maxPasswordLength = 128;

  static final _usernamePattern = RegExp(r'^[a-z0-9._-]{3,32}$');

  /// Sign-in names are not case sensitive.
  static String normalizeUsername(String input) => input.trim().toLowerCase();

  /// The first problem with the pair, or null when both are acceptable.
  static CredentialProblem? check({
    required String username,
    required String password,
  }) {
    if (!_usernamePattern.hasMatch(normalizeUsername(username))) {
      return CredentialProblem.usernameInvalid;
    }
    if (password.length < minPasswordLength) {
      return CredentialProblem.passwordTooShort;
    }
    if (password.length > maxPasswordLength) {
      return CredentialProblem.passwordTooLong;
    }
    if (password.toLowerCase().contains(normalizeUsername(username))) {
      return CredentialProblem.passwordContainsUsername;
    }
    return null;
  }
}
