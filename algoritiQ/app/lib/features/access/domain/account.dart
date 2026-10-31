// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
/// What a person may do on this tablet.
enum Role { admin, receptionist }

/// A person who can sign in (never holds the password).
final class Account {
  const Account({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    required this.role,
    required this.createdAt,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.photoVersion = 0,
  });

  final String id;

  /// Lower-case sign-in name, unique.
  final String username;
  final String displayName;
  final String email;
  final Role role;
  final DateTime createdAt;
  final String firstName;
  final String lastName;
  final String phone;

  /// Epoch milliseconds of the last photo change; 0 when there is no photo.
  final int photoVersion;
}

/// An [Account] plus whether they may still sign in.
final class AccountWithStatus {
  const AccountWithStatus({required this.account, required this.status});

  final Account account;
  final String status;
}

/// A browser that may sign in with a PIN, as the person sees it in a list.
final class PinDeviceInfo {
  const PinDeviceInfo({
    required this.id,
    required this.label,
    required this.createdAt,
    required this.lastUsedAt,
  });

  final String id;
  final String label;
  final DateTime createdAt;

  /// Null when it was never used to sign in.
  final DateTime? lastUsedAt;
}

/// A PIN browser found by its secret, with what is needed to check a PIN.
final class PinDeviceRecord {
  const PinDeviceRecord({
    required this.id,
    required this.account,
    required this.pinHash,
    required this.failures,
  });

  final String id;
  final Account account;
  final String pinHash;
  final int failures;
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
