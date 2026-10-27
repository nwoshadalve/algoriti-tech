import 'package:algoritiq_app/app/app.dart';
import 'package:algoritiq_app/features/access/application/access_providers.dart';
import 'package:algoritiq_app/features/access/application/access_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../support/licensing_kit.dart';

void main() {
  late LicensingKit kit;
  late MemoryLicenseStore licensed;

  setUpAll(() async {
    kit = await LicensingKit.create();
    licensed = MemoryLicenseStore(await kit.issue());
  });

  /// The guide has a ticking clock, so settle by hand instead of waiting for
  /// the screen to go quiet.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<ProviderContainer> openGuide(
    WidgetTester tester, {
    FakeApiHost? host,
    String? localName,
    Size? size,
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) async {
    final fake = host ?? FakeApiHost();
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
        adminRegistered: false,
        readinessAcknowledged: true,
        apiHost: fake,
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
    if (localName != null) {
      fake.claimName(localName);
      await settle(tester);
    }
    return container;
  }

  /// Unmounts the app so the code's one-second timer stops before the test
  /// ends.
  Future<void> close(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox.shrink());

  testWidgets('should not show the admin guide before readiness is done', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: kit.overrides(
        store: licensed,
        adminRegistered: false,
        readinessAcknowledged: false,
        apiHost: FakeApiHost(),
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

    expect(find.text('Keep the tablet ready'), findsOneWidget);
    expect(find.text('Create the admin account'), findsNothing);
    await close(tester);
  });

  testWidgets('should guide the first admin with the address and code', (
    tester,
  ) async {
    final container = await openGuide(tester);

    expect(find.text('Create the admin account'), findsOneWidget);
    expect(
      find.text('https://192.168.0.20:8443', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Server running'), findsOneWidget);
    final code = container.read(claimCodesProvider).current();
    expect(find.text(code.display), findsOneWidget);
    // The fingerprint is split into two even lines.
    expect(find.textContaining('AB:CD\nEF'), findsOneWidget);
    await close(tester);
  });

  testWidgets('should show the local name first, with the IP below', (
    tester,
  ) async {
    await openGuide(tester, localName: 'algoritiq.local');

    expect(
      find.text('https://algoritiq.local:8443', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Or by IP address'), findsOneWidget);
    expect(find.text('192.168.0.20:8443'), findsOneWidget);
    expect(
      find.text('https://192.168.0.20:8443', findRichText: true),
      findsNothing,
    );
    await close(tester);
  });

  testWidgets('should put the IP address in the QR code, not the name', (
    tester,
  ) async {
    await openGuide(tester, localName: 'algoritiq.local');

    Finder qrLabelled(String label) => find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == label,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is CustomPaint && widget.painter is QrPainter,
      ),
      findsOneWidget,
    );
    expect(qrLabelled('https://192.168.0.20:8443'), findsOneWidget);
    expect(qrLabelled('https://algoritiq.local:8443'), findsNothing);
    await close(tester);
  });

  testWidgets('should show only the IP address until a name is claimed', (
    tester,
  ) async {
    await openGuide(tester);

    expect(find.textContaining('algoritiq.local'), findsNothing);
    expect(find.textContaining('Or by IP address'), findsNothing);
    await close(tester);
  });

  testWidgets('should count the code down and offer a new one', (tester) async {
    final container = await openGuide(tester);
    final first = container.read(claimCodesProvider).current().display;
    expect(find.text('Expires in 15:00'), findsOneWidget);

    await tester.tap(find.text('New code'));
    await tester.pump();

    expect(find.text(first), findsNothing);
    expect(
      find.text(container.read(claimCodesProvider).current().display),
      findsOneWidget,
    );
    await close(tester);
  });

  testWidgets('should ask for Wi-Fi when the tablet has no network', (
    tester,
  ) async {
    await openGuide(tester, host: FakeApiHost(addresses: const []));

    expect(
      find.text('Connect this tablet to the clinic Wi-Fi to continue.'),
      findsOneWidget,
    );
    await close(tester);
  });

  testWidgets('should offer a retry when the server cannot start', (
    tester,
  ) async {
    final host = FakeApiHost(fails: true);
    await openGuide(tester, host: host);
    expect(find.text('The server could not start.'), findsOneWidget);

    host.fails = false;
    await tester.tap(find.text('Try again'));
    await settle(tester);

    expect(find.text('Server running'), findsOneWidget);
    await close(tester);
  });

  testWidgets('should move on as soon as the first admin registers', (
    tester,
  ) async {
    final container = await openGuide(tester);
    final service = await tester.runAsync(
      () => container.read(accessServiceProvider.future),
    );
    final code = container.read(claimCodesProvider).current().code;

    final result = await tester.runAsync(
      () => service!.registerAdmin(
        claimCode: code,
        username: 'owner',
        displayName: 'Owner',
        password: 'a-long-passphrase',
      ),
    );
    await settle(tester);

    expect(result, isA<Registered>());
    expect(find.text('Create the admin account'), findsNothing);
    expect(find.byIcon(Icons.add), findsOneWidget);
    await close(tester);
  });

  testWidgets('should not show the guide once an admin exists', (tester) async {
    final container = ProviderContainer(
      overrides: kit.overrides(store: licensed),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AlgoritiqApp(),
      ),
    );
    await settle(tester);

    expect(find.text('Create the admin account'), findsNothing);
    await close(tester);
  });

  testWidgets('should start the server only once', (tester) async {
    final host = FakeApiHost();
    await openGuide(tester, host: host);

    expect(host.starts, 1);
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
            await openGuide(
              tester,
              localName: 'algoritiq-2.local',
              size: size,
              brightness: brightness,
              textScale: scale,
            );

            expect(tester.takeException(), isNull);
            expect(find.text('Create the admin account'), findsOneWidget);
            await close(tester);
          },
        );
      }
    }
  }

  testWidgets('should need little scrolling on the Honor Pad in portrait', (
    tester,
  ) async {
    // 533 x 893 dp. As in the landscape test below, the test font is wider than
    // the real one; on the real tablet the guide needs no scrolling at all.
    await openGuide(
      tester,
      localName: 'algoritiq.local',
      size: const Size(533, 893),
    );

    final scrollable = find
        .descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    expect(
      tester.state<ScrollableState>(scrollable).position.maxScrollExtent,
      lessThanOrEqualTo(120),
    );
    await close(tester);
  });

  // The test font is about 1.7 times wider than the real one, so this is a
  // pessimistic bound; on the real Honor Pad X7 (Bengali and English, light
  // and dark) the guide needs no scrolling at all.
  testWidgets('should need very little scrolling on the Honor Pad', (
    tester,
  ) async {
    await openGuide(
      tester,
      localName: 'algoritiq.local',
      size: const Size(893, 533),
    );

    final scrollable = find
        .descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    expect(
      tester.state<ScrollableState>(scrollable).position.maxScrollExtent,
      lessThanOrEqualTo(80),
    );
    await close(tester);
  });
}
