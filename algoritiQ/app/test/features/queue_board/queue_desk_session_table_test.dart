// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/core/widgets/brand_loader.dart';
import 'package:algoritiq_app/features/queue_board/application/queue_desk_table_controller.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/queue_board/domain/token_query.dart';
import 'package:algoritiq_app/features/queue_board/presentation/queue_desk_live_wait.dart';
import 'package:algoritiq_app/features/queue_board/presentation/queue_desk_session_table.dart';
import 'package:algoritiq_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

BoardTokenView _token(
  int serial,
  String name, {
  TokenStatus status = TokenStatus.waiting,
  String? print,
  String queue = 'regular',
}) => BoardTokenView(
  id: 'token-$serial',
  serial: serial,
  queueTypeId: queue,
  queueEnglishName: queue == 'regular' ? 'Regular' : 'Report',
  queueBengaliName: queue == 'regular' ? 'সাধারণ' : 'রিপোর্ট',
  patientId: 'patient-$serial',
  clinicPatientId: '77$serial',
  patientBengaliName: name,
  status: status,
  issuedAt: DateTime.now().subtract(const Duration(minutes: 12)),
  firstCalledAt: status == TokenStatus.waiting
      ? null
      : DateTime.now().subtract(const Duration(minutes: 9)),
  latestPrintStatus: print,
);

void main() {
  final threeTokens = [
    _token(1003, 'করিম', print: 'FAILED'),
    _token(1002, 'রহিমা', status: TokenStatus.called, print: 'SENT'),
    _token(1001, 'সালমা', status: TokenStatus.cancelled, print: 'FAILED'),
  ];

  late List<String> log;

  Future<void> pump(
    WidgetTester tester, {
    required Size size,
    DeskTableState? state,
    String language = 'en',
    double textScale = 1,
    String? busy,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: Locale(language),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
            ),
            child: Scaffold(
              body: QueueDeskTokenTable(
                state:
                    state ??
                    DeskTableState(
                      items: threeTokens,
                      total: 3,
                      loading: false,
                    ),
                printerBusyTokenId: busy,
                onSort: (s) => log.add('sort ${s.name}'),
                onLoadMore: () => log.add('more'),
                onRetry: () => log.add('retry'),
                onClearFilters: () => log.add('clear'),
                onPrint: (t) => log.add('print ${t.serial}'),
                onReprint: (t) => log.add('reprint ${t.serial}'),
                onEditPatient: (t) => log.add('edit ${t.serial}'),
                onCancel: (t) => log.add('cancel ${t.serial}'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  setUp(() => log = []);

  testWidgets('should list the columns in the requested order', (tester) async {
    await pump(tester, size: const Size(900, 600));

    double x(String text) => tester.getTopLeft(find.text(text).first).dx;
    final headings = [
      'Patient ID',
      'Name',
      'Serial',
      'Queue',
      'Wait',
      'Status',
    ].map(x).toList();
    expect(headings, [...headings]..sort());

    final waitX = tester.getTopLeft(find.byType(DeskLiveWait).first).dx;
    final row = [
      x('771003'),
      x('করিম'),
      x('1003'),
      x('Regular'),
      waitX,
      x('Waiting'),
    ];
    expect(row, [...row]..sort(), reason: 'the row follows the headings');
  });

  testWidgets('should sort when a heading is tapped and say which way', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(
      tester,
      size: const Size(900, 600),
      state: DeskTableState(
        query: const TokenQuery(sort: TokenSort.name, ascending: true),
        items: threeTokens,
        total: 3,
        loading: false,
      ),
    );

    expect(find.bySemanticsLabel(RegExp('Name.*sorted ascending')), findsOne);
    await tester.tap(find.text('Serial'));
    await tester.tap(find.text('Patient ID'));
    await tester.tap(find.text('Queue'));
    await tester.tap(find.text('Wait'));
    await tester.tap(find.text('Status'));
    await tester.tap(find.text('Name'));

    expect(log, [
      'sort serial',
      'sort id',
      'sort queue',
      'sort wait',
      'sort status',
      'sort name',
    ]);
    semantics.dispose();
  });

  testWidgets('should wrap a very long Bengali name without overflowing', (
    tester,
  ) async {
    final name = 'আব্দুর রহমান ' * 8;
    await pump(
      tester,
      size: const Size(560, 600),
      state: DeskTableState(
        items: [_token(1001, name)],
        total: 1,
        loading: false,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(name), findsOneWidget);
  });

  testWidgets('should show a print icon only where a slip is still needed', (
    tester,
  ) async {
    await pump(tester, size: const Size(900, 600));

    // 1003 failed (needs print); 1002 printed; 1001 cancelled.
    expect(find.byIcon(Icons.print_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.print_outlined));
    expect(log, ['print 1003']);
  });

  testWidgets('should show printing as busy, not as an icon to tap', (
    tester,
  ) async {
    await pump(
      tester,
      size: const Size(900, 600),
      state: DeskTableState(
        items: [_token(1001, 'করিম', print: 'PENDING')],
        total: 1,
        loading: false,
      ),
    );

    expect(find.byIcon(Icons.print_outlined), findsNothing);
    expect(
      tester.widget<BrandLoader>(find.byType(BrandLoader)).semanticLabel,
      'Printing',
    );
  });

  testWidgets('should hold the print icon while a slip is printing', (
    tester,
  ) async {
    await pump(tester, size: const Size(900, 600), busy: 'token-9');

    await tester.tap(find.byIcon(Icons.print_outlined), warnIfMissed: false);

    expect(log, isEmpty);
  });

  testWidgets('should offer edit, reprint and cancel in the menu', (
    tester,
  ) async {
    await pump(tester, size: const Size(900, 600));

    await tester.tap(find.byIcon(Icons.more_horiz).at(1)); // called + printed
    await tester.pumpAndSettle();
    expect(find.text('Edit patient'), findsOneWidget);
    expect(find.text('Reprint'), findsOneWidget);
    expect(find.text('Cancel token'), findsOneWidget);
    await tester.tap(find.text('Reprint'));
    await tester.pumpAndSettle();
    expect(log, ['reprint 1002']);
  });

  testWidgets('should not offer cancel or reprint for a cancelled token', (
    tester,
  ) async {
    await pump(tester, size: const Size(900, 600));

    await tester.tap(find.byIcon(Icons.more_horiz).last);
    await tester.pumpAndSettle();

    expect(find.text('Edit patient'), findsOneWidget);
    expect(find.text('Cancel token'), findsNothing);
    expect(find.text('Reprint'), findsNothing);
  });

  for (final status in [TokenStatus.entered, TokenStatus.skipped]) {
    testWidgets('should hide print and reprint when status is $status', (
      tester,
    ) async {
      await pump(
        tester,
        size: const Size(900, 600),
        state: DeskTableState(
          items: [_token(1001, 'করিম', status: status, print: 'FAILED')],
          total: 1,
          loading: false,
        ),
      );

      expect(find.byIcon(Icons.print_outlined), findsNothing);
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      expect(find.text('Reprint'), findsNothing);
    });
  }

  testWidgets('should ask for the next page when scrolled to the end', (
    tester,
  ) async {
    await pump(
      tester,
      size: const Size(900, 400),
      state: DeskTableState(
        items: [for (var i = 0; i < 30; i++) _token(1001 + i, 'রোগী $i')],
        total: 80,
        loading: false,
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pump();

    expect(log, contains('more'));
  });

  testWidgets('should offer a retry when loading failed', (tester) async {
    await pump(
      tester,
      size: const Size(900, 600),
      state: const DeskTableState(loading: false, failed: true),
    );

    await tester.tap(find.text('Try again'));

    expect(find.text('Could not load patients.'), findsOneWidget);
    expect(log, ['retry']);
  });

  testWidgets('should say nothing matches and offer to clear filters', (
    tester,
  ) async {
    await pump(
      tester,
      size: const Size(900, 600),
      state: const DeskTableState(
        query: TokenQuery(search: 'xyz'),
        loading: false,
      ),
    );

    expect(find.text('No patients match.'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    expect(log, ['clear']);
  });

  testWidgets('should invite the first patient when the session is empty', (
    tester,
  ) async {
    await pump(
      tester,
      size: const Size(900, 600),
      state: const DeskTableState(loading: false),
    );

    expect(find.text('No tokens issued yet.'), findsOneWidget);
    expect(find.text('Clear filters'), findsNothing);
  });

  testWidgets('should become cards on a narrow pane', (tester) async {
    await pump(tester, size: const Size(400, 700));

    expect(find.text('Patient ID'), findsNothing);
    expect(find.text('করিম'), findsOneWidget);
    expect(find.textContaining('771003'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'bn']) {
    for (final scale in [1.0, 1.3]) {
      for (final width in [900.0, 400.0]) {
        testWidgets('should fit in $language, text x$scale, $width wide', (
          tester,
        ) async {
          await pump(
            tester,
            size: Size(width, 600),
            language: language,
            textScale: scale,
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('should write the table in Bengali', (tester) async {
    await pump(tester, size: const Size(900, 600), language: 'bn');

    expect(find.text('রোগীর আইডি'), findsOneWidget);
    expect(find.text('অপেক্ষায়'), findsOneWidget);
    expect(find.text('সাধারণ'), findsWidgets);
    expect(find.text('১০০৩'), findsOneWidget);
  });
}
