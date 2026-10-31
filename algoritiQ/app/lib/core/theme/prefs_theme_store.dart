// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_store.dart';

final class PrefsThemeStore implements ThemeStore {
  const PrefsThemeStore();

  static const _key = 'app.theme';

  @override
  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  @override
  Future<void> write(String value) async {
    await (await SharedPreferences.getInstance()).setString(_key, value);
  }
}
