// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

var _brandFontLoaded = false;

/// The tests' default font draws every glyph as a wide square, which makes
/// text look far bigger than on the tablet. Loading the brand font gives
/// realistic widths, so a layout that fits here fits there.
Future<void> _loadBrandFont(WidgetTester tester) async {
  if (_brandFontLoaded) return;
  await tester.runAsync(() async {
    final loader = FontLoader(brandFontFamily)
      ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans.ttf'));
    await loader.load();
  });
  _brandFontLoaded = true;
}

/// Pumps [child] the way the app shows it: themed, localised, at a given
/// screen size, text scale and brightness, with the wait ticker stilled.
Future<void> pumpDeskApp(
  WidgetTester tester,
  Widget child, {
  required Size size,
  String language = 'en',
  double textScale = 1,
  Brightness brightness = Brightness.dark,
  double keyboard = 0,
}) async {
  await _loadBrandFont(tester);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
        locale: Locale(language),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: Scaffold(resizeToAvoidBottomInset: false, body: child),
        ),
      ),
    ),
  );
}
