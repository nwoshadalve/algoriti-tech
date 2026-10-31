// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../../../core/clock.dart';
import '../../../core/id_generator.dart';
import '../../clinic/domain/chamber.dart';
import '../../clinic/domain/clinic_repository.dart';
import '../../clinic/domain/doctor.dart';
import '../../licensing/domain/license_core.dart';
import '../domain/access_policy.dart';
import '../domain/account.dart';
import '../domain/account_repository.dart';
import '../domain/password_hasher.dart';
import '../domain/user_query.dart';

/// Thrown when a signed-in person is not an admin.
final class UserManagementForbidden implements Exception {
  const UserManagementForbidden();
}

enum AssignmentTarget { chamber, doctor }

final class ScopeTarget {
  const ScopeTarget({required this.id, required this.name});

  final String id;
  final String name;
}

final class UsersOnboarding {
  const UsersOnboarding({required this.needsAttention});

  final bool needsAttention;
}

final class UsersContext {
  const UsersContext({
    required this.licenseType,
    required this.assignmentTarget,
    required this.targets,
    required this.onboarding,
  });

  final LicenseType? licenseType;
  final AssignmentTarget assignmentTarget;
  final List<ScopeTarget> targets;
  final UsersOnboarding onboarding;
}

final class ManagedUser {
  const ManagedUser({
    required this.account,
    required this.status,
    required this.scopeIds,
  });

  final Account account;
  final String status;

  /// Chambers (or doctors) a receptionist works for; always empty for admins.
  final List<String> scopeIds;
}

/// One page of [ManagedUser]s.
final class ManagedUsersPage {
  const ManagedUsersPage({
    required this.users,
    required this.total,
    required this.nextOffset,
  });

  final List<ManagedUser> users;

  /// Everything that matched the query, not only this page.
  final int total;

  /// Where the next page starts, or null when this was the last one.
  final int? nextOffset;
}

sealed class CreateUserResult {
  const CreateUserResult();
}

final class UserCreated extends CreateUserResult {
  const UserCreated(this.user);

  final ManagedUser user;
}

final class CreateUserRefused extends CreateUserResult {
  const CreateUserRefused(this.problem);

  final CreateUserProblem problem;
}

enum CreateUserProblem {
  usernameTaken,
  emailTaken,
  scopeInvalid,
  credentialsInvalid,
}

sealed class UpdateUserResult {
  const UpdateUserResult();
}

final class UserUpdated extends UpdateUserResult {
  const UserUpdated(this.user);

  final ManagedUser user;
}

final class UpdateUserRefused extends UpdateUserResult {
  const UpdateUserRefused(this.problem);

  final UpdateUserProblem problem;
}

enum UpdateUserProblem {
  notFound,
  emailTaken,
  scopeInvalid,
  profileInvalid,
  statusInvalid,

  /// An admin cannot disable their own account.
  cannotDisableSelf,

  /// The last active admin cannot be disabled: nobody could sign in to fix it.
  lastAdmin,
}

/// Admin-only creation and maintenance of accounts (admins and receptionists).
class UserManagementService {
  UserManagementService({
    required this._repository,
    required this._clinic,
    required this._hasher,
    required this._clock,
    required this._newId,
    required this._licensePayload,
  });

  final AccountRepository _repository;
  final ClinicRepository _clinic;
  final PasswordHasher _hasher;
  final Clock _clock;
  final IdGenerator _newId;
  final Future<LicensePayload?> Function() _licensePayload;

  void requireAdmin(Account account) {
    if (account.role != Role.admin) throw const UserManagementForbidden();
  }

  Future<UsersContext> loadContext(Account admin) async {
    requireAdmin(admin);
    final payload = await _licensePayload();
    final assignmentTarget = payload?.type == LicenseType.chamber
        ? AssignmentTarget.doctor
        : AssignmentTarget.chamber;
    final targets = await _loadTargets(assignmentTarget);
    final receptionists = <ManagedUser>[
      for (final row in await _repository.listAccounts())
        if (row.account.role == Role.receptionist)
          ManagedUser(
            account: row.account,
            status: row.status,
            scopeIds: await _repository.getUserScopes(row.account.id),
          ),
    ];
    final hasActiveReceptionist = receptionists.any(
      (u) => u.status == 'active',
    );
    final needsAttention =
        targets.isNotEmpty &&
        (!hasActiveReceptionist ||
            receptionists.any((u) => u.scopeIds.isEmpty));
    return UsersContext(
      licenseType: payload?.type,
      assignmentTarget: assignmentTarget,
      targets: targets,
      onboarding: UsersOnboarding(needsAttention: needsAttention),
    );
  }

  /// One page of the users that match [query]. The limit is kept between 1 and
  /// [UserQuery.maxLimit].
  Future<ManagedUsersPage> listUsers(
    Account admin, {
    UserQuery query = const UserQuery(),
  }) async {
    requireAdmin(admin);
    final limit = query.limit.clamp(1, UserQuery.maxLimit);
    final offset = query.offset < 0 ? 0 : query.offset;
    final page = await _repository.listAccountsPage(
      UserQuery(
        search: query.search,
        role: query.role,
        status: query.status,
        // Admins manage other people; their own account is in Settings.
        excludeId: admin.id,
        sort: query.sort,
        descending: query.descending,
        offset: offset,
        limit: limit,
      ),
    );
    final end = offset + page.rows.length;
    return ManagedUsersPage(
      users: [
        for (final row in page.rows)
          ManagedUser(
            account: row.account,
            status: row.status,
            scopeIds: row.account.role == Role.receptionist
                ? await _repository.getUserScopes(row.account.id)
                : const [],
          ),
      ],
      total: page.total,
      nextOffset: end < page.total && page.rows.isNotEmpty ? end : null,
    );
  }

  Future<CreateUserResult> createUser({
    required Account admin,
    required Role role,
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required List<String> scopeIds,
  }) async {
    requireAdmin(admin);
    if (AccessPolicy.checkEmail(email) != null) {
      return const CreateUserRefused(CreateUserProblem.credentialsInvalid);
    }
    final credentialProblem = AccessPolicy.check(
      username: username,
      password: password,
    );
    if (credentialProblem != null) {
      return const CreateUserRefused(CreateUserProblem.credentialsInvalid);
    }
    final name = AccessPolicy.normalizeUsername(username);
    if (await _repository.usernameInUse(name, exceptAccountId: '')) {
      return const CreateUserRefused(CreateUserProblem.usernameTaken);
    }
    final normalizedEmail = AccessPolicy.normalizeEmail(email);
    if (await _repository.emailInUse(normalizedEmail, exceptAccountId: '')) {
      return const CreateUserRefused(CreateUserProblem.emailTaken);
    }
    // Admins work for the whole clinic; only receptionists have a scope.
    final scopes = role == Role.receptionist ? scopeIds : const <String>[];
    final context = await loadContext(admin);
    if (!_scopesValid(scopes, context)) {
      return const CreateUserRefused(CreateUserProblem.scopeInvalid);
    }

    final displayName = '${firstName.trim()} ${lastName.trim()}'.trim();
    final now = _clock().toUtc();
    final account = Account(
      id: _newId(),
      username: name,
      displayName: displayName.isEmpty ? name : displayName,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: normalizedEmail,
      role: role,
      createdAt: now,
    );
    await _repository.createManagedUser(
      account: account,
      passwordHash: await _hasher.hash(password),
      actorId: admin.id,
      at: now,
    );
    if (scopes.isNotEmpty) {
      await _repository.setUserScopes(
        userId: account.id,
        scopeIds: scopes,
        actorId: admin.id,
        at: now,
      );
    }
    return UserCreated(
      ManagedUser(account: account, status: 'active', scopeIds: scopes),
    );
  }

  Future<UpdateUserResult> updateUser({
    required Account admin,
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? status,
    List<String>? scopeIds,
  }) async {
    requireAdmin(admin);
    final stored = await _repository.findAccountById(userId);
    if (stored == null) {
      return const UpdateUserRefused(UpdateUserProblem.notFound);
    }
    if (status != null && status != 'active' && status != 'inactive') {
      return const UpdateUserRefused(UpdateUserProblem.statusInvalid);
    }
    if (status == 'inactive' && stored.status == 'active') {
      if (userId == admin.id) {
        return const UpdateUserRefused(UpdateUserProblem.cannotDisableSelf);
      }
      if (stored.account.role == Role.admin &&
          await _repository.adminCount() <= 1) {
        return const UpdateUserRefused(UpdateUserProblem.lastAdmin);
      }
    }
    final profileProblem = AccessPolicy.checkProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
    if (profileProblem != null) {
      return const UpdateUserRefused(UpdateUserProblem.profileInvalid);
    }
    final normalizedEmail = AccessPolicy.normalizeEmail(email);
    if (await _repository.emailInUse(
      normalizedEmail,
      exceptAccountId: userId,
    )) {
      return const UpdateUserRefused(UpdateUserProblem.emailTaken);
    }
    final isReceptionist = stored.account.role == Role.receptionist;
    final scopes = isReceptionist
        ? scopeIds ?? await _repository.getUserScopes(userId)
        : const <String>[];
    if (isReceptionist && scopeIds != null) {
      final context = await loadContext(admin);
      if (!_scopesValid(scopes, context)) {
        return const UpdateUserRefused(UpdateUserProblem.scopeInvalid);
      }
    }

    final now = _clock().toUtc();
    final updated = await _repository.updateManagedUser(
      accountId: userId,
      firstName: firstName,
      lastName: lastName,
      email: normalizedEmail,
      phone: phone,
      status: status,
      actorId: admin.id,
      at: now,
    );
    if (isReceptionist && scopeIds != null) {
      await _repository.setUserScopes(
        userId: userId,
        scopeIds: scopeIds,
        actorId: admin.id,
        at: now,
      );
    }
    return UserUpdated(
      ManagedUser(
        account: updated,
        status: status ?? stored.status,
        scopeIds: scopes,
      ),
    );
  }

  bool _scopesValid(List<String> scopeIds, UsersContext context) {
    if (scopeIds.isEmpty) return true;
    final allowed = {for (final t in context.targets) t.id};
    return scopeIds.every(allowed.contains);
  }

  Future<List<ScopeTarget>> _loadTargets(AssignmentTarget target) async {
    switch (target) {
      case AssignmentTarget.chamber:
        final chambers = await _clinic.watchChambers().first;
        return [
          for (final Chamber(:id, :name) in chambers)
            ScopeTarget(id: id, name: name),
        ];
      case AssignmentTarget.doctor:
        final doctors = await _clinic.watchDoctors().first;
        return [
          for (final Doctor(:id, :name) in doctors)
            ScopeTarget(id: id, name: name),
        ];
    }
  }
}
