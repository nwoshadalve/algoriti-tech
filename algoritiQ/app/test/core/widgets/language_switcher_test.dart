import 'package:algoritiq_app/core/l10n/locale_controller.dart';
import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/core/widgets/language_switcher.dart';
import 'package:algoritiq_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/memory_locale_store.dart';

void main() {
  Future<void> open(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      overrides: [localeStoreProvider.overrideWithValue(MemoryLocaleStore())],
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: Center(child: LanguageSwitcher())),
      ),
    ),
  );

  testWidgets('should size hover and ripple to the visible 32 dp pill', (
    tester,
  ) async {
    await open(tester);

    for (final inkWell in tester.widgetList(find.byType(InkWell))) {
      final box = tester.getSize(find.byWidget(inkWell));
      expect(box.height, 32);
    }
  });

  testWidgets('should keep a 48 dp touch area on each language', (
    tester,
  ) async {
    await open(tester);

    final english = find.ancestor(
      of: find.text('EN'),
      matching: find.byWidgetPredicate(
        (w) => w is GestureDetector && w.behavior == HitTestBehavior.opaque,
      ),
    );
    final size = tester.getSize(english.last);

    expect(size.height, greaterThanOrEqualTo(48));
    expect(size.width, greaterThanOrEqualTo(48));
  });
}
