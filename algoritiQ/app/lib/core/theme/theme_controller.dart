// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'prefs_theme_store.dart';
import 'theme_store.dart';

final themeStoreProvider = Provider<ThemeStore>(
  (ref) => const PrefsThemeStore(),
);

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);

/// User theme choice (light, dark, or follow the device).
class ThemeController extends Notifier<ThemeMode> {
  late Future<void> restored;

  @override
  ThemeMode build() {
    restored = _restore();
    return ThemeMode.system;
  }

  /// Flips between light and dark (same as the web dashboard toggle).
  Future<void> toggleLightDark(BuildContext context) async {
    final brightness = Theme.of(context).brightness;
    final next = brightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setMode(next);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      await ref.read(themeStoreProvider).write(_encode(mode));
    } on Object {
      // Best effort: still applies for this session.
    }
  }

  Future<void> _restore() async {
    String? raw;
    try {
      raw = await ref.read(themeStoreProvider).read();
    } on Object {
      return;
    }
    if (!ref.mounted) return;
    state = _decode(raw);
  }

  static String _encode(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };

  static ThemeMode _decode(String? raw) => switch (raw) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
