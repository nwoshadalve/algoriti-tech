import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../support/licensing_kit.dart';
import '../../support/pump_app.dart';

void main() {
  late LicensingKit kit;

  setUpAll(() async => kit = await LicensingKit.create());

  Future<void> openApp(WidgetTester tester, List<Override> overrides) =>
      pumpApp(tester, overrides);

  testWidgets('should show the activation screen with the device code', (
    tester,
  ) async {
    await openApp(tester, kit.overrides());

    final code = (await DeviceCode.fromAndroidId(kit.deviceId)).toString();
    expect(find.text('Activate this device'), findsOneWidget);
    expect(find.text(code), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets('should unlock the app when a valid key is entered', (
    tester,
  ) async {
    await openApp(tester, kit.overrides());
    final token = await tester.runAsync(kit.issue);

    await tester.enterText(find.byType(TextField), token!);
    await tester.tap(find.text('Activate'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Doctor license · up to 2 chambers'), findsOneWidget);
    expect(find.text('No expiry'), findsOneWidget);
  });

  testWidgets('should activate from the keyboard Done key', (tester) async {
    await openApp(tester, kit.overrides());
    final token = await tester.runAsync(kit.issue);

    await tester.enterText(find.byType(TextField), token!);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('should drop line breaks and spaces from a pasted key', (
    tester,
  ) async {
    await openApp(tester, kit.overrides());

    await tester.enterText(find.byType(TextField), 'AB12 CD34\nEF56');

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'AB12CD34EF56');
  });

  testWidgets('should explain why a key for another device is rejected', (
    tester,
  ) async {
    await openApp(tester, kit.overrides());
    final token = await tester.runAsync(
      () => kit.issue(forDeviceId: 'other-device'),
    );

    await tester.enterText(find.byType(TextField), token!);
    await tester.tap(find.text('Activate'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(
      find.text('This key was issued for a different device.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets('should open straight to home on a licensed device', (
    tester,
  ) async {
    final store = MemoryLicenseStore(await kit.issue());
    await openApp(tester, kit.overrides(store: store));

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Activate this device'), findsNothing);
  });

  testWidgets('should warn during the grace period', (tester) async {
    final store = MemoryLicenseStore(
      await kit.issue(expiresAt: testNow.subtract(const Duration(days: 3))),
    );
    await openApp(tester, kit.overrides(store: store));

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(
      find.text(
        'License expired. Enter a renewed key soon to avoid interruption.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('should offer a retry when the device id cannot be read', (
    tester,
  ) async {
    await openApp(tester, kit.overrides(deviceIdUnavailable: true));

    expect(find.text("Couldn't read this device's identity."), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
