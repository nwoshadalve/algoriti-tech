// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/core/toast/toast_host.dart';
import 'package:algoritiq_app/features/connectivity/application/tv_test_service.dart';
import 'package:algoritiq_app/features/connectivity/presentation/tv_card.dart';
import 'package:algoritiq_app/features/home/application/receptionist_scope_service.dart';
import 'package:algoritiq_app/features/home/application/receptionist_work.dart';
import 'package:algoritiq_app/features/tv_link/application/tv_link_providers.dart';
import 'package:algoritiq_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Work extends ReceptionistWorkController {
  @override
  ReceptionistWorkState? build() =>
      const ReceptionistWorkReady(WorkScopeOption(id: 'c1', name: 'Room 1'));
}

class _FakeTest extends Fake implements TvTestService {
  TvTestOutcome outcome = TvTestOutcome.shown;
  final asked = <String>[];

  @override
  Future<TvTestOutcome> testDisplay() async {
    asked.add('display');
    return outcome;
  }

  @override
  Future<TvTestOutcome> testSound() async {
    asked.add('sound');
    return outcome;
  }
}

void main() {
  late _FakeTest tester0;

  Future<void> pumpCard(
    WidgetTester tester, {
    bool connected = false,
    Size size = const Size(893, 533),
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester0 = _FakeTest();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          receptionistWorkProvider.overrideWith(_Work.new),
          tvTestServiceProvider.overrideWithValue(tester0),
          tvConnectedProvider.overrideWith(
            (ref, chamberId) => Stream.value(connected),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => ToastHost(child: child),
          home: const Scaffold(body: SingleChildScrollView(child: TvCard())),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('what the card shows', () {
    testWidgets('should offer the tests when the TV is connected', (
      tester,
    ) async {
      await pumpCard(tester, connected: true);

      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('Test screen'), findsOneWidget);
      expect(find.text('Test sound'), findsOneWidget);
    });

    testWidgets('should not offer a test to a TV that is not connected', (
      tester,
    ) async {
      await pumpCard(tester);

      expect(find.text('Not connected'), findsOneWidget);
      expect(find.text('Test screen'), findsNothing);
      expect(find.text('Test sound'), findsNothing);
    });
  });

  group('testing the TV', () {
    Future<void> runTest(
      WidgetTester tester,
      String button,
      String confirm,
    ) async {
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
      await tester.tap(find.text(confirm));
      await tester.pumpAndSettle();
    }

    testWidgets('should ask first and test nothing on cancel', (tester) async {
      await pumpCard(tester, connected: true);

      await tester.tap(find.text('Test screen'));
      await tester.pumpAndSettle();
      expect(find.text('Show a test screen on the TV?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(tester0.asked, isEmpty);
    });

    testWidgets('should say the TV showed the screen', (tester) async {
      await pumpCard(tester, connected: true);

      await runTest(tester, 'Test screen', 'Show on TV');

      expect(tester0.asked, ['display']);
      expect(find.text('The TV showed the test screen.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('should say the TV played the sound', (tester) async {
      await pumpCard(tester, connected: true);
      tester0.outcome = TvTestOutcome.played;

      await runTest(tester, 'Test sound', 'Play test sound');

      expect(tester0.asked, ['sound']);
      expect(find.text('The TV played the test sound.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('should say when the sound did not play', (tester) async {
      await pumpCard(tester, connected: true);
      tester0.outcome = TvTestOutcome.soundFailed;

      await runTest(tester, 'Test sound', 'Play test sound');

      expect(find.textContaining('the sound did not play'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('should say when the TV did not answer', (tester) async {
      await pumpCard(tester, connected: true);
      tester0.outcome = TvTestOutcome.noReply;

      await runTest(tester, 'Test screen', 'Show on TV');

      expect(find.text('The TV did not answer. Try again.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
    });
  });

  group('fit', () {
    const sizes = {
      'phone': Size(360, 740),
      'honor pad portrait': Size(533, 893),
      'honor pad landscape': Size(893, 533),
    };
    for (final MapEntry(key: name, value: size) in sizes.entries) {
      for (final locale in const [Locale('en'), Locale('bn')]) {
        testWidgets('should fit on $name in ${locale.languageCode}', (
          tester,
        ) async {
          await pumpCard(tester, connected: true, size: size, locale: locale);

          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
