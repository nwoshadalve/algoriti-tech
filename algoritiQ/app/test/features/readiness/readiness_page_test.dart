// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/licensing_kit.dart';
import '../../support/readiness_kit.dart';

void main() {
  late LicensingKit kit;
  late MemoryLicenseStore licensed;

  setUpAll(() async {
    kit = await LicensingKit.create();
    licensed = MemoryLicenseStore(await kit.issue());
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<ProviderContainer> open(
    WidgetTester tester, {
    FakeKeepAliveGateway? gateway,
    Size? size,
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) async {
    if (size != null) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
      tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
      addTearDown(tester.view.reset);
    }
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    final container = ProviderContainer(
      overrides: kit.overrides(
        store: licensed,
        readinessAcknowledged: false,
        keepAlive: gateway ?? FakeKeepAliveGateway(),
      ),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AlgoritiqApp(),
      ),
    );
    await settle(tester);
    return container;
  }

  Future<void> close(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox.shrink());

  testWidgets('should show the guide before anything else on a new tablet', (
    tester,
  ) async {
    await open(tester);

    expect(find.text('Keep the tablet ready'), findsOneWidget);
    expect(find.text('Run in the background'), findsOneWidget);
    expect(find.text('Start after a restart'), findsOneWidget);
    expect(find.text('Screen lock'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
    await close(tester);
  });

  testWidgets('should offer Allow only for what is missing', (tester) async {
    await open(
      tester,
      gateway: FakeKeepAliveGateway(
        batteryOptimizationIgnored: false,
        notificationsGranted: false,
      ),
    );

    expect(find.byTooltip('Allow'), findsNWidgets(2));
    await close(tester);
  });

  testWidgets('should ask Android when Allow is tapped', (tester) async {
    final gateway = FakeKeepAliveGateway(batteryOptimizationIgnored: false);
    await open(tester, gateway: gateway);

    await tester.tap(find.byTooltip('Allow'));
    await settle(tester);

    expect(gateway.calls, contains('requestIgnoreBatteryOptimizations'));
    await close(tester);
  });

  testWidgets('should tick an item off when the user comes back allowed', (
    tester,
  ) async {
    final gateway = FakeKeepAliveGateway(
      batteryOptimizationIgnored: false,
      autoStartGranted: true,
    );
    await open(tester, gateway: gateway);
    expect(find.byTooltip('Allow'), findsOneWidget);

    gateway.batteryOptimizationIgnored = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);

    expect(find.byTooltip('Allow'), findsNothing);
    final continueButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNotNull);
    await close(tester);
  });

  testWidgets('should keep Continue disabled until every item is done', (
    tester,
  ) async {
    await open(
      tester,
      gateway: FakeKeepAliveGateway(batteryOptimizationIgnored: false),
    );

    final continueButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNull);
    expect(find.text('Continue anyway'), findsNothing);
    await close(tester);
  });

  testWidgets('should open auto-start settings from the settings icon', (
    tester,
  ) async {
    final gateway = FakeKeepAliveGateway(autoStartGranted: false);
    await open(tester, gateway: gateway, size: const Size(1280, 2000));

    await tester.tap(find.byTooltip('Open settings').first);
    await settle(tester);
    expect(gateway.calls, contains('openAutoStartSettings'));
    await close(tester);
  });

  testWidgets('should go on to the app, and not show the guide again', (
    tester,
  ) async {
    await open(tester, size: const Size(1280, 2000));

    await tester.tap(find.text('Continue'));
    await settle(tester);

    expect(find.text('Keep the tablet ready'), findsNothing);
    expect(find.text('Patient queue'), findsOneWidget);
    await close(tester);
  });

  const screens = {
    'phone portrait': Size(360, 740),
    'phone landscape': Size(740, 360),
    'tablet portrait': Size(800, 1280),
    'tablet landscape': Size(1280, 800),
    'honor pad landscape': Size(893, 533),
  };
  for (final MapEntry(key: name, value: size) in screens.entries) {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'should lay out the guide on $name, ${brightness.name}, text x$scale',
          (tester) async {
            await open(
              tester,
              size: size,
              brightness: brightness,
              textScale: scale,
              gateway: FakeKeepAliveGateway(
                batteryOptimizationIgnored: false,
                notificationsGranted: false,
                autoStartGranted: false,
                serviceRunning: false,
              ),
            );

            expect(tester.takeException(), isNull);
            expect(find.text('Keep the tablet ready'), findsOneWidget);
            await close(tester);
          },
        );
      }
    }
  }

  testWidgets('should need little scrolling on the Honor Pad, worst case', (
    tester,
  ) async {
    await open(
      tester,
      size: const Size(893, 533),
      gateway: FakeKeepAliveGateway(
        batteryOptimizationIgnored: false,
        notificationsGranted: false,
        autoStartGranted: false,
      ),
    );

    final scrollable = find
        .descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    // Every item needs a button here, and the test font is about 1.7 times
    // wider than the real one, so this is a pessimistic bound.
    expect(
      tester.state<ScrollableState>(scrollable).position.maxScrollExtent,
      lessThanOrEqualTo(80),
    );
    await close(tester);
  });
}
