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

  testWidgets('should show restore or start new after readiness', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: kit.overrides(
        store: licensed,
        setupDone: false,
        adminRegistered: false,
        signedIn: false,
        readinessAcknowledged: true,
        clinicDataChosen: false,
        keepAlive: FakeKeepAliveGateway(),
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

    expect(find.text('Clinic data'), findsOneWidget);
    expect(find.text('Start new'), findsOneWidget);
    expect(find.text('Restore from backup'), findsOneWidget);
  });

  testWidgets('should open setup after start new', (tester) async {
    final container = ProviderContainer(
      overrides: kit.overrides(
        store: licensed,
        setupDone: false,
        adminRegistered: false,
        signedIn: false,
        readinessAcknowledged: true,
        clinicDataChosen: false,
        keepAlive: FakeKeepAliveGateway(),
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

    await tester.tap(find.text('Start new'));
    await settle(tester);

    expect(find.text('Your profile'), findsWidgets);
  });
}
