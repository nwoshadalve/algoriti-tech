import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/core/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/licensing_kit.dart';
import 'support/pump_app.dart';

void main() {
  late LicensingKit kit;
  late MemoryLicenseStore licensed;

  setUpAll(() async {
    kit = await LicensingKit.create();
    licensed = MemoryLicenseStore(await kit.issue());
  });

  Future<void> openLicensedApp(WidgetTester tester) =>
      pumpApp(tester, kit.overrides(store: licensed));

  group('theme', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('should render the logo with ${mode.name} theme', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: mode,
            home: const Scaffold(body: BrandLogo.wordmark()),
          ),
        );

        expect(find.bySemanticsLabel('AlgoritiQ'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('home counter increments', (tester) async {
    await openLicensedApp(tester);

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
