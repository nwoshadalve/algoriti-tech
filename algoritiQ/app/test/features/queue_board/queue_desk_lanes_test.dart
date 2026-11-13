// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/queue_board/presentation/queue_desk_lanes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/desk_app.dart';

BoardTokenView _token(
  String queue,
  int serial,
  String name, {
  bool announced = true,
}) => BoardTokenView(
  announced: announced,
  id: 't$serial',
  serial: serial,
  queueTypeId: queue,
  queueEnglishName: queue,
  queueBengaliName: queue,
  patientId: 'p$serial',
  clinicPatientId: '77$serial',
  patientName: name,
  status: TokenStatus.called,
  issuedAt: DateTime.utc(2026),
);

QueueTypeBoardControl _control(
  String id, {
  bool canCall = true,
  int waiting = 2,
}) => QueueTypeBoardControl(
  queueTypeId: id,
  englishName: 'Queue $id',
  bengaliName: 'কিউ $id',
  waitingCount: waiting,
  nextSerial: 9,
  canCallNext: canCall,
  canRecall: !canCall,
);

void main() {
  late List<String> log;
  setUp(() => log = []);

  Future<void> pump(
    WidgetTester tester, {
    required List<QueueTypeBoardControl> controls,
    List<BoardTokenView> called = const [],
    String? busy,
    Size size = const Size(893, 381),
  }) => pumpDeskApp(
    tester,
    Padding(
      padding: const EdgeInsets.all(8),
      child: DeskQueueLanes(
        controls: controls,
        called: called,
        busyQueueId: busy,
        onCall: (id) => log.add('call $id'),
        onRecall: (id) => log.add('recall $id'),
        onEntered: (t) => log.add('entered ${t.serial}'),
        onMissed: (t) => log.add('missed ${t.serial}'),
        onCancel: (t) => log.add('cancel ${t.serial}'),
        onEndSession: () => log.add('end'),
      ),
    ),
    size: size,
  );

  testWidgets('should show every queue and give each its own Call', (
    tester,
  ) async {
    await pump(tester, controls: [_control('a'), _control('b'), _control('c')]);

    await tester.tap(find.text('Call').at(1));

    expect(find.text('Call'), findsNWidgets(3));
    expect(log, ['call b']);
  });

  testWidgets('should keep the actions with the patient of their queue', (
    tester,
  ) async {
    await pump(
      tester,
      controls: [_control('a', canCall: false), _control('b', canCall: false)],
      called: [_token('a', 104, 'করিম'), _token('b', 201, 'রহিম')],
    );

    await tester.tap(find.text('Entered').last);
    await tester.tap(find.text('Missed').first);
    await tester.tap(find.text('Recall').last);
    await tester.tap(find.text('Cancel').first);

    expect(log, ['entered 201', 'missed 104', 'recall b', 'cancel 104']);
  });

  testWidgets('should let Call announce a token that came up by itself', (
    tester,
  ) async {
    await pump(
      tester,
      controls: [_control('a', canCall: false)],
      called: [_token('a', 104, 'করিম', announced: false)],
    );

    // The queue has no Call button of its own while it is calling; the one
    // with the patient makes the first announcement.
    expect(find.widgetWithText(FilledButton, 'Call'), findsOneWidget);
    expect(find.text('Recall'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Call'));

    expect(log, ['recall a']);
  });

  testWidgets('should show no Call button for a queue that is calling', (
    tester,
  ) async {
    await pump(
      tester,
      controls: [_control('a', canCall: false), _control('b')],
      called: [_token('a', 104, 'করিম')],
    );

    // Only the idle queue has one; the calling queue has Recall instead.
    expect(find.widgetWithText(FilledButton, 'Call'), findsOneWidget);
    expect(find.text('Recall'), findsOneWidget);
  });

  testWidgets(
    'should show no patient actions for a queue that is not calling',
    (tester) async {
      await pump(
        tester,
        controls: [_control('a', canCall: false), _control('b')],
        called: [_token('a', 104, 'করিম')],
      );

      expect(find.text('Entered'), findsOneWidget);
      expect(find.text('No patient is being called.'), findsOneWidget);
    },
  );

  testWidgets('should not let a busy or blocked queue be called again', (
    tester,
  ) async {
    await pump(
      tester,
      controls: [_control('a', canCall: false), _control('b')],
      busy: 'b',
    );

    await tester.tap(find.byType(FilledButton).first, warnIfMissed: false);
    await tester.tap(find.byType(FilledButton).at(1), warnIfMissed: false);

    expect(log, isEmpty);
  });

  testWidgets('should end the session from the small button', (tester) async {
    await pump(tester, controls: [_control('a')]);

    await tester.tap(find.text('End session'));

    expect(log, ['end']);
  });

  testWidgets(
    'should stack the patient and actions under the name when narrow',
    (tester) async {
      await pump(
        tester,
        size: const Size(360, 700),
        controls: [_control('a', canCall: false)],
        called: [_token('a', 104, 'করিম')],
      );

      final nameY = tester.getTopLeft(find.text('Queue a')).dy;
      final patientY = tester.getTopLeft(find.text('104')).dy;
      final actionsY = tester.getTopLeft(find.text('Entered')).dy;
      expect(tester.takeException(), isNull);
      expect(nameY, lessThan(patientY));
      expect(patientY, lessThan(actionsY));
    },
  );
}
