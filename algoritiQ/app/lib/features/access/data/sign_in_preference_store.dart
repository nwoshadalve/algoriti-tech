// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:shared_preferences/shared_preferences.dart';

enum SignInMode { pin, password }

/// Last sign-in screen the person chose on this tablet (PIN or password).
final class SignInPreferenceStore {
  const SignInPreferenceStore();

  static const _key = 'sign_in.mode';

  Future<SignInMode> readMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) == 'password'
        ? SignInMode.password
        : SignInMode.pin;
  }

  Future<void> saveMode(SignInMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      mode == SignInMode.password ? 'password' : 'pin',
    );
  }
}
