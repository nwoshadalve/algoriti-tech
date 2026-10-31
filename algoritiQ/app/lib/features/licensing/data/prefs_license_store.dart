// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/license_ports.dart';

final class PrefsLicenseStore implements LicenseStore {
  const PrefsLicenseStore();

  static const _key = 'license.token';

  @override
  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  @override
  Future<void> write(String token) async {
    await (await SharedPreferences.getInstance()).setString(_key, token);
  }
}
