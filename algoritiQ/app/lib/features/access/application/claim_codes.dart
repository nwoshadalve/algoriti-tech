// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:math';

import '../../../core/clock.dart';

/// A one-time code shown on the tablet screen. Registering the first admin
/// from a browser needs it, so only someone holding the tablet can do it.
final class ClaimCode {
  const ClaimCode({required this.code, required this.expiresAt});

  /// Eight characters, e.g. `7K4M9XQ2`.
  final String code;
  final DateTime expiresAt;

  /// Easier to read and type: `7K4M-9XQ2`.
  String get display => '${code.substring(0, 4)}-${code.substring(4)}';
}

/// Why a typed code was refused.
enum ClaimCheck { ok, wrong, expired, locked }

/// Issues and checks claim codes. Kept in memory only: a restart simply
/// shows a new code.
///
/// A code expires after [lifetime], dies after [maxAttempts] wrong guesses
/// and can be used once.
class ClaimCodes {
  ClaimCodes({
    required this._clock,
    Random? random,
    this.lifetime = const Duration(minutes: 15),
    this.maxAttempts = 5,
  }) : _random = random ?? Random.secure();

  final Clock _clock;
  final Random _random;
  final Duration lifetime;
  final int maxAttempts;

  // Crockford base32 without look-alikes (no I, L, O, U).
  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  ClaimCode? _current;
  int _wrongAttempts = 0;

  /// The code to show now; a fresh one when there is none, it expired, was
  /// used, or too many wrong codes were tried.
  ClaimCode current() {
    final code = _current;
    if (code != null &&
        _clock().isBefore(code.expiresAt) &&
        _wrongAttempts < maxAttempts) {
      return code;
    }
    return refresh();
  }

  /// Replaces the code (the "new code" button).
  ClaimCode refresh() {
    _wrongAttempts = 0;
    return _current = ClaimCode(
      code: String.fromCharCodes([
        for (var i = 0; i < 8; i++)
          _alphabet.codeUnitAt(_random.nextInt(_alphabet.length)),
      ]),
      expiresAt: _clock().add(lifetime),
    );
  }

  /// Checks [input] without using the code up (see [consume]).
  ClaimCheck check(String input) {
    final code = _current;
    if (code == null) return ClaimCheck.expired;
    if (_wrongAttempts >= maxAttempts) return ClaimCheck.locked;
    if (!_clock().isBefore(code.expiresAt)) return ClaimCheck.expired;
    if (_sameCode(_normalize(input), code.code)) return ClaimCheck.ok;
    _wrongAttempts++;
    return _wrongAttempts >= maxAttempts ? ClaimCheck.locked : ClaimCheck.wrong;
  }

  /// Uses the code up. Call after the registration it unlocked succeeded.
  void consume() => _current = null;

  /// Wrong guesses left before the code is locked.
  int get attemptsLeft => max(0, maxAttempts - _wrongAttempts);

  String _normalize(String input) =>
      input.toUpperCase().replaceAll(RegExp(r'[^0-9A-Z]'), '');

  bool _sameCode(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
