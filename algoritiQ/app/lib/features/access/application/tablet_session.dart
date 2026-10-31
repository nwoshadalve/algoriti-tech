// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/account.dart';
import 'access_providers.dart';
import 'access_service.dart';
import '../data/sign_in_preference_store.dart';

/// Who is signed in on this tablet, and the token that proves it.
final class TabletSignIn {
  const TabletSignIn(this.account, this.token);

  final Account account;
  final String token;

  /// The tablet only has the receptionist screen for now: an admin is shown
  /// a notice that points to the web app instead.
  bool get showsAdminNotice => account.role == Role.admin;
}

final tabletSessionProvider = NotifierProvider<TabletSession, TabletSignIn?>(
  TabletSession.new,
);

/// The tablet's own sign-in. By default the session lives in memory only until
/// the app is closed. With **Remember me**, the token is kept in secure storage
/// and restored on launch (30-day session). A reset on any device (or expiry)
/// ends it too, noticed when the app comes back to the front ([stillValid]).
class TabletSession extends Notifier<TabletSignIn?> {
  /// The tablet is a client of its own API; this key tells it apart from the
  /// laptops when sign-in attempts are slowed down.
  static const _clientKey = 'tablet';

  @override
  TabletSignIn? build() => null;

  Future<AccessService> get _access => ref.read(accessServiceProvider.future);

  /// Restores a remembered sign-in after the app was closed or restarted.
  Future<void> restoreRemembered() async {
    if (state != null) return;
    final token = await ref.read(rememberedSessionStoreProvider).read();
    if (token == null || token.isEmpty) return;
    final account = await (await _access).authenticate(token);
    if (!ref.mounted) return;
    if (account != null) {
      state = TabletSignIn(account, token);
    } else {
      await ref.read(rememberedSessionStoreProvider).clear();
    }
  }

  Future<LoginResult> signIn(
    String username,
    String password, {
    bool remember = false,
  }) async {
    final result = await (await _access).login(
      username: username,
      password: password,
      clientKey: _clientKey,
      remember: remember,
    );
    if (result case LoggedIn(:final token, :final account)) {
      state = TabletSignIn(account, token);
      if (remember) {
        await ref.read(rememberedSessionStoreProvider).write(token);
      } else {
        await ref.read(rememberedSessionStoreProvider).clear();
      }
    }
    return result;
  }

  Future<PinLoginResult> signInWithPin(String pin) async {
    final registration = await ref.read(pinClientStoreProvider).read();
    if (registration == null) return const PinUnavailable();
    final result = await (await _access).loginWithPin(
      deviceToken: registration.deviceToken,
      pin: pin,
      clientKey: _clientKey,
    );
    if (result case PinLoggedIn(:final session)) {
      state = TabletSignIn(session.account, session.token);
    }
    return result;
  }

  /// PIN removed on the tablet after lockout; password only until a new PIN.
  Future<void> forgetPinRegistration() async {
    await ref.read(pinClientStoreProvider).clear();
    await ref.read(signInPreferenceStoreProvider).saveMode(SignInMode.password);
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

  /// The app was closed. The engine outlives the screen, so an admin (who
  /// has no screen of their own on the tablet yet) is signed out here.
  Future<void> appClosed() async {
    if (state?.account.role == Role.admin) await signOut();
  }

  void updateAccount(Account account) {
    final current = state;
    if (current == null) return;
    state = TabletSignIn(account, current.token);
  }

  Future<void> signOut() async {
    final current = state;
    state = null;
    await ref.read(rememberedSessionStoreProvider).clear();
    if (current != null) await (await _access).logout(current.token);
  }

  /// Signs out when the session was ended elsewhere.
  Future<void> stillValid() async {
    final current = state;
    if (current == null) return;
    final account = await (await _access).authenticate(current.token);
    if (account == null && ref.mounted) {
      state = null;
      await ref.read(rememberedSessionStoreProvider).clear();
    }
  }
}
