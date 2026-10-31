// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
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

  testWidgets('home shows the receptionist board', (tester) async {
    await openLicensedApp(tester);

    expect(find.text('Patient queue'), findsOneWidget);
  });
}
