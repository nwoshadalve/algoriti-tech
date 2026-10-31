// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/core/toast/toast_controller.dart';
import 'package:algoritiq_app/core/toast/toast_host.dart';
import 'package:algoritiq_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<ProviderContainer> pump(
    WidgetTester tester, {
    ThemeMode mode = ThemeMode.light,
    Size size = const Size(800, 1200),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => ToastHost(child: child),
          home: const Scaffold(body: Text('page')),
        ),
      ),
    );
    return container;
  }

  ToastController toaster(ProviderContainer c) =>
      c.read(toastControllerProvider.notifier);

  testWidgets('should show a message and take it away by itself', (
    tester,
  ) async {
    final c = await pump(tester);

    toaster(c).success('Saved');
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('should keep an error longer than a success', (tester) async {
    final c = await pump(tester);

    toaster(c)
      ..success('Saved')
      ..error('Failed');
    await tester.pump(const Duration(seconds: 5));

    expect(find.text('Saved'), findsNothing);
    expect(find.text('Failed'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Failed'), findsNothing);
  });

  testWidgets('should show at most five, dropping the oldest', (tester) async {
    final c = await pump(tester);

    for (var i = 1; i <= 7; i++) {
      toaster(c).info('Message $i');
    }
    await tester.pump();

    expect(c.read(toastControllerProvider), hasLength(maxToasts));
    expect(find.text('Message 1'), findsNothing);
    expect(find.text('Message 2'), findsNothing);
    for (var i = 3; i <= 7; i++) {
      expect(find.text('Message $i'), findsOneWidget);
    }
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('should not stack the same message twice', (tester) async {
    final c = await pump(tester);

    toaster(c)
      ..success('Saved')
      ..success('Saved');
    await tester.pump();

    expect(find.text('Saved'), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('should close a message when its close button is tapped', (
    tester,
  ) async {
    final c = await pump(tester);
    toaster(c).error('Failed');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(find.text('Failed'), findsNothing);
  });

  testWidgets('should not block taps on the page underneath', (tester) async {
    final c = await pump(tester);
    toaster(c).info('Hello');
    await tester.pump();

    expect(tester.takeException(), isNull);
    await tester.tap(find.text('page'), warnIfMissed: false);
    await tester.pump(const Duration(seconds: 10));
  });

  for (final mode in ThemeMode.values.where((m) => m != ThemeMode.system)) {
    testWidgets('should fit a phone in ${mode.name} theme', (tester) async {
      final c = await pump(tester, mode: mode, size: const Size(360, 740));

      toaster(c)
        ..success('Printer connected. This is a long message for the toaster.')
        ..error('The test page did not print. Check paper and cover.');
      await tester.pump();

      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 10));
    });
  }
}
