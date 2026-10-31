/// Why a username or password was refused.
enum CredentialProblem {
  usernameInvalid,
  emailInvalid,
  passwordTooShort,
  passwordTooLong,
  passwordContainsUsername,
}

/// Why a profile change was refused.
enum ProfileProblem {
  firstNameMissing,
  nameTooLong,
  emailInvalid,
  emailTaken,
  phoneInvalid,
}

/// Why a PIN was refused.
enum PinProblem {
  /// Not exactly [AccessPolicy.pinLength] digits.
  format,

  /// Too easy to guess: one digit repeated, or a straight run like 123456.
  weak,
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

  static const pinLength = 6;

  /// The problem with [pin], or null when it is acceptable. A PIN is short, so
  /// it is only ever used together with a secret kept in one browser, and a
  /// device is locked after a few wrong tries; the rules here only keep out
  /// the guesses an attacker would try first.
  static PinProblem? checkPin(String pin) {
    if (pin.length != pinLength || !RegExp(r'^[0-9]+$').hasMatch(pin)) {
      return PinProblem.format;
    }
    final digits = [for (final unit in pin.codeUnits) unit - 0x30];
    final steps = {
      for (var i = 1; i < digits.length; i++) digits[i] - digits[i - 1],
    };
    final repeated = steps.length == 1 && steps.single == 0;
    final run = steps.length == 1 && (steps.single == 1 || steps.single == -1);
    return repeated || run ? PinProblem.weak : null;
  }

  static const maxNameLength = 64;
  static const maxPhoneLength = 32;
  static final _phonePattern = RegExp(r'^[0-9+()\-. ]+$');

  /// Largest profile picture accepted, in bytes (the web app shrinks first).
  static const maxPhotoBytes = 512 * 1024;

  /// The first problem with a profile's text fields, or null. An empty phone
  /// is allowed.
  static ProfileProblem? checkProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    if (firstName.trim().isEmpty) return ProfileProblem.firstNameMissing;
    if (firstName.trim().length > maxNameLength ||
        lastName.trim().length > maxNameLength) {
      return ProfileProblem.nameTooLong;
    }
    if (checkEmail(email) != null) return ProfileProblem.emailInvalid;
    final number = phone.trim();
    if (number.isNotEmpty &&
        (number.length > maxPhoneLength || !_phonePattern.hasMatch(number))) {
      return ProfileProblem.phoneInvalid;
    }
    return null;
  }

  /// "jpeg", "png" or "webp" when [bytes] start like that image type.
  static String? imageType(List<int> bytes) {
    bool startsWith(List<int> magic, [int offset = 0]) {
      if (bytes.length < offset + magic.length) return false;
      for (var i = 0; i < magic.length; i++) {
        if (bytes[offset + i] != magic[i]) return false;
      }
      return true;
    }

    if (startsWith(const [0xFF, 0xD8, 0xFF])) return 'jpeg';
    if (startsWith(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
      return 'png';
    }
    if (startsWith(const [0x52, 0x49, 0x46, 0x46]) &&
        startsWith(const [0x57, 0x45, 0x42, 0x50], 8)) {
      return 'webp';
    }
    return null;
  }

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
