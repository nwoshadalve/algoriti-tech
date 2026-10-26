import 'package:algoritiq_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/licensing_kit.dart';

void main() {
  late LicensingKit kit;

  setUpAll(() async => kit = await LicensingKit.create());

  const screens = {
    'phone portrait': Size(360, 740),
    'phone landscape': Size(740, 360),
    'tablet portrait': Size(800, 1280),
    'tablet landscape': Size(1280, 800),
  };

  Future<void> openApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: kit.overrides(), child: const AlgoritiqApp()),
    );
    await tester.pumpAndSettle();
  }

  for (final MapEntry(key: name, value: size) in screens.entries) {
    for (final brightness in Brightness.values) {
      for (final textScale in [1.0, 2.0]) {
        testWidgets(
          'should lay out without overflow on $name, ${brightness.name}, '
          'text x$textScale',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.platformBrightnessTestValue = brightness;
            tester.platformDispatcher.textScaleFactorTestValue = textScale;
            addTearDown(tester.view.reset);
            addTearDown(tester.platformDispatcher.clearAllTestValues);

            await openApp(tester);

            expect(tester.takeException(), isNull);
            expect(find.text('Activate'), findsOneWidget);
          },
        );
      }
    }
  }

  testWidgets('should switch the screen to Bengali from the language toggle', (
    tester,
  ) async {
    await openApp(tester);

    await tester.tap(find.text('বাংলা'));
    await tester.pumpAndSettle();

    expect(find.text('AlgoritiQ সক্রিয় করুন'), findsOneWidget);
    expect(find.text('Activate AlgoritiQ'), findsNothing);
  });
}
