import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/account.dart';
import 'access_providers.dart';
import 'access_service.dart';

/// Who is signed in on this tablet, and the token that proves it.
final class TabletSignIn {
  const TabletSignIn(this.account, this.token);

  final Account account;
  final String token;
}

final tabletSessionProvider = NotifierProvider<TabletSession, TabletSignIn?>(
  TabletSession.new,
);

/// The tablet's own sign-in. It lives in memory only: closing the app, or
/// restarting the tablet, asks for the password again. A reset on any device
/// (or the 12 hour limit) ends it too, noticed when the app comes back to the
/// front ([stillValid]).
class TabletSession extends Notifier<TabletSignIn?> {
  /// The tablet is a client of its own API; this key tells it apart from the
  /// laptops when sign-in attempts are slowed down.
  static const _clientKey = 'tablet';

  @override
  TabletSignIn? build() => null;

  Future<AccessService> get _access => ref.read(accessServiceProvider.future);

  Future<LoginResult> signIn(String username, String password) async {
    final result = await (await _access).login(
      username: username,
      password: password,
      clientKey: _clientKey,
    );
    if (result case LoggedIn(:final token, :final account)) {
      state = TabletSignIn(account, token);
    }
    return result;
  }

  /// Step 1 of a password reset: check the activation key.
  Future<ResetStartResult> startReset({
    required String username,
    required String activationKey,
  }) async => (await _access).startReset(
    username: username,
    activationKey: activationKey,
    clientKey: _clientKey,
  );

  /// Step 2: choose the new password with the ticket from step 1.
  Future<ResetFinishResult> finishReset({
    required String ticket,
    required String newPassword,
  }) async => (await _access).finishReset(
    ticket: ticket,
    newPassword: newPassword,
    clientKey: _clientKey,
  );

  Future<void> signOut() async {
    final current = state;
    state = null;
    if (current != null) await (await _access).logout(current.token);
  }

  /// Signs out when the session was ended elsewhere.
  Future<void> stillValid() async {
    final current = state;
    if (current == null) return;
    final account = await (await _access).authenticate(current.token);
    if (account == null && ref.mounted) state = null;
  }
}
