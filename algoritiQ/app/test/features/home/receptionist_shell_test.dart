// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/app/app.dart';
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

  Future<void> pumpShell(
    WidgetTester tester, {
    required Size size,
    required Brightness brightness,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
    addTearDown(tester.view.reset);
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await pumpApp(tester, kit.overrides(store: licensed));
  }

  const sizes = {
    'phone portrait': Size(360, 740),
    'phone landscape': Size(740, 360),
    'tablet portrait': Size(800, 1280),
    'tablet landscape': Size(1280, 800),
    'honor pad landscape': Size(893, 533),
    'honor pad portrait': Size(533, 893),
  };

  for (final MapEntry(key: name, value: size) in sizes.entries) {
    for (final brightness in Brightness.values) {
      testWidgets('receptionist board on $name, ${brightness.name}', (
        tester,
      ) async {
        await pumpShell(tester, size: size, brightness: brightness);
        expect(tester.takeException(), isNull);
        expect(find.text('Patient queue'), findsOneWidget);
      });
    }
  }

  testWidgets('menu should open Connectivity and keep the app on screen', (
    tester,
  ) async {
    await pumpShell(
      tester,
      size: const Size(533, 893),
      brightness: Brightness.light,
    );

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Connectivity'));
    await tester.pumpAndSettle();

    // The drawer closed once, not twice: the page is still there.
    expect(find.text('Printer'), findsOneWidget);
    expect(find.text('TV screen'), findsOneWidget);

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Board'));
    await tester.pumpAndSettle();

    expect(find.text('Patient queue'), findsOneWidget);
  });
}
