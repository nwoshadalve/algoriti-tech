// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/licensing_kit.dart';
import '../../support/pump_app.dart';

void main() {
  late LicensingKit kit;
  late MemoryLicenseStore licensed;

  setUpAll(() async {
    kit = await LicensingKit.create();
    licensed = MemoryLicenseStore(await kit.issue());
  });

  Future<void> pumpDesk(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, kit.overrides(store: licensed));
  }

  Finder startButton() => find.widgetWithText(FilledButton, 'Start session');

  testWidgets('start session should ask first and stay closed on cancel', (
    tester,
  ) async {
    await pumpDesk(tester);
    expect(find.text('Session not open'), findsOneWidget);

    await tester.tap(startButton());
    await tester.pumpAndSettle();

    expect(find.text("Start today's session?"), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text("Start today's session?"), findsNothing);
    expect(find.text('Session not open'), findsOneWidget);
  });

  testWidgets('start session should open the session once confirmed', (
    tester,
  ) async {
    await pumpDesk(tester);

    await tester.tap(startButton());
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.widgetWithText(FilledButton, 'Start session'),
      ),
    );
    // The session is written to the real (in-memory) database.
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Session not open'), findsNothing);
    expect(find.text('Session started.'), findsOneWidget);

    // The open desk ticks every few seconds; close it before the test ends.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });
}
