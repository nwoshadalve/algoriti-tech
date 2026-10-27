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
final class ClaimRefused extends RegisterResult implements VerifyClaimResult {
  const ClaimRefused(this.reason, {required this.attemptsLeft});

  final ClaimCheck reason;
  final int attemptsLeft;
}

/// An admin already exists; the registration page is closed for good.
final class AdminAlreadyRegistered extends RegisterResult
    implements VerifyClaimResult {
  const AdminAlreadyRegistered();
}

final class CredentialsRefused extends RegisterResult {
  const CredentialsRefused(this.problem);

  final CredentialProblem problem;
}

sealed class VerifyClaimResult {
  const VerifyClaimResult();
}

/// The claim code matches the tablet; it is not used up until registration.
final class ClaimVerified extends VerifyClaimResult {
  const ClaimVerified();
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

/// First step of a password reset: prove the activation key.
sealed class ResetStartResult {
  const ResetStartResult();
}

/// The key was right: [ticket] lets the owner choose a new password until
/// [expiresAt]. Shown once; only its hash is kept.
final class ResetTicketIssued extends ResetStartResult {
  const ResetTicketIssued(this.ticket, this.expiresAt);

  final String ticket;
  final DateTime expiresAt;
}

/// The activation key or the username was not accepted (never says which).
final class ResetRefused extends ResetStartResult {
  const ResetRefused();
}

/// Second step: choose the new password with the ticket.
sealed class ResetFinishResult {
  const ResetFinishResult();
}

/// The password was changed and every sign-in of the account ended.
final class PasswordWasReset extends ResetFinishResult {
  const PasswordWasReset();
}

/// The ticket is unknown, used or expired: start again.
final class ResetTicketInvalid extends ResetFinishResult {
  const ResetTicketInvalid();
}

final class ResetCredentialsRefused extends ResetFinishResult {
  const ResetCredentialsRefused(this.problem);

  final CredentialProblem problem;
}

/// Too many failures; try again after [retryAfter].
final class ResetThrottled implements ResetStartResult, ResetFinishResult {
  const ResetThrottled(this.retryAfter);

  final Duration retryAfter;
}

class _ResetTicket {
  const _ResetTicket(this.accountId, this.username, this.expiresAt);

  final String accountId;
  final String username;
  final DateTime expiresAt;
}

/// Accounts and sign-in: registering the first admin, logging in and out,
/// resetting a forgotten password, and telling who a token belongs to.
/// Everything sensitive is audited.
class AccessService {
  AccessService({
    required this._repository,
    required this._hasher,
    required this._claimCodes,
    required this._throttle,
    required this._clock,
    required this._newId,
    required this._licenseKey,
    Random? random,
    this.sessionLifetime = const Duration(hours: 12),
    this.resetLifetime = const Duration(minutes: 10),
  }) : _random = random ?? Random.secure();

  final AccountRepository _repository;
  final PasswordHasher _hasher;
  final ClaimCodes _claimCodes;
  final LoginThrottle _throttle;
  final Clock _clock;
  final IdGenerator _newId;

  /// The activation key stored on this tablet.
  final Future<String?> Function() _licenseKey;
  final Random _random;
  final Duration sessionLifetime;

  /// How long the ticket from a verified activation key stays usable.
  final Duration resetLifetime;

  /// Tickets in memory only: a restart of the app ends them.
  final _tickets = <String, _ResetTicket>{};

  static const _maxTickets = 8;

  Future<bool> get hasAdmin async => await _repository.adminCount() > 0;

  /// Checks the claim code before the registration form. Does not consume it.
  Future<VerifyClaimResult> verifyClaimCode(String claimCode) async {
    if (await hasAdmin) return const AdminAlreadyRegistered();
    final claim = _claimCodes.check(claimCode);
    if (claim != ClaimCheck.ok) {
      await _repository.audit(
        at: _clock(),
        action: 'admin.claim_refused',
        detail: claim.name,
      );
      return ClaimRefused(claim, attemptsLeft: _claimCodes.attemptsLeft);
    }
    return const ClaimVerified();
  }

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

  /// Step 1 of a forgotten-password reset. When [activationKey] is the key
  /// this tablet was activated with (the clinic owner or the vendor holds it)
  /// and [username] exists, returns a ticket for step 2. Works offline.
  ///
  /// A wrong key and an unknown username give the same answer, and attempts
  /// are slowed down per client and for the whole tablet.
  Future<ResetStartResult> startReset({
    required String username,
    required String activationKey,
    required String clientKey,
  }) async {
    final keys = ['reset:client:$clientKey', 'reset:all'];
    for (final key in keys) {
      final wait = _throttle.waitFor(key);
      if (wait != null) return ResetThrottled(wait);
    }

    final name = AccessPolicy.normalizeUsername(username);
    final stored = await _licenseKey();
    final keyMatches =
        stored != null && _sameKey(_keyForm(stored), _keyForm(activationKey));
    final target = keyMatches ? await _repository.findCredentials(name) : null;
    if (target == null) {
      keys.forEach(_throttle.recordFailure);
      await _repository.audit(
        at: _clock(),
        action: 'auth.reset_refused',
        detail: keyMatches ? 'unknown user' : 'wrong key',
      );
      return const ResetRefused();
    }

    keys.forEach(_throttle.recordSuccess);
    final now = _clock().toUtc();
    _tickets.removeWhere(
      (_, t) => t.accountId == target.account.id || !now.isBefore(t.expiresAt),
    );
    while (_tickets.length >= _maxTickets) {
      _tickets.remove(_tickets.keys.first);
    }
    final ticket = _newToken();
    final expiresAt = now.add(resetLifetime);
    _tickets[_hashToken(ticket)] = _ResetTicket(
      target.account.id,
      name,
      expiresAt,
    );
    await _repository.audit(
      at: now,
      action: 'auth.reset_key_accepted',
      actorId: target.account.id,
    );
    return ResetTicketIssued(ticket, expiresAt);
  }

  /// Step 2: sets the new password for the account the [ticket] belongs to.
  /// Every sign-in of the account ends, any lockout on it is lifted, and the
  /// reset is audited. A refused password keeps the ticket, so the owner can
  /// try another one.
  Future<ResetFinishResult> finishReset({
    required String ticket,
    required String newPassword,
    required String clientKey,
  }) async {
    final limit = 'reset:client:$clientKey';
    final wait = _throttle.waitFor(limit);
    if (wait != null) return ResetThrottled(wait);

    final now = _clock().toUtc();
    final hash = _hashToken(ticket);
    final found = _tickets[hash];
    if (found == null || !now.isBefore(found.expiresAt)) {
      _tickets.remove(hash);
      _throttle.recordFailure(limit);
      return const ResetTicketInvalid();
    }

    final problem = AccessPolicy.check(
      username: found.username,
      password: newPassword,
    );
    if (problem != null) return ResetCredentialsRefused(problem);

    await _repository.resetPassword(
      accountId: found.accountId,
      passwordHash: await _hasher.hash(newPassword),
      at: now,
    );
    _tickets.removeWhere((_, t) => t.accountId == found.accountId);
    _throttle.recordSuccess('user:${found.username}');
    return const PasswordWasReset();
  }

  /// Case, spaces and dashes do not matter when the key is pasted.
  static String _keyForm(String key) =>
      key.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

  /// Compares without stopping at the first difference.
  static bool _sameKey(String a, String b) {
    var diff = a.length ^ b.length;
    for (var i = 0; i < a.length && i < b.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
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
