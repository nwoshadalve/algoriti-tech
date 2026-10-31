// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'account.dart';
import 'user_query.dart';

/// Storage for accounts, sessions and the audit trail.
abstract interface class AccountRepository {
  Future<int> adminCount();

  /// The admin registered first (earliest `createdAt`), used for password policy.
  Future<String?> firstAdminId();

  Stream<int> watchAdminCount();

  /// Creates [account] as the first admin, with its audit entry, in one
  /// transaction. Returns false (and writes nothing) if an admin exists.
  Future<bool> createFirstAdmin(Account account, String passwordHash);

  Future<StoredCredentials?> findCredentials(String username);

  /// Same as [findCredentials], looked up by the (normalized) email address.
  Future<StoredCredentials?> findCredentialsByEmail(String email);

  /// Whether another account already uses [email] (already normalized).
  Future<bool> emailInUse(String email, {required String exceptAccountId});

  /// Saves the profile fields and audits it, in one transaction. Returns the
  /// account as stored afterwards.
  Future<Account> updateProfile({
    required String accountId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required DateTime at,
  });

  /// Stores (or, with null, removes) the profile picture and audits it.
  Future<Account> setPhoto({
    required String accountId,
    required List<int>? bytes,
    required DateTime at,
  });

  Future<List<int>?> photoOf(String accountId);

  Future<void> saveSession({
    required String id,
    required String accountId,
    required String tokenHash,
    required DateTime createdAt,
    required DateTime expiresAt,
  });

  Future<SessionRecord?> findSession(String tokenHash);

  Future<void> revokeSession(String tokenHash);

  /// Sets a new password, ends every sign-in of the account and audits it, in
  /// one transaction.
  Future<void> resetPassword({
    required String accountId,
    required String passwordHash,
    required DateTime at,
  });

  /// Sets a new password, ends every sign-in of the account except the one
  /// with [keepTokenHash], and audits it, in one transaction.
  Future<void> changePassword({
    required String accountId,
    required String passwordHash,
    required String keepTokenHash,
    required DateTime at,
  });

  /// Sets a new password for [accountId], revokes every session and PIN, and
  /// records [actorId] as the admin who did it.
  Future<void> setPasswordByAdmin({
    required String accountId,
    required String passwordHash,
    required String actorId,
    required DateTime at,
  });

  /// Every account, including inactive ones (for admin user management).
  Future<List<AccountWithStatus>> listAccounts();

  /// One page of the accounts matching [query], searched, filtered and sorted
  /// by the database.
  Future<AccountsPage> listAccountsPage(UserQuery query);

  Future<AccountWithStatus?> findAccountById(String accountId);

  Future<bool> usernameInUse(
    String username, {
    required String exceptAccountId,
  });

  /// Creates a receptionist (or other managed role) created by an admin.
  Future<Account> createManagedUser({
    required Account account,
    required String passwordHash,
    required String actorId,
    required DateTime at,
  });

  /// Updates profile and/or [status] (`active` / `inactive`). Accounts are never
  /// deleted.
  Future<Account> updateManagedUser({
    required String accountId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String? status,
    required String actorId,
    required DateTime at,
  });

  Future<List<String>> getUserScopes(String userId);

  /// Takes [scopeId] (a chamber or doctor that no longer exists) away from
  /// everyone it was assigned to, and audits it.
  Future<void> removeScopeEverywhere({
    required String scopeId,
    required String actorId,
    required DateTime at,
  });

  Future<void> setUserScopes({
    required String userId,
    required List<String> scopeIds,
    required String actorId,
    required DateTime at,
  });

  /// Keeps a PIN browser for [accountId]. At most [keepAtMost] stay: the oldest
  /// go first. [replaceDeviceId], when it belongs to the account, is removed
  /// (the browser is setting a new PIN). Audited, in one transaction.
  Future<void> savePinDevice({
    required String id,
    required String accountId,
    required String tokenHash,
    required String pinHash,
    required String label,
    required DateTime at,
    required int keepAtMost,
    String? replaceDeviceId,
  });

  /// The PIN browser whose secret hashes to [tokenHash], if its account may
  /// still sign in.
  Future<PinDeviceRecord?> findPinDevice(String tokenHash);

  Future<List<PinDeviceInfo>> listPinDevices(String accountId);

  /// Counts a wrong PIN and returns how many are now in a row.
  Future<int> recordPinFailure(String deviceId);

  /// A right PIN: the wrong ones in a row start again from zero.
  Future<void> recordPinSuccess(String deviceId, DateTime at);

  /// Removes one PIN browser of [accountId]. False when there was none.
  Future<bool> removePinDevice({
    required String accountId,
    required String deviceId,
    required String reason,
    required DateTime at,
  });

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
