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
  patientName: name,
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
  calledTokens: [?called],
  queueControls: _queues(queues),
  tokens: const [],
  printerBusyTokenId: null,
);

QueueDeskCallbacks _callbacks(List<String> log) => QueueDeskCallbacks(
  onCall: (id) => log.add('call $id'),
  onRecall: (id) => log.add('recall $id'),
  onEntered: (t) => log.add('entered ${t.serial}'),
  onMissed: (t) => log.add('missed ${t.serial}'),
  onCancelCalled: (t) => log.add('cancelCalled ${t.serial}'),
  onAdd: () => log.add('add'),
  onAddExisting: () => log.add('addExisting'),
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
        // A new desk each time, so it opens on Calling again.
        child: QueueDeskView(
          key: UniqueKey(),
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

  /// Opens the Patients tab.
  Future<void> openPatients(WidgetTester tester) async {
    await tester.tap(find.textContaining('Patients'));
    await tester.pumpAndSettle();
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
            for (final text in ['Queue number 0', if (called) '1001']) {
              final rect = tester.getRect(find.text(text).first);
              expect(
                screen.contains(rect.topLeft) &&
                    screen.contains(rect.bottomRight),
                isTrue,
                reason: '$text is on screen, at $rect',
              );
            }
            // Up to three queues are all on screen at once, each with Call.
            if (queues <= 3) {
              final calls = find.widgetWithText(FilledButton, 'Call');
              // A queue that is calling has no Call button.
              expect(calls, findsNWidgets(called ? queues - 1 : queues));
              for (final call in calls.evaluate()) {
                final rect = tester.getRect(find.byWidget(call.widget));
                expect(
                  screen.contains(rect.topLeft) &&
                      screen.contains(rect.bottomRight),
                  isTrue,
                  reason: 'Call is on screen, at $rect',
                );
              }
            }
            // The patients are on the other tab, with the whole screen.
            await openPatients(tester);
            final row = tester.getRect(find.text('করিম').first);
            expect(
              screen.contains(row.topLeft) && screen.contains(row.bottomRight),
              isTrue,
              reason: 'the first patient is on screen, at $row',
            );
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

  int scrolling(WidgetTester tester) => [
    for (final e in find.byType(Scrollable).evaluate())
      (e as StatefulElement).state as ScrollableState,
  ].where((s) => s.position.maxScrollExtent > 0).length;

  testWidgets(
    'should scroll nothing on Calling and only the list on Patients',
    (tester) async {
      for (final size in [const Size(1340, 800), const Size(800, 1340)]) {
        await pumpView(tester, size: size, queues: 3, called: true);
        expect(
          scrolling(tester),
          0,
          reason: 'Calling does not scroll, at $size',
        );

        await openPatients(tester);
        expect(scrolling(tester), 1, reason: 'only the list, at $size');
      }
    },
  );

  testWidgets('should open on Calling and switch to the patients and back', (
    tester,
  ) async {
    await pumpView(
      tester,
      size: const Size(1340, 800),
      queues: 3,
      called: true,
    );

    expect(find.text('Queue number 0'), findsOneWidget);
    expect(find.text('Patient ID'), findsNothing);

    await openPatients(tester);
    expect(find.text('Patient ID'), findsOneWidget);
    expect(find.text('Queue number 0'), findsWidgets);

    await tester.tap(find.textContaining('Calling'));
    await tester.pumpAndSettle();
    expect(find.text('Patient ID'), findsNothing);
    expect(find.text('1001'), findsOneWidget);
  });

  testWidgets('should show how many are calling and how many patients', (
    tester,
  ) async {
    await pumpView(
      tester,
      size: const Size(1340, 800),
      queues: 2,
      called: true,
      rows: 3,
    );

    expect(find.text('Calling 1'), findsOneWidget);
    expect(find.text('Patients 3'), findsOneWidget);
  });

  testWidgets('should keep the Add buttons on both tabs', (tester) async {
    final log = <String>[];
    await pumpView(
      tester,
      size: const Size(1340, 800),
      queues: 2,
      called: false,
      log: log,
    );

    await tester.tap(find.text('Add'));
    await openPatients(tester);
    await tester.tap(find.text('Add existing'));

    expect(log, ['add', 'addExisting']);
  });

  testWidgets('should put the Add buttons under the tabs on a narrow pane', (
    tester,
  ) async {
    await pumpView(
      tester,
      size: const Size(360, 700),
      queues: 2,
      called: false,
    );

    final tabsY = tester.getTopLeft(find.textContaining('Calling')).dy;
    final addY = tester.getTopLeft(find.text('Add')).dy;
    expect(addY, greaterThan(tabsY));
    expect(tester.takeException(), isNull);
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
    await tester.tap(find.text('End session'));
    await openPatients(tester);
    await tester.tap(find.text('All statuses 3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Waiting 3'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Serial'));

    expect(log, [
      'add',
      'addExisting',
      // q0 is calling, so its Call is gone; the first Call is q1's.
      'call q1',
      'entered 1001',
      'endSession',
      'status waiting',
      'sort serial',
    ]);
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
    await openPatients(tester);
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
    await openPatients(tester);
    await tester.tap(find.byTooltip('Clear filters'));

    expect(log, ['clear']);
  });

  group('keyboard', () {
    const landscape = Size(893, 381);

    testWidgets('should have no search box on the desk', (tester) async {
      await pumpView(tester, size: landscape, queues: 3, called: true);

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets(
      'should leave the desk alone when a dialog opens the keyboard',
      (tester) async {
        await pumpView(
          tester,
          size: landscape,
          queues: 3,
          called: true,
          keyboard: 200,
        );

        expect(find.text('Queue number 0'), findsWidgets);
        expect(find.text('Patients 40'), findsOneWidget);
      },
    );
  });
}
