// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_store.dart';

final class PrefsLocaleStore implements LocaleStore {
  const PrefsLocaleStore();

  static const _key = 'app.language';

  @override
  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  @override
  Future<void> write(String languageCode) async {
    await (await SharedPreferences.getInstance()).setString(_key, languageCode);
  }
}
