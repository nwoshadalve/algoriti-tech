// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/core/widgets/app_dialog.dart';
import 'package:algoritiq_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    required Size size,
    Brightness brightness = Brightness.light,
    Widget body = const Text('Body'),
    double keyboard = 0,
    bool fixedSizeWithKeyboard = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAppDialog<void>(
                context: context,
                title: 'Title',
                body: body,
                fixedSizeWithKeyboard: fixedSizeWithKeyboard,
                actions: [
                  TextButton(onPressed: () {}, child: const Text('Cancel')),
                  FilledButton(onPressed: () {}, child: const Text('Print')),
                ],
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Size dialogSize(WidgetTester tester) => tester.getSize(
    find
        .descendant(of: find.byType(Dialog), matching: find.byType(Column))
        .first,
  );

  testWidgets('should show header, body and footer', (tester) async {
    await open(tester, size: const Size(800, 1280));

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
  });

  testWidgets('should take most of the width in portrait', (tester) async {
    await open(tester, size: const Size(400, 800));

    expect(
      dialogSize(tester).width,
      closeTo(400 * DialogSize.portraitWidth, 1),
    );
  });

  testWidgets('should take less width but more height in landscape', (
    tester,
  ) async {
    final tall = Text('x\n' * 80);
    await open(tester, size: const Size(1000, 600), body: tall);

    final size = dialogSize(tester);
    expect(size.width, closeTo(1000 * DialogSize.landscapeWidth, 1));
    expect(size.height, closeTo(600 * DialogSize.landscapeHeight, 1));
  });

  testWidgets('should keep header and footer while a long body scrolls', (
    tester,
  ) async {
    await open(
      tester,
      size: const Size(400, 800),
      body: Column(children: [for (var i = 0; i < 60; i++) Text('Line $i')]),
    );

    expect(tester.takeException(), isNull);
    expect(dialogSize(tester).height, lessThanOrEqualTo(800 * 0.7 + 1));
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
    final bottom = tester.getBottomLeft(find.byType(Dialog)).dy;
    expect(
      tester.getTopLeft(find.text('Line 59')).dy,
      greaterThan(bottom),
      reason: 'below the fold until scrolled',
    );

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -4000),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Line 59')).dy,
      lessThan(bottom),
      reason: 'scrolled into view',
    );
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
  });

  testWidgets('should stay on screen with the keyboard open', (tester) async {
    await open(
      tester,
      size: const Size(360, 700),
      keyboard: 300,
      body: Column(children: [for (var i = 0; i < 40; i++) Text('Line $i')]),
    );

    expect(tester.takeException(), isNull);
    expect(dialogSize(tester).height, lessThanOrEqualTo((700 - 300) * 0.7 + 1));
  });

  testWidgets(
    'should keep the fields visible above a tall landscape keyboard',
    (tester) async {
      // Regression: the fixed footer used up the little room left above the
      // keyboard, so the focused field had no visible space.
      await open(
        tester,
        size: const Size(1340, 800),
        keyboard: 450,
        fixedSizeWithKeyboard: true,
        body: Column(
          children: [
            for (var i = 0; i < 6; i++) TextField(key: Key('field$i')),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
      final first = tester.getRect(find.byKey(const Key('field0')));
      expect(first.height, greaterThan(0));
      expect(first.bottom, lessThanOrEqualTo(800 - 450));
      final dialog = tester.getRect(
        find
            .descendant(of: find.byType(Dialog), matching: find.byType(Column))
            .first,
      );
      expect(dialog.bottom, lessThanOrEqualTo(800 - 450));
      expect(
        tester.getRect(find.byType(SingleChildScrollView)).height,
        greaterThan(150),
        reason: 'the body gets the room, not a fixed footer',
      );
    },
  );

  testWidgets('should keep focus when the keyboard opens', (tester) async {
    // Regression: the body moved in the tree as the keyboard opened, which
    // rebuilt the fields, dropped focus and closed the keyboard again.
    final node = FocusNode();
    addTearDown(node.dispose);
    await open(
      tester,
      size: const Size(1340, 800),
      fixedSizeWithKeyboard: true,
      body: TextField(focusNode: node),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(node.hasFocus, isTrue);

    tester.view.viewInsets = const FakeViewPadding(bottom: 450);
    await tester.pumpAndSettle();

    expect(node.hasFocus, isTrue);
  });

  testWidgets('should close from the header', (tester) async {
    await open(tester, size: const Size(800, 1280));

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Title'), findsNothing);
  });

  const sizes = {
    'phone portrait': Size(360, 740),
    'phone landscape': Size(740, 360),
    'honor pad portrait': Size(533, 893),
    'honor pad landscape': Size(893, 533),
    'tablet landscape': Size(1280, 800),
  };
  for (final MapEntry(key: name, value: size) in sizes.entries) {
    for (final brightness in Brightness.values) {
      testWidgets('should lay out on $name, ${brightness.name}', (
        tester,
      ) async {
        await open(
          tester,
          size: size,
          brightness: brightness,
          body: Column(children: [for (var i = 0; i < 30; i++) Text('L$i')]),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Print'), findsOneWidget);
      });
    }
  }
}
