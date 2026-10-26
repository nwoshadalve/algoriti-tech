import 'package:algoritiq_app/app/app.dart';
import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/core/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
    await tester.pumpWidget(const AlgoritiqApp());

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
