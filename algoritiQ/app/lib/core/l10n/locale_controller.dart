// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'locale_store.dart';
import 'prefs_locale_store.dart';

final localeStoreProvider = Provider<LocaleStore>(
  (ref) => const PrefsLocaleStore(),
);

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

/// The language chosen by the user, or null to follow the device language.
///
/// The choice survives restarts and needs no network.
class LocaleController extends Notifier<Locale?> {
  /// Completes once the saved language (if any) has been applied.
  late Future<void> restored;

  @override
  Locale? build() {
    restored = _restore();
    return null;
  }

  Future<void> select(Locale locale) async {
    state = locale;
    try {
      await ref.read(localeStoreProvider).write(locale.languageCode);
    } on Object {
      // Saving is best effort: the language still changes for this session.
    }
  }

  Future<void> _restore() async {
    String? code;
    try {
      code = await ref.read(localeStoreProvider).read();
    } on Object {
      return; // Unreadable preference: keep following the device language.
    }
    if (!ref.mounted || state != null) return;
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == code) {
        state = locale;
        return;
      }
    }
  }
}
