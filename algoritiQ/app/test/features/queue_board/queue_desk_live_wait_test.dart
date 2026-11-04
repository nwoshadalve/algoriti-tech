// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/queue_board/presentation/queue_desk_format.dart';
import 'package:algoritiq_app/features/queue_board/presentation/queue_desk_live_wait.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

BoardTokenView _token({
  required DateTime issuedAt,
  TokenStatus status = TokenStatus.waiting,
  DateTime? firstCalledAt,
  DateTime? cancelledAt,
}) => BoardTokenView(
  id: 't',
  serial: 1001,
  queueTypeId: 'regular',
  queueEnglishName: 'Regular',
  queueBengaliName: 'সাধারণ',
  patientId: 'p',
  clinicPatientId: '7761',
  patientBengaliName: 'করিম',
  status: status,
  issuedAt: issuedAt,
  firstCalledAt: firstCalledAt,
  cancelledAt: cancelledAt,
);

void main() {
  group('queueDeskWaitClock', () {
    const en = Locale('en');
    const bn = Locale('bn');

    test('should show minutes and seconds under an hour', () {
      expect(queueDeskWaitClock(Duration.zero, en), '00:00');
      expect(queueDeskWaitClock(const Duration(seconds: 5), en), '00:05');
      expect(
        queueDeskWaitClock(const Duration(minutes: 59, seconds: 59), en),
        '59:59',
      );
    });

    test('should add hours from one hour on', () {
      expect(queueDeskWaitClock(const Duration(hours: 1), en), '1:00:00');
      expect(
        queueDeskWaitClock(
          const Duration(hours: 12, minutes: 3, seconds: 9),
          en,
        ),
        '12:03:09',
      );
    });

    test('should never go negative', () {
      expect(queueDeskWaitClock(const Duration(seconds: -30), en), '00:00');
    });

    test('should use Bengali digits in Bengali', () {
      expect(
        queueDeskWaitClock(const Duration(minutes: 12, seconds: 5), bn),
        '১২:০৫',
      );
    });
  });

  group('DeskLiveWait', () {
    final start = DateTime.utc(2026, 11, 4, 9);
    late DateTime now;

    setUp(() {
      now = start;
      deskNow = () => now;
    });
    tearDown(() => deskNow = DateTime.now);

    /// Moves the clock on and lets the row's timer fire.
    Future<void> pass(WidgetTester tester, Duration by) async {
      now = now.add(by);
      await tester.pump(by);
    }

    Future<void> pump(WidgetTester tester, BoardTokenView token) =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DeskLiveWait(token: token)),
          ),
        );

    testWidgets('should count up every second while the patient waits', (
      tester,
    ) async {
      await pump(tester, _token(issuedAt: start));

      await pass(tester, const Duration(seconds: 5));
      expect(find.text('00:05'), findsOneWidget);

      await pass(tester, const Duration(seconds: 1));
      expect(find.text('00:06'), findsOneWidget);
    });

    testWidgets('should keep counting after being hidden and shown again', (
      tester,
    ) async {
      // A filter or a page switch removes the row and builds it again later.
      final token = _token(issuedAt: start);
      await pump(tester, token);
      await pass(tester, const Duration(seconds: 3));
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      now = now.add(const Duration(seconds: 10));

      await pump(tester, token);
      expect(find.text('00:13'), findsOneWidget);
      await pass(tester, const Duration(seconds: 2));

      expect(find.text('00:15'), findsOneWidget);
    });

    testWidgets('should stay frozen at the first call', (tester) async {
      final token = _token(
        issuedAt: start,
        status: TokenStatus.called,
        firstCalledAt: start.add(const Duration(minutes: 2, seconds: 30)),
      );
      await pump(tester, token);

      await pass(tester, const Duration(hours: 1));

      expect(find.text('02:30'), findsOneWidget);
    });

    testWidgets('should stop counting when the patient is called', (
      tester,
    ) async {
      await pump(tester, _token(issuedAt: start));
      await pass(tester, const Duration(seconds: 4));

      await pump(
        tester,
        _token(
          issuedAt: start,
          status: TokenStatus.called,
          firstCalledAt: start.add(const Duration(seconds: 4)),
        ),
      );
      await pass(tester, const Duration(minutes: 5));

      expect(find.text('00:04'), findsOneWidget);
    });

    testWidgets('should stay frozen when cancelled before a call', (
      tester,
    ) async {
      final token = _token(
        issuedAt: start,
        status: TokenStatus.cancelled,
        cancelledAt: start.add(const Duration(minutes: 4)),
      );
      await pump(tester, token);

      await pass(tester, const Duration(hours: 3));

      expect(find.text('04:00'), findsOneWidget);
    });

    testWidgets('should show zero for an issue time in the future', (
      tester,
    ) async {
      await pump(tester, _token(issuedAt: start.add(const Duration(hours: 2))));

      await pass(tester, const Duration(seconds: 1));

      expect(find.text('00:00'), findsOneWidget);
    });
  });
}
