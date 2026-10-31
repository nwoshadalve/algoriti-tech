// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
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

sealed class ProfileResult {
  const ProfileResult();
}

final class ProfileSaved extends ProfileResult {
  const ProfileSaved(this.account);

  final Account account;
}

final class ProfileRefused extends ProfileResult {
  const ProfileRefused(this.problem);

  final ProfileProblem problem;
}

sealed class ChangePasswordResult {
  const ChangePasswordResult();
}

final class PasswordChanged extends ChangePasswordResult {
  const PasswordChanged();
}

/// The current password given was not the account's.
final class CurrentPasswordWrong extends ChangePasswordResult {
  const CurrentPasswordWrong();
}

final class NewPasswordRefused extends ChangePasswordResult {
  const NewPasswordRefused(this.problem);

  final CredentialProblem problem;
}

/// The new password is the one already in use.
final class NewPasswordSame extends ChangePasswordResult {
  const NewPasswordSame();
}

final class ChangeThrottled extends ChangePasswordResult {
  const ChangeThrottled(this.retryAfter);

  final Duration retryAfter;
}

sealed class PhotoResult {
  const PhotoResult();
}

final class PhotoSaved extends PhotoResult {
  const PhotoSaved(this.account);

  final Account account;
}

/// Not a JPEG, PNG or WebP picture.
final class PhotoUnsupported extends PhotoResult {
  const PhotoUnsupported();
}

final class PhotoTooLarge extends PhotoResult {
  const PhotoTooLarge();
}

sealed class SetPinResult {
  const SetPinResult();
}

final class PinSet extends SetPinResult {
  const PinSet({required this.deviceToken, required this.device});

  /// Shown once. The browser keeps it; the tablet keeps only its hash.
  final String deviceToken;
  final PinDeviceInfo device;
}

final class PinPasswordWrong extends SetPinResult {
  const PinPasswordWrong();
}

final class PinRefused extends SetPinResult {
  const PinRefused(this.problem);

  final PinProblem problem;
}

final class PinSetThrottled extends SetPinResult {
  const PinSetThrottled(this.retryAfter);

  final Duration retryAfter;
}

sealed class PinLoginResult {
  const PinLoginResult();
}

final class PinLoggedIn extends PinLoginResult {
  const PinLoggedIn(this.session);

  final LoggedIn session;
}

/// A wrong PIN; [attemptsLeft] more and the browser's PIN is switched off.
final class PinWrong extends PinLoginResult {
  const PinWrong(this.attemptsLeft);

  final int attemptsLeft;
}

/// Too many wrong PINs: this browser's PIN was just removed.
final class PinLocked extends PinLoginResult {
  const PinLocked();
}

/// Unknown or removed browser, or the account cannot sign in. The browser
/// should forget its PIN and ask for the password.
final class PinUnavailable extends PinLoginResult {
  const PinUnavailable();
}

final class PinLoginThrottled extends PinLoginResult {
  const PinLoginThrottled(this.retryAfter);

  final Duration retryAfter;
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
    this.rememberLifetime = const Duration(days: 30),
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

  /// How long a sign-in lasts when the person asked to be remembered.
  final Duration rememberLifetime;

  /// Wrong PINs in a row before a browser's PIN is removed.
  static const maxPinFailures = 3;

  /// PIN browsers kept per person; setting another drops the oldest.
  static const maxPinDevices = 5;

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
    required String firstName,
    required String lastName,
    required String email,
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
    if (AccessPolicy.checkEmail(email) != null) {
      return const CredentialsRefused(CredentialProblem.emailInvalid);
    }
    final problem = AccessPolicy.check(username: username, password: password);
    if (problem != null) return CredentialsRefused(problem);

    final name = AccessPolicy.normalizeUsername(username);
    final displayName = '${firstName.trim()} ${lastName.trim()}'.trim();
    final account = Account(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      id: _newId(),
      username: name,
      displayName: displayName.isEmpty ? name : displayName,
      email: AccessPolicy.normalizeEmail(email),
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

  /// Signs in with the username or, when [username] holds an `@`, the email
  /// address of the account (usernames never contain `@`).
  Future<LoginResult> login({
    required String username,
    required String password,
    required String clientKey,
    bool remember = false,
  }) async {
    final name = AccessPolicy.normalizeUsername(username);
    final byEmail = name.contains('@');
    final keys = ['user:$name', 'client:$clientKey'];
    for (final key in keys) {
      final wait = _throttle.waitFor(key);
      if (wait != null) return TooManyAttempts(wait);
    }

    final stored = byEmail
        ? await _repository.findCredentialsByEmail(name)
        : await _repository.findCredentials(name);
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
    return _openSession(
      stored.account,
      remember: remember,
      action: 'auth.login',
    );
  }

  Future<LoggedIn> _openSession(
    Account account, {
    required bool remember,
    required String action,
  }) async {
    final token = _newToken();
    final now = _clock().toUtc();
    final expiresAt = now.add(remember ? rememberLifetime : sessionLifetime);
    await _repository.saveSession(
      id: _newId(),
      accountId: account.id,
      tokenHash: _hashToken(token),
      createdAt: now,
      expiresAt: expiresAt,
    );
    await _repository.audit(at: now, action: action, actorId: account.id);
    return LoggedIn(token: token, expiresAt: expiresAt, account: account);
  }

  /// Lets the signed-in person sign in to **this browser** with a PIN. Needs
  /// the password, so a borrowed, unlocked browser cannot set one. The tablet
  /// returns a secret for the browser to keep; the PIN works only with it.
  Future<SetPinResult> setPin({
    required Account account,
    required String password,
    required String pin,
    required String label,
    String? replaceDeviceId,
  }) async {
    final limit = 'pin-set:${account.id}';
    final wait = _throttle.waitFor(limit);
    if (wait != null) return PinSetThrottled(wait);

    final stored = await _repository.findCredentials(account.username);
    final valid =
        stored != null && await _hasher.verify(password, stored.passwordHash);
    if (!valid) {
      _throttle.recordFailure(limit);
      await _repository.audit(
        at: _clock(),
        action: 'auth.pin_set_refused',
        actorId: account.id,
      );
      return const PinPasswordWrong();
    }
    _throttle.recordSuccess(limit);
    final problem = AccessPolicy.checkPin(pin);
    if (problem != null) return PinRefused(problem);

    final token = _newToken();
    final id = _newId();
    final now = _clock().toUtc();
    final cleanLabel = label.trim();
    await _repository.savePinDevice(
      id: id,
      accountId: account.id,
      tokenHash: _hashToken(token),
      pinHash: await _hasher.hash(pin),
      label: cleanLabel.length > 80 ? cleanLabel.substring(0, 80) : cleanLabel,
      at: now,
      keepAtMost: maxPinDevices,
      replaceDeviceId: replaceDeviceId,
    );
    return PinSet(
      deviceToken: token,
      device: PinDeviceInfo(
        id: id,
        label: cleanLabel,
        createdAt: now,
        lastUsedAt: null,
      ),
    );
  }

  /// Signs in with a PIN from a browser that holds [deviceToken]. Wrong PINs
  /// are slowed down, and [maxPinFailures] in a row remove the browser's PIN:
  /// from then on only the password works there.
  Future<PinLoginResult> loginWithPin({
    required String deviceToken,
    required String pin,
    required String clientKey,
  }) async {
    final device = await _repository.findPinDevice(_hashToken(deviceToken));
    if (device == null) {
      // Same work as a real check, so timing does not tell the difference.
      await _hasher.verify(pin, _decoyHash);
      return const PinUnavailable();
    }
    final keys = ['pin:${device.id}', 'client:$clientKey'];
    for (final key in keys) {
      final wait = _throttle.waitFor(key);
      if (wait != null) return PinLoginThrottled(wait);
    }

    if (!await _hasher.verify(pin, device.pinHash)) {
      keys.forEach(_throttle.recordFailure);
      final failures = await _repository.recordPinFailure(device.id);
      await _repository.audit(
        at: _clock(),
        action: 'auth.pin_failed',
        actorId: device.account.id,
        detail: device.id,
      );
      if (failures >= maxPinFailures) {
        await _repository.removePinDevice(
          accountId: device.account.id,
          deviceId: device.id,
          reason: 'auth.pin_locked',
          at: _clock().toUtc(),
        );
        return const PinLocked();
      }
      return PinWrong(maxPinFailures - failures);
    }

    keys.forEach(_throttle.recordSuccess);
    await _repository.recordPinSuccess(device.id, _clock().toUtc());
    return PinLoggedIn(
      await _openSession(
        device.account,
        remember: false,
        action: 'auth.pin_login',
      ),
    );
  }

  Future<List<PinDeviceInfo>> pinDevices(Account account) =>
      _repository.listPinDevices(account.id);

  /// False when the person has no such PIN browser.
  Future<bool> removePinDevice(Account account, String deviceId) =>
      _repository.removePinDevice(
        accountId: account.id,
        deviceId: deviceId,
        reason: 'auth.pin_removed',
        at: _clock().toUtc(),
      );

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

  /// Changes the signed-in person's own name, email and phone.
  Future<ProfileResult> updateProfile({
    required String accountId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    final problem = AccessPolicy.checkProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
    if (problem != null) return ProfileRefused(problem);
    final normalized = AccessPolicy.normalizeEmail(email);
    if (await _repository.emailInUse(normalized, exceptAccountId: accountId)) {
      return const ProfileRefused(ProfileProblem.emailTaken);
    }
    return ProfileSaved(
      await _repository.updateProfile(
        accountId: accountId,
        firstName: firstName,
        lastName: lastName,
        email: normalized,
        phone: phone,
        at: _clock().toUtc(),
      ),
    );
  }

  /// Changes the signed-in person's own password. Needs the current one, so a
  /// borrowed, unlocked browser cannot lock the owner out. Wrong guesses are
  /// slowed down. Every other sign-in of the account ends; [token] stays.
  Future<ChangePasswordResult> changePassword({
    required Account account,
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final limit = 'password:${account.id}';
    final wait = _throttle.waitFor(limit);
    if (wait != null) return ChangeThrottled(wait);

    final stored = await _repository.findCredentials(account.username);
    final valid =
        stored != null &&
        await _hasher.verify(currentPassword, stored.passwordHash);
    if (!valid) {
      _throttle.recordFailure(limit);
      await _repository.audit(
        at: _clock(),
        action: 'auth.password_change_refused',
        actorId: account.id,
      );
      return const CurrentPasswordWrong();
    }
    _throttle.recordSuccess(limit);

    final problem = AccessPolicy.check(
      username: account.username,
      password: newPassword,
    );
    if (problem != null) return NewPasswordRefused(problem);
    if (newPassword == currentPassword) return const NewPasswordSame();

    await _repository.changePassword(
      accountId: account.id,
      passwordHash: await _hasher.hash(newPassword),
      keepTokenHash: _hashToken(token),
      at: _clock().toUtc(),
    );
    return const PasswordChanged();
  }

  Future<PhotoResult> changePhoto({
    required String accountId,
    required List<int> bytes,
  }) async {
    if (bytes.length > AccessPolicy.maxPhotoBytes) {
      return const PhotoTooLarge();
    }
    if (AccessPolicy.imageType(bytes) == null) return const PhotoUnsupported();
    return PhotoSaved(
      await _repository.setPhoto(
        accountId: accountId,
        bytes: bytes,
        at: _clock().toUtc(),
      ),
    );
  }

  Future<Account> removePhoto(String accountId) => _repository.setPhoto(
    accountId: accountId,
    bytes: null,
    at: _clock().toUtc(),
  );

  Future<List<int>?> photoOf(String accountId) =>
      _repository.photoOf(accountId);

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
