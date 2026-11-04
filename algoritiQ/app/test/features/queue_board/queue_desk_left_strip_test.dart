// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/queue_board/presentation/queue_desk_now_calling.dart';
import 'package:algoritiq_app/features/queue_board/presentation/queue_desk_queue_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/desk_app.dart';

BoardTokenView _called({String? name}) => BoardTokenView(
  id: 'token-1',
  serial: 1001,
  queueTypeId: 'regular',
  queueEnglishName: 'Regular',
  queueBengaliName: 'সাধারণ',
  patientId: 'patient-1',
  clinicPatientId: '7761',
  patientBengaliName: name ?? 'করিম',
  status: TokenStatus.called,
  issuedAt: DateTime.utc(2026),
);

List<QueueTypeBoardControl> _queues(int n, {bool canCall = true}) => [
  for (var i = 0; i < n; i++)
    QueueTypeBoardControl(
      queueTypeId: 'q$i',
      englishName: 'Queue number $i',
      bengaliName: 'সাধারণ সারি $i',
      waitingCount: i,
      nextSerial: 1001 + i,
      canCallNext: canCall,
      canRecall: i.isEven,
    ),
];

void main() {
  late List<String> log;
  setUp(() => log = []);

  Widget nowCalling(BoardTokenView? called) => Align(
    alignment: Alignment.topLeft,
    child: DeskNowCalling(
      called: called,
      onRecall: () => log.add('recall'),
      onEntered: () => log.add('entered'),
      onMissed: () => log.add('missed'),
      onCancel: () => log.add('cancel'),
    ),
  );

  group('Now calling', () {
    final longName = 'মোহাম্মদ আব্দুর রহমান চৌধুরী ' * 3;

    for (final width in [360.0, 800.0]) {
      testWidgets('should stay short with a very long name at $width wide', (
        tester,
      ) async {
        await pumpDeskApp(
          tester,
          SizedBox(
            width: width,
            child: nowCalling(_called(name: longName)),
          ),
          size: Size(width, 700),
        );

        expect(tester.takeException(), isNull);
        final height = tester.getSize(find.byType(DeskNowCalling)).height;
        // The test font is far wider than the brand font, so the four actions
        // wrap to two lines here; on the tablet they fit on one (~120 dp).
        expect(height, lessThanOrEqualTo(200), reason: '$height dp tall');
      });
    }

    testWidgets('should be a single line when nobody is called', (
      tester,
    ) async {
      await pumpDeskApp(
        tester,
        SizedBox(width: 360, child: nowCalling(null)),
        size: const Size(360, 700),
      );

      expect(find.text('No patient is being called.'), findsOneWidget);
      expect(tester.getSize(find.byType(DeskNowCalling)).height, lessThan(80));
    });

    testWidgets('should show the serial, name, id, queue and four actions', (
      tester,
    ) async {
      await pumpDeskApp(
        tester,
        SizedBox(width: 360, child: nowCalling(_called())),
        size: const Size(360, 700),
      );

      expect(find.text('1001'), findsOneWidget);
      expect(find.text('করিম'), findsOneWidget);
      expect(find.textContaining('7761'), findsOneWidget);
      for (final action in ['Recall', 'Entered', 'Missed', 'Cancel']) {
        await tester.tap(find.text(action));
      }
      expect(log, ['recall', 'entered', 'missed', 'cancel']);
    });
  });

  group('Queue controls', () {
    Widget controls(
      int n, {
      required bool tiles,
      bool canCall = true,
      String? busy,
    }) => DeskQueueControls(
      controls: _queues(n, canCall: canCall),
      horizontalTiles: tiles,
      busyQueueId: busy,
      onCall: (id) => log.add('call $id'),
      onRecall: (id) => log.add('recall $id'),
    );

    for (final n in [1, 3, 6]) {
      testWidgets('should fit $n queues as rows in a narrow strip', (
        tester,
      ) async {
        await pumpDeskApp(
          tester,
          SizedBox(width: 360, height: 400, child: controls(n, tiles: false)),
          size: const Size(360, 700),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Call'), findsWidgets);
      });

      testWidgets('should fit $n queues as tiles across a wide pane', (
        tester,
      ) async {
        await pumpDeskApp(
          tester,
          SizedBox(width: 800, child: controls(n, tiles: true)),
          size: const Size(800, 700),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Call'), findsNWidgets(n));
      });
    }

    testWidgets('should scroll only when the rows cannot fit', (tester) async {
      await pumpDeskApp(
        tester,
        SizedBox(width: 360, height: 200, child: controls(6, tiles: false)),
        size: const Size(360, 700),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(Scrollable), findsOneWidget);
    });

    testWidgets('should send the queue id with Call and Recall', (
      tester,
    ) async {
      await pumpDeskApp(
        tester,
        SizedBox(width: 360, height: 400, child: controls(3, tiles: false)),
        size: const Size(360, 700),
      );

      await tester.tap(find.text('Call').first);
      await tester.tap(find.text('Recall').first);

      expect(log, ['call q0', 'recall q0']);
    });

    testWidgets('should disable Call when no one can be called', (
      tester,
    ) async {
      await pumpDeskApp(
        tester,
        SizedBox(
          width: 360,
          height: 400,
          child: controls(2, tiles: false, canCall: false),
        ),
        size: const Size(360, 700),
      );

      await tester.tap(find.text('Call').first, warnIfMissed: false);

      expect(log, isEmpty);
      expect(find.textContaining('Resolve serial'), findsNothing);
    });
  });
}
