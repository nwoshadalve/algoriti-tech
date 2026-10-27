import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/account.dart';
import '../domain/account_repository.dart';
import '../domain/audit_chain.dart';

final class DriftAccountRepository implements AccountRepository {
  DriftAccountRepository(this._db);

  final AppDatabase _db;

  Account _accountOf(UserRow row) => Account(
    id: row.id,
    username: row.username,
    displayName: row.displayName,
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
    await audit(at: at, action: 'auth.password_reset', actorId: accountId);
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
