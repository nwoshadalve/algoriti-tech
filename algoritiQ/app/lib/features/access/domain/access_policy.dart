/// Why a username or password was refused.
enum CredentialProblem {
  usernameInvalid,
  emailInvalid,
  passwordTooShort,
  passwordTooLong,
  passwordContainsUsername,
}

/// Rules for usernames, email and passwords on registration.
abstract final class AccessPolicy {
  static const minPasswordLength = 8;
  static const maxPasswordLength = 128;
  static const maxEmailLength = 254;

  static final _usernamePattern = RegExp(r'^[a-z0-9._-]{3,32}$');
  static final _emailPattern = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    caseSensitive: false,
  );

  /// Sign-in names are not case sensitive.
  static String normalizeUsername(String input) => input.trim().toLowerCase();

  static String normalizeEmail(String input) => input.trim().toLowerCase();

  static CredentialProblem? checkEmail(String email) {
    final value = email.trim();
    if (value.isEmpty || value.length > maxEmailLength) {
      return CredentialProblem.emailInvalid;
    }
    if (!_emailPattern.hasMatch(value)) return CredentialProblem.emailInvalid;
    return null;
  }

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
