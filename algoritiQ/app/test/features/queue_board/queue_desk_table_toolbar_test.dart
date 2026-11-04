// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/features/queue_board/application/queue_desk_table_controller.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/queue_board/domain/token_query.dart';
import 'package:algoritiq_app/features/queue_board/presentation/queue_desk_table_toolbar.dart';
import 'package:algoritiq_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const _queues = [
  QueueTypeBoardControl(
    queueTypeId: 'regular',
    englishName: 'Regular',
    bengaliName: 'সাধারণ',
    waitingCount: 2,
    nextSerial: 1003,
    canCallNext: true,
    canRecall: false,
  ),
  QueueTypeBoardControl(
    queueTypeId: 'report',
    englishName: 'Report',
    bengaliName: 'রিপোর্ট',
    waitingCount: 0,
    nextSerial: 2001,
    canCallNext: false,
    canRecall: false,
  ),
];

void main() {
  late List<String> log;

  Future<void> pump(
    WidgetTester tester, {
    DeskTableState state = const DeskTableState(loading: false),
    Size size = const Size(900, 300),
    String language = 'en',
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        locale: Locale(language),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: QueueDeskTableToolbar(
            state: state,
            queues: _queues,
            onSearch: (t) => log.add('search $t'),
            onStatus: (s) => log.add('status ${s?.name}'),
            onQueue: (q) => log.add('queue $q'),
            onToggleNotPrinted: () => log.add('notPrinted'),
            onSort: (s) => log.add('sort ${s.name}'),
            onClear: () => log.add('clear'),
          ),
        ),
      ),
    );
  }

  setUp(() => log = []);

  const counts = {
    TokenStatus.waiting: 5,
    TokenStatus.called: 1,
    TokenStatus.entered: 4,
    TokenStatus.skipped: 1,
    TokenStatus.cancelled: 2,
  };

  Future<void> openStatusMenu(WidgetTester tester, String current) async {
    await tester.tap(find.text(current));
    await tester.pumpAndSettle();
  }

  testWidgets('should list every status with its count in a menu', (
    tester,
  ) async {
    await pump(
      tester,
      state: const DeskTableState(loading: false, counts: counts),
      size: const Size(900, 700),
    );
    expect(find.text('Waiting 5'), findsNothing, reason: 'closed menu');

    await openStatusMenu(tester, 'All statuses 13');

    expect(find.text('Waiting 5'), findsOneWidget);
    expect(find.text('Called 1'), findsOneWidget);
    expect(find.text('Missed 1'), findsOneWidget);
    expect(find.text('Entered 4'), findsOneWidget);
    expect(find.text('Cancelled 2'), findsOneWidget);
  });

  testWidgets('should filter by status and clear the status filter', (
    tester,
  ) async {
    await pump(
      tester,
      state: const DeskTableState(loading: false, counts: counts),
      size: const Size(900, 700),
    );

    await openStatusMenu(tester, 'All statuses 13');
    await tester.tap(find.text('Waiting 5'));
    await tester.pumpAndSettle();
    await openStatusMenu(tester, 'All statuses 13');
    await tester.tap(find.text('All statuses 13').last);

    expect(log, ['status waiting', 'status null']);
  });

  testWidgets('should show and mark the chosen status', (tester) async {
    await pump(
      tester,
      state: const DeskTableState(
        loading: false,
        counts: counts,
        query: TokenQuery(status: TokenStatus.called),
      ),
      size: const Size(900, 700),
    );
    expect(find.text('Called 1'), findsOneWidget, reason: 'on the button');

    await openStatusMenu(tester, 'Called 1');

    final item = tester.widget<CheckedPopupMenuItem<int>>(
      find.widgetWithText(CheckedPopupMenuItem<int>, 'Called 1'),
    );
    expect(item.checked, isTrue);
  });

  testWidgets('should keep the queue and status menus on one row', (
    tester,
  ) async {
    await pump(tester, size: const Size(600, 300));

    expect(
      tester.getTopLeft(find.text('All queues')).dy,
      tester.getTopLeft(find.text('All statuses 0')).dy,
    );
  });

  testWidgets('should report what is typed in the search box', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), 'করিম');

    expect(log, ['search করিম']);
  });

  testWidgets('should empty the search box when filters are cleared', (
    tester,
  ) async {
    await pump(
      tester,
      state: const DeskTableState(
        loading: false,
        query: TokenQuery(search: 'করিম'),
      ),
    );
    expect(find.text('করিম'), findsOneWidget);

    await pump(tester);
    await tester.pump();

    expect(find.text('করিম'), findsNothing);
  });

  testWidgets('should filter by queue', (tester) async {
    await pump(tester);

    await tester.tap(find.text('All queues'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report').last);

    expect(log, ['queue report']);
  });

  testWidgets('should toggle the not-printed filter', (tester) async {
    await pump(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Not printed'));

    expect(log, ['notPrinted']);
  });

  testWidgets('should sort from the menu and show the current sort', (
    tester,
  ) async {
    await pump(
      tester,
      state: const DeskTableState(
        loading: false,
        query: TokenQuery(sort: TokenSort.name, ascending: true),
      ),
      // Tall enough for the whole menu.
      size: const Size(900, 700),
    );

    await tester.tap(find.byTooltip('Sort by'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CheckedPopupMenuItem<TokenSort>>(
            find.widgetWithText(CheckedPopupMenuItem<TokenSort>, 'Name'),
          )
          .checked,
      isTrue,
    );
    await tester.tap(find.text('Wait'));
    await tester.pumpAndSettle();

    expect(log, ['sort wait']);
  });

  testWidgets('should offer clear only while a filter is on', (tester) async {
    await pump(tester);
    expect(find.byTooltip('Clear filters'), findsNothing);

    await pump(
      tester,
      state: const DeskTableState(
        loading: false,
        query: TokenQuery(notPrintedOnly: true),
      ),
    );
    await tester.tap(find.byTooltip('Clear filters'));

    expect(log, ['clear']);
  });

  for (final language in ['en', 'bn']) {
    for (final width in [900.0, 600.0, 360.0]) {
      testWidgets('should fit in $language at $width wide', (tester) async {
        await pump(
          tester,
          state: const DeskTableState(loading: false, counts: counts),
          size: Size(width, 600),
          language: language,
        );

        expect(tester.takeException(), isNull);
      });
    }
  }
}
