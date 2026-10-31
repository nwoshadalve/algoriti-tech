// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/account.dart';
import '../domain/account_repository.dart';
import '../domain/audit_chain.dart';
import '../domain/user_query.dart';

final class DriftAccountRepository implements AccountRepository {
  DriftAccountRepository(this._db);

  final AppDatabase _db;

  AccountWithStatus _managedOf(UserRow row) =>
      AccountWithStatus(account: _accountOf(row), status: row.status);

  Account _accountOf(UserRow row) => Account(
    id: row.id,
    username: row.username,
    displayName: row.displayName,
    firstName: row.firstName.isNotEmpty
        ? row.firstName
        : row.displayName.split(' ').first,
    lastName: row.firstName.isNotEmpty
        ? row.lastName
        : row.displayName.split(' ').skip(1).join(' '),
    phone: row.phone,
    photoVersion: row.photoVersion,
    email: row.email,
    role: Role.values.asNameMap()[row.role] ?? Role.admin,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt, isUtc: true),
  );

  Expression<bool> get _isActiveAdmin =>
      _db.users.role.equals(Role.admin.name) &
      _db.users.status.equals('active');

  @override
  Future<int> adminCount() async {
    final count = _db.users.id.count();
    final query = _db.selectOnly(_db.users)
      ..addColumns([count])
      ..where(_isActiveAdmin);
    return (await query.map((row) => row.read(count)).getSingle()) ?? 0;
  }

  @override
  Future<String?> firstAdminId() async {
    final query = _db.select(_db.users)
      ..where((u) => u.role.equals(Role.admin.name))
      ..orderBy([
        (u) => OrderingTerm.asc(u.createdAt),
        (u) => OrderingTerm.asc(u.id),
      ])
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row?.id;
  }

  @override
  Stream<int> watchAdminCount() {
    final count = _db.users.id.count();
    final query = _db.selectOnly(_db.users)
      ..addColumns([count])
      ..where(_isActiveAdmin);
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  @override
  Future<bool> createFirstAdmin(Account account, String passwordHash) =>
      _db.transaction(() async {
        if (await adminCount() > 0) return false;
        await _db
            .into(_db.users)
            .insert(
              UsersCompanion.insert(
                id: account.id,
                username: account.username,
                displayName: account.displayName,
                email: Value(account.email),
                firstName: Value(account.firstName),
                lastName: Value(account.lastName),
                role: account.role.name,
                passwordHash: passwordHash,
                createdAt: account.createdAt.toUtc().millisecondsSinceEpoch,
              ),
            );
        await audit(
          at: account.createdAt,
          action: 'admin.registered',
          actorId: account.id,
          detail: account.username,
        );
        return true;
      });

  @override
  Future<StoredCredentials?> findCredentials(String username) async {
    final row =
        await (_db.select(_db.users)..where(
              (u) => u.username.equals(username) & u.status.equals('active'),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return StoredCredentials(
      account: _accountOf(row),
      passwordHash: row.passwordHash,
    );
  }

  @override
  Future<StoredCredentials?> findCredentialsByEmail(String email) async {
    final row =
        await (_db.select(_db.users)
              ..where((u) => u.email.equals(email) & u.status.equals('active'))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return StoredCredentials(
      account: _accountOf(row),
      passwordHash: row.passwordHash,
    );
  }

  @override
  Future<bool> emailInUse(
    String email, {
    required String exceptAccountId,
  }) async {
    final row =
        await (_db.select(_db.users)
              ..where(
                (u) =>
                    u.email.equals(email) & u.id.equals(exceptAccountId).not(),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<Account> _stored(String accountId) async => _accountOf(
    await (_db.select(
      _db.users,
    )..where((u) => u.id.equals(accountId))).getSingle(),
  );

  @override
  Future<Account> updateProfile({
    required String accountId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required DateTime at,
  }) => _db.transaction(() async {
    final displayName = '${firstName.trim()} ${lastName.trim()}'.trim();
    await (_db.update(_db.users)..where((u) => u.id.equals(accountId))).write(
      UsersCompanion(
        firstName: Value(firstName.trim()),
        lastName: Value(lastName.trim()),
        displayName: Value(displayName),
        email: Value(email),
        phone: Value(phone.trim()),
      ),
    );
    await audit(at: at, action: 'account.profile_updated', actorId: accountId);
    return _stored(accountId);
  });

  @override
  Future<Account> setPhoto({
    required String accountId,
    required List<int>? bytes,
    required DateTime at,
  }) => _db.transaction(() async {
    await (_db.update(_db.users)..where((u) => u.id.equals(accountId))).write(
      UsersCompanion(
        photo: Value(bytes == null ? null : Uint8List.fromList(bytes)),
        photoVersion: Value(
          bytes == null ? 0 : at.toUtc().millisecondsSinceEpoch,
        ),
      ),
    );
    await audit(
      at: at,
      action: bytes == null ? 'account.photo_removed' : 'account.photo_changed',
      actorId: accountId,
    );
    return _stored(accountId);
  });

  @override
  Future<List<int>?> photoOf(String accountId) async {
    final row = await (_db.select(
      _db.users,
    )..where((u) => u.id.equals(accountId))).getSingleOrNull();
    return row?.photo;
  }

  @override
  Future<void> saveSession({
    required String id,
    required String accountId,
    required String tokenHash,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) async {
    await _db
        .into(_db.authSessions)
        .insert(
          AuthSessionsCompanion.insert(
            id: id,
            userId: accountId,
            tokenHash: tokenHash,
            createdAt: createdAt.toUtc().millisecondsSinceEpoch,
            expiresAt: expiresAt.toUtc().millisecondsSinceEpoch,
          ),
        );
  }

  @override
  Future<SessionRecord?> findSession(String tokenHash) async {
    final query = _db.select(_db.authSessions).join([
      innerJoin(_db.users, _db.users.id.equalsExp(_db.authSessions.userId)),
    ])..where(_db.authSessions.tokenHash.equals(tokenHash));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final session = row.readTable(_db.authSessions);
    final user = row.readTable(_db.users);
    if (user.status != 'active') return null;
    return SessionRecord(
      account: _accountOf(user),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt,
        isUtc: true,
      ),
      revoked: session.revoked,
    );
  }

  @override
  Future<void> revokeSession(String tokenHash) async {
    await (_db.update(_db.authSessions)
          ..where((s) => s.tokenHash.equals(tokenHash)))
        .write(const AuthSessionsCompanion(revoked: Value(true)));
  }

  @override
  Future<void> resetPassword({
    required String accountId,
    required String passwordHash,
    required DateTime at,
  }) => _db.transaction(() async {
    await (_db.update(_db.users)..where((u) => u.id.equals(accountId))).write(
      UsersCompanion(passwordHash: Value(passwordHash)),
    );
    await (_db.update(_db.authSessions)
          ..where((s) => s.userId.equals(accountId)))
        .write(const AuthSessionsCompanion(revoked: Value(true)));
    // A PIN set with the old password may have been set by someone else.
    await (_db.delete(
      _db.pinDevices,
    )..where((d) => d.userId.equals(accountId))).go();
    await audit(at: at, action: 'auth.password_reset', actorId: accountId);
  });

  @override
  Future<void> changePassword({
    required String accountId,
    required String passwordHash,
    required String keepTokenHash,
    required DateTime at,
  }) => _db.transaction(() async {
    await (_db.update(_db.users)..where((u) => u.id.equals(accountId))).write(
      UsersCompanion(passwordHash: Value(passwordHash)),
    );
    await (_db.update(_db.authSessions)..where(
          (s) =>
              s.userId.equals(accountId) &
              s.tokenHash.equals(keepTokenHash).not(),
        ))
        .write(const AuthSessionsCompanion(revoked: Value(true)));
    await (_db.delete(
      _db.pinDevices,
    )..where((d) => d.userId.equals(accountId))).go();
    await audit(at: at, action: 'auth.password_changed', actorId: accountId);
  });

  @override
  Future<void> setPasswordByAdmin({
    required String accountId,
    required String passwordHash,
    required String actorId,
    required DateTime at,
  }) => _db.transaction(() async {
    await (_db.update(_db.users)..where((u) => u.id.equals(accountId))).write(
      UsersCompanion(passwordHash: Value(passwordHash)),
    );
    await (_db.update(_db.authSessions)
          ..where((s) => s.userId.equals(accountId)))
        .write(const AuthSessionsCompanion(revoked: Value(true)));
    await (_db.delete(
      _db.pinDevices,
    )..where((d) => d.userId.equals(accountId))).go();
    await audit(
      at: at,
      action: 'user.password_set',
      actorId: actorId,
      detail: accountId,
    );
  });

  @override
  Future<void> savePinDevice({
    required String id,
    required String accountId,
    required String tokenHash,
    required String pinHash,
    required String label,
    required DateTime at,
    required int keepAtMost,
    String? replaceDeviceId,
  }) => _db.transaction(() async {
    if (replaceDeviceId != null) {
      await (_db.delete(_db.pinDevices)..where(
            (d) => d.id.equals(replaceDeviceId) & d.userId.equals(accountId),
          ))
          .go();
    }
    final existing =
        await (_db.select(_db.pinDevices)
              ..where((d) => d.userId.equals(accountId))
              ..orderBy([(d) => OrderingTerm.asc(d.createdAt)]))
            .get();
    final surplus = existing.length - (keepAtMost - 1);
    for (final old in existing.take(surplus < 0 ? 0 : surplus)) {
      await (_db.delete(
        _db.pinDevices,
      )..where((d) => d.id.equals(old.id))).go();
    }
    await _db
        .into(_db.pinDevices)
        .insert(
          PinDevicesCompanion.insert(
            id: id,
            userId: accountId,
            tokenHash: tokenHash,
            pinHash: pinHash,
            label: Value(label),
            createdAt: at.toUtc().millisecondsSinceEpoch,
          ),
        );
    await audit(at: at, action: 'auth.pin_set', actorId: accountId, detail: id);
  });

  @override
  Future<PinDeviceRecord?> findPinDevice(String tokenHash) async {
    final query = _db.select(_db.pinDevices).join([
      innerJoin(_db.users, _db.users.id.equalsExp(_db.pinDevices.userId)),
    ])..where(_db.pinDevices.tokenHash.equals(tokenHash));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final user = row.readTable(_db.users);
    if (user.status != 'active') return null;
    final device = row.readTable(_db.pinDevices);
    return PinDeviceRecord(
      id: device.id,
      account: _accountOf(user),
      pinHash: device.pinHash,
      failures: device.failures,
    );
  }

  @override
  Future<List<PinDeviceInfo>> listPinDevices(String accountId) async {
    final rows =
        await (_db.select(_db.pinDevices)
              ..where((d) => d.userId.equals(accountId))
              ..orderBy([(d) => OrderingTerm.asc(d.createdAt)]))
            .get();
    return [
      for (final row in rows)
        PinDeviceInfo(
          id: row.id,
          label: row.label,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            row.createdAt,
            isUtc: true,
          ),
          lastUsedAt: row.lastUsedAt == 0
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                  row.lastUsedAt,
                  isUtc: true,
                ),
        ),
    ];
  }

  @override
  Future<int> recordPinFailure(String deviceId) => _db.transaction(() async {
    final row = await (_db.select(
      _db.pinDevices,
    )..where((d) => d.id.equals(deviceId))).getSingleOrNull();
    final failures = (row?.failures ?? 0) + 1;
    await (_db.update(_db.pinDevices)..where((d) => d.id.equals(deviceId)))
        .write(PinDevicesCompanion(failures: Value(failures)));
    return failures;
  });

  @override
  Future<void> recordPinSuccess(String deviceId, DateTime at) async {
    await (_db.update(
      _db.pinDevices,
    )..where((d) => d.id.equals(deviceId))).write(
      PinDevicesCompanion(
        failures: const Value(0),
        lastUsedAt: Value(at.toUtc().millisecondsSinceEpoch),
      ),
    );
  }

  @override
  Future<bool> removePinDevice({
    required String accountId,
    required String deviceId,
    required String reason,
    required DateTime at,
  }) => _db.transaction(() async {
    final removed = await (_db.delete(
      _db.pinDevices,
    )..where((d) => d.id.equals(deviceId) & d.userId.equals(accountId))).go();
    if (removed == 0) return false;
    await audit(at: at, action: reason, actorId: accountId, detail: deviceId);
    return true;
  });

  @override
  Future<void> audit({
    required DateTime at,
    required String action,
    String? actorId,
    String? detail,
  }) => _db.transaction(() async {
    final last =
        await (_db.select(_db.auditEntries)
              ..orderBy([(e) => OrderingTerm.desc(e.seq)])
              ..limit(1))
            .getSingleOrNull();
    final previous = last?.hash ?? AuditChain.genesis;
    await _db
        .into(_db.auditEntries)
        .insert(
          AuditEntriesCompanion.insert(
            at: at.toUtc().millisecondsSinceEpoch,
            actorId: Value(actorId),
            action: action,
            detail: Value(detail),
            prevHash: previous,
            hash: AuditChain.hashOf(
              previousHash: previous,
              at: at,
              actorId: actorId,
              action: action,
              detail: detail,
            ),
          ),
        );
  });

  @override
  Future<List<AccountWithStatus>> listAccounts() async {
    final rows =
        await (_db.select(_db.users)..orderBy([
              (u) => OrderingTerm.asc(u.role),
              (u) => OrderingTerm.asc(u.username),
            ]))
            .get();
    return [for (final row in rows) _managedOf(row)];
  }

  Expression<bool> _matching(UserQuery query) {
    final users = _db.users;
    Expression<bool> where = const Constant(true);
    final term = query.search.trim().toLowerCase();
    if (term.isNotEmpty) {
      // `instr` takes the term as plain text; `LIKE` would give `%` and `_`
      // a meaning of their own. SQLite lower-cases ASCII letters only.
      Expression<bool> has(Expression<String> column) =>
          FunctionCallExpression<int>('instr', [
            column.lower(),
            Variable<String>(term),
          ]).isBiggerThanValue(0);
      where =
          where &
          (has(users.displayName) |
              has(users.username) |
              has(users.email) |
              has(users.phone));
    }
    if (query.role != null) where = where & users.role.equals(query.role!.name);
    if (query.status != null) {
      where = where & users.status.equals(query.status!);
    }
    if (query.excludeId != null) {
      where = where & users.id.equals(query.excludeId!).not();
    }
    return where;
  }

  @override
  Future<AccountsPage> listAccountsPage(UserQuery query) async {
    final users = _db.users;
    final mode = query.descending ? OrderingMode.desc : OrderingMode.asc;
    final Expression<Object> key = switch (query.sort) {
      UserSort.name => users.displayName.lower(),
      UserSort.username => users.username,
      UserSort.role => users.role,
      UserSort.status => users.status,
      UserSort.created => users.createdAt,
    };
    final rows =
        await (_db.select(users)
              ..where((_) => _matching(query))
              // The id breaks ties, so a row never moves between two pages.
              ..orderBy([
                (_) => OrderingTerm(expression: key, mode: mode),
                (u) => OrderingTerm(expression: u.id),
              ])
              ..limit(query.limit, offset: query.offset))
            .get();
    final count = users.id.count();
    final total =
        await (_db.selectOnly(users)
              ..addColumns([count])
              ..where(_matching(query)))
            .map((row) => row.read(count))
            .getSingle();
    return AccountsPage(
      rows: [for (final row in rows) _managedOf(row)],
      total: total ?? 0,
    );
  }

  @override
  Future<AccountWithStatus?> findAccountById(String accountId) async {
    final row = await (_db.select(
      _db.users,
    )..where((u) => u.id.equals(accountId))).getSingleOrNull();
    return row == null ? null : _managedOf(row);
  }

  @override
  Future<bool> usernameInUse(
    String username, {
    required String exceptAccountId,
  }) async {
    final name = username.trim().toLowerCase();
    final row =
        await (_db.select(_db.users)
              ..where(
                (u) =>
                    u.username.equals(name) &
                    u.id.equals(exceptAccountId).not(),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  @override
  Future<Account> createManagedUser({
    required Account account,
    required String passwordHash,
    required String actorId,
    required DateTime at,
  }) => _db.transaction(() async {
    await _db
        .into(_db.users)
        .insert(
          UsersCompanion.insert(
            id: account.id,
            username: account.username,
            displayName: account.displayName,
            email: Value(account.email),
            firstName: Value(account.firstName),
            lastName: Value(account.lastName),
            phone: Value(account.phone),
            role: account.role.name,
            passwordHash: passwordHash,
            createdAt: account.createdAt.toUtc().millisecondsSinceEpoch,
          ),
        );
    await audit(
      at: at,
      action: 'user.created',
      actorId: actorId,
      detail: account.username,
    );
    return _stored(account.id);
  });

  @override
  Future<Account> updateManagedUser({
    required String accountId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String? status,
    required String actorId,
    required DateTime at,
  }) => _db.transaction(() async {
    final displayName = '${firstName.trim()} ${lastName.trim()}'.trim();
    await (_db.update(_db.users)..where((u) => u.id.equals(accountId))).write(
      UsersCompanion(
        firstName: Value(firstName.trim()),
        lastName: Value(lastName.trim()),
        displayName: Value(displayName),
        email: Value(email),
        phone: Value(phone.trim()),
        status: status == null ? const Value.absent() : Value(status),
      ),
    );
    await audit(
      at: at,
      action: status == 'inactive' ? 'user.deactivated' : 'user.updated',
      actorId: actorId,
      detail: accountId,
    );
    return _stored(accountId);
  });

  @override
  Future<List<String>> getUserScopes(String userId) async {
    final rows =
        await (_db.select(_db.userScopeAssignments)
              ..where((s) => s.userId.equals(userId))
              ..orderBy([(s) => OrderingTerm.asc(s.scopeId)]))
            .get();
    return [for (final row in rows) row.scopeId];
  }

  @override
  Future<void> removeScopeEverywhere({
    required String scopeId,
    required String actorId,
    required DateTime at,
  }) => _db.transaction(() async {
    await (_db.delete(
      _db.userScopeAssignments,
    )..where((s) => s.scopeId.equals(scopeId))).go();
    await audit(
      at: at,
      action: 'user.scope_removed',
      actorId: actorId,
      detail: scopeId,
    );
  });

  @override
  Future<void> setUserScopes({
    required String userId,
    required List<String> scopeIds,
    required String actorId,
    required DateTime at,
  }) => _db.transaction(() async {
    await (_db.delete(
      _db.userScopeAssignments,
    )..where((s) => s.userId.equals(userId))).go();
    for (final scopeId in scopeIds) {
      await _db
          .into(_db.userScopeAssignments)
          .insert(
            UserScopeAssignmentsCompanion.insert(
              userId: userId,
              scopeId: scopeId,
            ),
          );
    }
    await audit(
      at: at,
      action: 'user.scopes_updated',
      actorId: actorId,
      detail: userId,
    );
  });

  @override
  Future<bool> auditTrailIsIntact() async {
    final entries = await (_db.select(
      _db.auditEntries,
    )..orderBy([(e) => OrderingTerm.asc(e.seq)])).get();
    var previous = AuditChain.genesis;
    for (final entry in entries) {
      final expected = AuditChain.hashOf(
        previousHash: previous,
        at: DateTime.fromMillisecondsSinceEpoch(entry.at, isUtc: true),
        actorId: entry.actorId,
        action: entry.action,
        detail: entry.detail,
      );
      if (entry.prevHash != previous || entry.hash != expected) return false;
      previous = entry.hash;
    }
    return true;
  }
}
