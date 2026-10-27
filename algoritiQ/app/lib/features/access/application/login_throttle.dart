import '../../../core/clock.dart';

/// Slows down password guessing. After [freeAttempts] failures a key (a
/// username or a client address) must wait, and the wait doubles with each
/// further failure up to [maxDelay]. Kept in memory: a guesser cannot
/// restart the tablet app.
class LoginThrottle {
  LoginThrottle({
    required this._clock,
    this.freeAttempts = 5,
    this.baseDelay = const Duration(seconds: 30),
    this.maxDelay = const Duration(minutes: 15),
  });

  final Clock _clock;
  final int freeAttempts;
  final Duration baseDelay;
  final Duration maxDelay;

  final _failures = <String, int>{};
  final _blockedUntil = <String, DateTime>{};

  /// How long [key] must still wait, or null when it may try now.
  Duration? waitFor(String key) {
    final until = _blockedUntil[key];
    if (until == null) return null;
    final remaining = until.difference(_clock());
    return remaining.isNegative || remaining == Duration.zero
        ? null
        : remaining;
  }

  void recordFailure(String key) {
    final failures = (_failures[key] ?? 0) + 1;
    _failures[key] = failures;
    if (failures < freeAttempts) return;
    final doublings = failures - freeAttempts;
    var delay = baseDelay * (1 << (doublings > 20 ? 20 : doublings));
    if (delay > maxDelay) delay = maxDelay;
    _blockedUntil[key] = _clock().add(delay);
  }

  void recordSuccess(String key) {
    _failures.remove(key);
    _blockedUntil.remove(key);
  }
}
