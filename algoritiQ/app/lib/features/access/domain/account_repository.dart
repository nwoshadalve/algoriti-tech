import 'account.dart';

/// Storage for accounts, sessions and the audit trail.
abstract interface class AccountRepository {
  Future<int> adminCount();

  Stream<int> watchAdminCount();

  /// Creates [account] as the first admin, with its audit entry, in one
  /// transaction. Returns false (and writes nothing) if an admin exists.
  Future<bool> createFirstAdmin(Account account, String passwordHash);

  Future<StoredCredentials?> findCredentials(String username);

  Future<void> saveSession({
    required String id,
    required String accountId,
    required String tokenHash,
    required DateTime createdAt,
    required DateTime expiresAt,
  });

  Future<SessionRecord?> findSession(String tokenHash);

  Future<void> revokeSession(String tokenHash);

  /// Appends to the tamper-evident audit trail.
  Future<void> audit({
    required DateTime at,
    required String action,
    String? actorId,
    String? detail,
  });

  /// False when any audit entry was changed or removed.
  Future<bool> auditTrailIsIntact();
}
