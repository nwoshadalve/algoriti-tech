import 'dart:convert';
import 'dart:math';

import 'package:cryptography/dart.dart';

import '../../../core/clock.dart';
import '../../../core/id_generator.dart';
import '../domain/access_policy.dart';
import '../domain/account.dart';
import '../domain/account_repository.dart';
import '../domain/password_hasher.dart';
import 'claim_codes.dart';
import 'login_throttle.dart';

sealed class RegisterResult {
  const RegisterResult();
}

final class Registered extends RegisterResult {
  const Registered(this.account);

  final Account account;
}

/// The claim code was wrong, expired or locked ([reason]).
final class ClaimRefused extends RegisterResult {
  const ClaimRefused(this.reason, {required this.attemptsLeft});

  final ClaimCheck reason;
  final int attemptsLeft;
}

/// An admin already exists; the registration page is closed for good.
final class AdminAlreadyRegistered extends RegisterResult {
  const AdminAlreadyRegistered();
}

final class CredentialsRefused extends RegisterResult {
  const CredentialsRefused(this.problem);

  final CredentialProblem problem;
}

sealed class LoginResult {
  const LoginResult();
}

final class LoggedIn extends LoginResult {
  const LoggedIn({
    required this.token,
    required this.expiresAt,
    required this.account,
  });

  /// Shown to the client once; only its hash is stored.
  final String token;
  final DateTime expiresAt;
  final Account account;
}

final class InvalidCredentials extends LoginResult {
  const InvalidCredentials();
}

/// Too many failures; try again after [retryAfter].
final class TooManyAttempts extends LoginResult {
  const TooManyAttempts(this.retryAfter);

  final Duration retryAfter;
}

/// Accounts and sign-in: registering the first admin, logging in and out,
/// and telling who a token belongs to. Everything sensitive is audited.
class AccessService {
  AccessService({
    required this._repository,
    required this._hasher,
    required this._claimCodes,
    required this._throttle,
    required this._clock,
    required this._newId,
    Random? random,
    this.sessionLifetime = const Duration(hours: 12),
  }) : _random = random ?? Random.secure();

  final AccountRepository _repository;
  final PasswordHasher _hasher;
  final ClaimCodes _claimCodes;
  final LoginThrottle _throttle;
  final Clock _clock;
  final IdGenerator _newId;
  final Random _random;
  final Duration sessionLifetime;

  Future<bool> get hasAdmin async => await _repository.adminCount() > 0;

  /// Registers the first admin. Needs the claim code shown on the tablet.
  Future<RegisterResult> registerAdmin({
    required String claimCode,
    required String username,
    required String displayName,
    required String password,
  }) async {
    if (await hasAdmin) return const AdminAlreadyRegistered();

    // The claim code is checked before anything else, so an outsider learns
    // nothing about the rules or the form.
    final claim = _claimCodes.check(claimCode);
    if (claim != ClaimCheck.ok) {
      await _repository.audit(
        at: _clock(),
        action: 'admin.claim_refused',
        detail: claim.name,
      );
      return ClaimRefused(claim, attemptsLeft: _claimCodes.attemptsLeft);
    }
    final problem = AccessPolicy.check(username: username, password: password);
    if (problem != null) return CredentialsRefused(problem);

    final name = AccessPolicy.normalizeUsername(username);
    final account = Account(
      id: _newId(),
      username: name,
      displayName: displayName.trim().isEmpty ? name : displayName.trim(),
      role: Role.admin,
      createdAt: _clock().toUtc(),
    );
    final created = await _repository.createFirstAdmin(
      account,
      await _hasher.hash(password),
    );
    if (!created) return const AdminAlreadyRegistered();
    _claimCodes.consume();
    return Registered(account);
  }

  Future<LoginResult> login({
    required String username,
    required String password,
    required String clientKey,
  }) async {
    final name = AccessPolicy.normalizeUsername(username);
    final keys = ['user:$name', 'client:$clientKey'];
    for (final key in keys) {
      final wait = _throttle.waitFor(key);
      if (wait != null) return TooManyAttempts(wait);
    }

    final stored = await _repository.findCredentials(name);
    // Unknown names do the same work, so timing does not reveal them.
    final valid = await _hasher.verify(
      password,
      stored?.passwordHash ?? _decoyHash,
    );
    if (stored == null || !valid) {
      keys.forEach(_throttle.recordFailure);
      await _repository.audit(
        at: _clock(),
        action: 'auth.login_failed',
        detail: name,
      );
      return const InvalidCredentials();
    }

    keys.forEach(_throttle.recordSuccess);
    final token = _newToken();
    final now = _clock().toUtc();
    final expiresAt = now.add(sessionLifetime);
    await _repository.saveSession(
      id: _newId(),
      accountId: stored.account.id,
      tokenHash: _hashToken(token),
      createdAt: now,
      expiresAt: expiresAt,
    );
    await _repository.audit(
      at: now,
      action: 'auth.login',
      actorId: stored.account.id,
    );
    return LoggedIn(
      token: token,
      expiresAt: expiresAt,
      account: stored.account,
    );
  }

  /// The account a token belongs to, or null if unknown, expired or revoked.
  Future<Account?> authenticate(String token) async {
    final session = await _repository.findSession(_hashToken(token));
    if (session == null || session.revoked) return null;
    if (!_clock().toUtc().isBefore(session.expiresAt)) return null;
    return session.account;
  }

  Future<void> logout(String token) async {
    final account = await authenticate(token);
    await _repository.revokeSession(_hashToken(token));
    if (account != null) {
      await _repository.audit(
        at: _clock(),
        action: 'auth.logout',
        actorId: account.id,
      );
    }
  }

  String _newToken() => base64Url
      .encode(List.generate(32, (_) => _random.nextInt(256)))
      .replaceAll('=', '');

  String _hashToken(String token) => [
    for (final byte in const DartSha256().hashSync(utf8.encode(token)).bytes)
      byte.toRadixString(16).padLeft(2, '0'),
  ].join();

  /// A well-formed hash nobody has the password for.
  static const _decoyHash =
      r'argon2id$m=8,t=1,p=1$AAAAAAAAAAAAAAAAAAAAAA==$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
}
