// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/core/toast/toast_host.dart';
import 'package:algoritiq_app/features/connectivity/application/printer_controller.dart';
import 'package:algoritiq_app/features/connectivity/application/test_token_service.dart';
import 'package:algoritiq_app/features/connectivity/domain/printer.dart';
import 'package:algoritiq_app/features/connectivity/presentation/connectivity_page.dart';
import 'package:algoritiq_app/l10n/app_localizations.dart';
import 'package:algoritiq_app/platform/printer_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/clinic_fake.dart';
import '../../support/printer_fake.dart';

void main() {
  late FakePrinterGateway gateway;
  late MemoryPrinterStore store;
  late ProviderContainer container;
  String? scope;

  /// Like testWidgets, but ends the printer controller's timers before the
  /// test's own "no timer left" check.
  void pageTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump();
    });
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    Brightness brightness = Brightness.light,
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: [
        printerGatewayProvider.overrideWithValue(gateway),
        printerStoreProvider.overrideWithValue(store),
        printerRetryDelaysProvider.overrideWithValue(const [
          Duration(minutes: 5),
        ]),
        testTokenServiceProvider.overrideWith(
          (ref) => TestTokenService(
            clinic: FakeClinic(),
            scopeId: () => scope,
            now: () => DateTime(2026, 10, 30, 12, 14),
            print: (job) =>
                ref.read(printerControllerProvider.notifier).print(job),
            render: (slip) async => Uint8List.fromList([9, 9]),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => ToastHost(child: child),
          // Room above for the app's top bar, below for the system bar.
          home: const Scaffold(
            body: Column(
              children: [
                SizedBox(height: 88),
                Expanded(child: ConnectivityPage()),
                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  setUp(() {
    gateway = FakePrinterGateway();
    store = MemoryPrinterStore();
    scope = 'c1';
  });

  pageTest('should offer to choose a printer when none is set up', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('No printer set up'), findsOneWidget);
    expect(find.text('Choose printer'), findsOneWidget);
    expect(find.text('TV screen'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
  });

  pageTest('should show only the connection when connected', (tester) async {
    store.device = rongta;
    await pumpPage(tester);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('RPP02C'), findsOneWidget);
    expect(find.text('Test print'), findsOneWidget);
    for (final gone in [
      'Battery',
      'Paper',
      'Cover',
      'Refresh',
      'Change printer',
      'Forget printer',
    ]) {
      expect(find.text(gone), findsNothing, reason: gone);
    }
  });

  pageTest('should say it keeps trying when the printer is off', (
    tester,
  ) async {
    store.device = rongta;
    gateway.connectResults = [ConnectOutcome.failed];
    await pumpPage(tester);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Not connected'), findsOneWidget);
    expect(find.text('Connect now'), findsOneWidget);
    expect(find.textContaining('Trying again in'), findsOneWidget);
  });

  pageTest('should ask to turn Bluetooth on when it is off', (tester) async {
    store.device = rongta;
    gateway.accessNow = BluetoothAccess.off;
    await pumpPage(tester);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Bluetooth is off'), findsOneWidget);
    expect(find.text('Turn Bluetooth on'), findsOneWidget);
    expect(gateway.connectCalls, 0);
  });

  pageTest('should list nearby printers and pair the one chosen', (
    tester,
  ) async {
    gateway.nearby = [rongta];
    await pumpPage(tester);

    await tester.tap(find.text('Choose printer'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your printer'), findsOneWidget);
    expect(find.text('RPP02C'), findsOneWidget);

    await tester.tap(find.text('RPP02C'));
    await tester.pumpAndSettle();

    expect(store.device, rongta);
    expect(find.text('Printer connected.'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
  });

  group('test print', () {
    Future<void> openConfirm(WidgetTester tester) async {
      store.device = rongta;
      await pumpPage(tester);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Test print'));
      await tester.pumpAndSettle();
    }

    pageTest('should ask before printing and print nothing on cancel', (
      tester,
    ) async {
      await openConfirm(tester);

      expect(find.text('Print a test token?'), findsOneWidget);
      expect(gateway.printed, isEmpty);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Print a test token?'), findsNothing);
      expect(gateway.printed, isEmpty);
    });

    pageTest('should print the test token once it is confirmed', (
      tester,
    ) async {
      await openConfirm(tester);

      await tester.tap(find.text('Print test token'));
      await tester.pumpAndSettle();

      expect(gateway.printed, hasLength(1));
      expect(gateway.printed.single, [9, 9]);
      expect(find.text('Test token printed.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
    });

    pageTest('should tell the receptionist when the token did not print', (
      tester,
    ) async {
      gateway.printResult = PrintOutcome.failed;
      await openConfirm(tester);

      await tester.tap(find.text('Print test token'));
      await tester.pumpAndSettle();

      expect(
        find.text('The test token did not print. Check paper and cover.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 10));
    });

    pageTest('should say so when the chamber or doctor is not known', (
      tester,
    ) async {
      scope = null;
      await openConfirm(tester);

      await tester.tap(find.text('Print test token'));
      await tester.pumpAndSettle();

      expect(gateway.printed, isEmpty);
      expect(
        find.text(
          'The chamber or doctor details for the token could not be found.',
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 10));
    });
  });

  const fits = {
    'phone portrait': Size(360, 740),
    'honor pad portrait': Size(533, 893),
    'honor pad landscape': Size(893, 533),
    'tablet portrait': Size(800, 1280),
    'tablet landscape': Size(1280, 800),
  };
  for (final MapEntry(key: name, value: size) in fits.entries) {
    for (final brightness in Brightness.values) {
      for (final locale in const [Locale('en'), Locale('bn')]) {
        pageTest('should fit without scrolling on $name, ${brightness.name}, '
            '${locale.languageCode}', (tester) async {
          store.device = rongta;
          await pumpPage(
            tester,
            size: size,
            brightness: brightness,
            locale: locale,
          );
          await tester.pump(const Duration(milliseconds: 50));

          expect(tester.takeException(), isNull);
          final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
          expect(scroll.position.maxScrollExtent, 0);
        });
      }
    }
  }

  pageTest('should lay out on a short phone in landscape', (tester) async {
    store.device = rongta;
    await pumpPage(tester, size: const Size(740, 360));
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
  });
}
