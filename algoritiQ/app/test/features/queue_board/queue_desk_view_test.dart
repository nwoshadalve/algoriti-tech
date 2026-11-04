// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/application/queue_desk_table_controller.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/queue_board/domain/token_query.dart';
import 'package:algoritiq_app/features/queue_board/presentation/queue_desk_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/desk_app.dart';

BoardTokenView _token(
  int serial, {
  String name = 'করিম',
  TokenStatus status = TokenStatus.waiting,
}) => BoardTokenView(
  id: 'token-$serial',
  serial: serial,
  queueTypeId: 'q0',
  queueEnglishName: 'Queue number 0',
  queueBengaliName: 'সাধারণ সারি ০',
  patientId: 'patient-$serial',
  clinicPatientId: '77$serial',
  patientBengaliName: name,
  status: status,
  issuedAt: DateTime.now().subtract(const Duration(minutes: 7)),
  firstCalledAt: status == TokenStatus.waiting ? null : DateTime.now(),
  latestPrintStatus: serial.isEven ? 'SENT' : 'FAILED',
);

List<QueueTypeBoardControl> _queues(int n) => [
  for (var i = 0; i < n; i++)
    QueueTypeBoardControl(
      queueTypeId: 'q$i',
      englishName: 'Queue number $i',
      bengaliName: 'সাধারণ সারি $i',
      waitingCount: i + 1,
      nextSerial: 1001 + i,
      canCallNext: true,
      canRecall: i.isEven,
    ),
];

BoardSnapshot _snapshot(int queues, {BoardTokenView? called}) => BoardSnapshot(
  chamberId: 'chamber',
  chamberName: 'Room 1',
  sessionId: 'session',
  sessionOpen: true,
  calledToken: called,
  queueControls: _queues(queues),
  tokens: const [],
  printerBusyTokenId: null,
);

QueueDeskCallbacks _callbacks(List<String> log) => QueueDeskCallbacks(
  onCall: (id) => log.add('call $id'),
  onRecall: (id) => log.add('recall $id'),
  onEntered: () => log.add('entered'),
  onMissed: () => log.add('missed'),
  onCancelCalled: () => log.add('cancelCalled'),
  onAdd: () => log.add('add'),
  onAddExisting: () => log.add('addExisting'),
  onSearch: (t) => log.add('search $t'),
  onStatus: (s) => log.add('status ${s?.name}'),
  onQueue: (q) => log.add('queue $q'),
  onToggleNotPrinted: () => log.add('notPrinted'),
  onClearFilters: () => log.add('clear'),
  onSort: (s) => log.add('sort ${s.name}'),
  onLoadMore: () => log.add('more'),
  onRetry: () => log.add('retry'),
  onPrint: (t) => log.add('print ${t.serial}'),
  onReprint: (t) => log.add('reprint ${t.serial}'),
  onEditPatient: (t) => log.add('edit ${t.serial}'),
  onCancel: (t) => log.add('cancel ${t.serial}'),
  onEndSession: () => log.add('endSession'),
);

DeskTableState _table(int rows) => DeskTableState(
  items: [for (var i = 0; i < rows; i++) _token(1001 + i)],
  total: rows,
  counts: {TokenStatus.waiting: rows},
  loading: false,
);

void main() {
  final longName = 'মোহাম্মদ আব্দুর রহমান চৌধুরী ' * 3;

  // The desk's own area in dp, below the top bar and above the system bar:
  // the Honor Pad X7 (800×1340 px at 240 dpi) leaves 893×381 in landscape.
  const sizes = {
    'honor pad landscape': Size(893, 381),
    'honor pad portrait': Size(533, 741),
    'large tablet landscape': Size(1280, 680),
    'large tablet portrait': Size(800, 1100),
    'phone portrait': Size(360, 600),
  };

  Future<void> pumpView(
    WidgetTester tester, {
    required Size size,
    required int queues,
    required bool called,
    int rows = 40,
    String language = 'en',
    double textScale = 1,
    Brightness brightness = Brightness.dark,
    List<String>? log,
    DeskTableState? table,
    int? total,
    double keyboard = 0,
  }) async {
    await pumpDeskApp(
      tester,
      Padding(
        padding: const EdgeInsets.all(8),
        child: QueueDeskView(
          snapshot: _snapshot(
            queues,
            called: called
                ? _token(1001, name: longName, status: TokenStatus.called)
                : null,
          ),
          table: table ?? _table(rows),
          callbacks: _callbacks(log ?? []),
        ),
      ),
      size: size,
      language: language,
      textScale: textScale,
      brightness: brightness,
      keyboard: keyboard,
    );
  }

  group('layout matrix', () {
    for (final entry in sizes.entries) {
      for (final queues in [1, 3, 6]) {
        for (final called in [false, true]) {
          testWidgets('should fit on ${entry.key} with $queues queues, '
              '${called ? 'a called patient' : 'nobody called'}', (
            tester,
          ) async {
            await pumpView(
              tester,
              size: entry.value,
              queues: queues,
              called: called,
            );

            expect(tester.takeException(), isNull);
            // A phone is too small to show everything at once; it scrolls as a
            // page. On tablets everything must be on screen without scrolling.
            if (entry.key.startsWith('phone')) return;
            final screen = Offset.zero & entry.value;
            for (final text in ['Queue number 0', 'করিম', if (called) '1001']) {
              final rect = tester.getRect(find.text(text).first);
              expect(
                screen.contains(rect.topLeft) &&
                    screen.contains(rect.bottomRight),
                isTrue,
                reason: '$text is on screen, at $rect',
              );
            }
          });
        }
      }
    }

    for (final language in ['en', 'bn']) {
      for (final scale in [1.0, 1.3]) {
        for (final brightness in Brightness.values) {
          testWidgets(
            'should fit in $language at text x$scale, ${brightness.name}',
            (tester) async {
              for (final size in sizes.values) {
                await pumpView(
                  tester,
                  size: size,
                  queues: 6,
                  called: true,
                  language: language,
                  textScale: scale,
                  brightness: brightness,
                );
                expect(
                  tester.takeException(),
                  isNull,
                  reason: '$size in $language x$scale ${brightness.name}',
                );
              }
            },
          );
        }
      }
    }
  });

  testWidgets('should scroll nothing but the patient list', (tester) async {
    for (final size in [const Size(1340, 800), const Size(800, 1340)]) {
      await pumpView(tester, size: size, queues: 3, called: true);

      final scrollable = <ScrollableState>[
        for (final e in find.byType(Scrollable).evaluate())
          (e as StatefulElement).state as ScrollableState,
      ];
      final scrolling = scrollable.where((s) => s.position.maxScrollExtent > 0);
      expect(scrolling, hasLength(1), reason: 'only the list, at $size');
    }
  });

  testWidgets('should sit the strip beside the table in landscape', (
    tester,
  ) async {
    await pumpView(
      tester,
      size: const Size(1340, 800),
      queues: 3,
      called: false,
    );

    final queueX = tester.getTopLeft(find.text('Queue number 0').first).dx;
    final tableX = tester.getTopLeft(find.text('Patient ID')).dx;
    expect(queueX, lessThan(tableX));
  });

  testWidgets('should stack the parts in portrait', (tester) async {
    await pumpView(
      tester,
      size: const Size(800, 1340),
      queues: 3,
      called: true,
    );

    final nowY = tester.getTopLeft(find.text('1001').first).dy;
    final queueY = tester.getTopLeft(find.text('Queue number 0').first).dy;
    final tableY = tester.getTopLeft(find.text('Patient ID')).dy;
    expect(nowY, lessThan(queueY));
    expect(queueY, lessThan(tableY));
  });

  testWidgets('should pass every action through', (tester) async {
    final log = <String>[];
    await pumpView(
      tester,
      size: const Size(1340, 800),
      queues: 2,
      called: true,
      rows: 3,
      log: log,
    );

    await tester.tap(find.text('Add'));
    await tester.tap(find.text('Add existing'));
    await tester.tap(find.text('Call').first);
    await tester.tap(find.text('Entered').first);
    await tester.tap(find.text('All statuses 3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Waiting 3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Serial'));
    await tester.tap(find.text('End session'));

    expect(log, [
      'add',
      'addExisting',
      'call q0',
      'entered',
      'status waiting',
      'sort serial',
      'endSession',
    ]);
  });

  testWidgets('should show the session title with the matching total', (
    tester,
  ) async {
    await pumpView(
      tester,
      size: const Size(1340, 800),
      queues: 1,
      called: false,
      rows: 3,
    );

    expect(find.text("Today's session"), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('should offer to clear filters only while one is on', (
    tester,
  ) async {
    final log = <String>[];
    await pumpView(
      tester,
      size: const Size(1280, 680),
      queues: 2,
      called: false,
      log: log,
    );
    expect(find.byTooltip('Clear filters'), findsNothing);

    await pumpView(
      tester,
      size: const Size(1280, 680),
      queues: 2,
      called: false,
      log: log,
      table: DeskTableState(
        query: const TokenQuery(notPrintedOnly: true),
        items: [_token(1001)],
        total: 1,
        loading: false,
      ),
    );
    await tester.tap(find.byTooltip('Clear filters'));

    expect(log, ['clear']);
  });

  group('typing in the search box', () {
    const landscape = Size(893, 381);
    // The keyboard of the Honor Pad covers roughly half of a landscape screen.
    const keyboard = 200.0;

    Future<void> focusSearchThenOpenKeyboard(
      WidgetTester tester,
      Size size,
    ) async {
      await pumpView(tester, size: size, queues: 3, called: true);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await pumpView(
        tester,
        size: size,
        queues: 3,
        called: true,
        keyboard: keyboard,
      );
      await tester.pump();
    }

    for (final size in [landscape, const Size(533, 741)]) {
      testWidgets('should keep the search box above the keyboard at $size', (
        tester,
      ) async {
        await focusSearchThenOpenKeyboard(tester, size);

        expect(tester.takeException(), isNull);
        final box = tester.getRect(find.byType(TextField));
        expect(box.bottom, lessThanOrEqualTo(size.height - keyboard));
        expect(box.top, greaterThanOrEqualTo(0));
        // Only the table is left, with its first rows in the room that is.
        expect(find.text("Today's session"), findsNothing);
        expect(find.text('Call'), findsNothing);
        final row = tester.getRect(find.text('করিম').first);
        expect(row.bottom, lessThanOrEqualTo(size.height - keyboard));
      });

      testWidgets('should keep the keyboard open while the desk rearranges', (
        tester,
      ) async {
        await focusSearchThenOpenKeyboard(tester, size);

        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.focusNode!.hasFocus, isTrue);
      });
    }

    testWidgets('should show the whole desk again when the keyboard closes', (
      tester,
    ) async {
      await focusSearchThenOpenKeyboard(tester, landscape);
      await pumpView(tester, size: landscape, queues: 3, called: true);
      await tester.pump();

      expect(find.text('Queue number 0'), findsWidgets);
      expect(find.text("Today's session"), findsOneWidget);
    });

    testWidgets('should leave the desk alone when a dialog opens the keyboard', (
      tester,
    ) async {
      // The search box has no focus, so the keyboard belongs to something else.
      await pumpView(
        tester,
        size: landscape,
        queues: 3,
        called: true,
        keyboard: keyboard,
      );

      expect(find.text('Queue number 0'), findsWidgets);
    });
  });
}
