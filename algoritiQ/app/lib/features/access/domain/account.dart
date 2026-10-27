/// What a person may do. Only admins exist so far; doctors and receptionists
/// are added with their own screens.
enum Role { admin }

/// A person who can sign in (never holds the password).
final class Account {
  const Account({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  final String id;

  /// Lower-case sign-in name, unique.
  final String username;
  final String displayName;
  final String email;
  final Role role;
  final DateTime createdAt;
}

/// An [Account] with its stored password hash (never sent to clients).
final class StoredCredentials {
  const StoredCredentials({required this.account, required this.passwordHash});

  final Account account;
  final String passwordHash;
}

/// A signed-in session found by its token hash.
final class SessionRecord {
  const SessionRecord({
    required this.account,
    required this.expiresAt,
    required this.revoked,
  });

  final Account account;
  final DateTime expiresAt;
  final bool revoked;
}
