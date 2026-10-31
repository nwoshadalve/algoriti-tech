// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'account.dart';

/// What the users list can be sorted by.
enum UserSort { name, username, role, status, created }

/// One page request for the admin's users table: what to match, in which
/// order, and which slice. Every part is applied by the database, so the
/// browser only ever receives the rows it shows.
final class UserQuery {
  const UserQuery({
    this.search = '',
    this.role,
    this.status,
    this.excludeId,
    this.sort = UserSort.name,
    this.descending = false,
    this.offset = 0,
    this.limit = defaultLimit,
  });

  static const defaultLimit = 20;
  static const maxLimit = 50;

  /// Matches part of the name, username, email or phone, in any case.
  final String search;

  final Role? role;

  /// `active` or `inactive`; null for both.
  final String? status;

  /// An account to leave out, so admins do not see themselves in the list.
  final String? excludeId;

  final UserSort sort;
  final bool descending;
  final int offset;
  final int limit;
}

/// One slice of the accounts that match a [UserQuery].
final class AccountsPage {
  const AccountsPage({required this.rows, required this.total});

  final List<AccountWithStatus> rows;

  /// Everything that matches, not only this slice.
  final int total;
}
