// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/analytics/domain/analytics_calculator.dart';
import 'package:algoritiq_app/features/analytics/domain/analytics_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dhaka is six hours ahead of UTC.
const _dhaka = Duration(hours: 6);

/// A token issued at [wall] on the clinic's clock (Dhaka).
AnalyticsToken token(
  DateTime wall, {
  String status = 'ENTERED',
  int? fee,
  int? waitedMinutes,
  String queue = 'regular',
  String patient = 'p1',
  String chamber = 'c1',
}) {
  final issued = wall.subtract(_dhaka).millisecondsSinceEpoch;
  return AnalyticsToken(
    issuedAtMs: issued,
    firstCalledAtMs: waitedMinutes == null
        ? null
        : issued + waitedMinutes * 60000,
    status: status,
    queueTypeId: queue,
    patientId: patient,
    chamberId: chamber,
    feeBdt: fee,
  );
}

AnalyticsResult compute(
  AnalyticsPeriod period,
  DateTime day, {
  List<AnalyticsToken> tokens = const [],
  List<AnalyticsSession> sessions = const [],
  List<DateTime> patients = const [],
}) => computeAnalytics(
  period: period,
  day: day,
  offset: _dhaka,
  timeZone: 'Asia/Dhaka',
  tokens: tokens,
  sessions: sessions,
  patientCreatedMs: [
    for (final w in patients) w.subtract(_dhaka).millisecondsSinceEpoch,
  ],
);

void main() {
  // Saturday 7 November 2026.
  final saturday = DateTime.utc(2026, 11, 7);

  group('a day', () {
    test('should give 24 hourly points on the clinic clock', () {
      final result = compute(
        AnalyticsPeriod.day,
        saturday,
        tokens: [token(DateTime.utc(2026, 11, 7, 10, 15), fee: 500)],
      );

      expect(result.series, hasLength(24));
      expect(result.series[10].key, '2026-11-07T10');
      expect(result.series[10].totals.tokens, 1);
      expect(result.series[9].totals.tokens, 0);
      expect(result.fromDate, '2026-11-07');
      expect(result.toDate, '2026-11-07');
    });

    test('should put a token issued after midnight on the clinic day', () {
      // 01:30 Saturday in Dhaka is 19:30 UTC on Friday.
      final result = compute(
        AnalyticsPeriod.day,
        saturday,
        tokens: [token(DateTime.utc(2026, 11, 7, 1, 30))],
      );

      expect(result.totals.tokens, 1);
      expect(result.series[1].totals.tokens, 1);
    });

    test('should compare with the day before', () {
      final result = compute(
        AnalyticsPeriod.day,
        saturday,
        tokens: [
          token(DateTime.utc(2026, 11, 7, 9)),
          token(DateTime.utc(2026, 11, 7, 11)),
          token(DateTime.utc(2026, 11, 6, 9)),
          token(DateTime.utc(2026, 11, 5, 9)),
        ],
      );

      expect(result.totals.tokens, 2);
      expect(result.previous?.tokens, 1);
      expect(result.previousFromDate, '2026-11-06');
    });
  });

  group('a week', () {
    test('should run Monday to Sunday with a point per day', () {
      final result = compute(
        AnalyticsPeriod.week,
        saturday,
        tokens: [
          token(DateTime.utc(2026, 11, 2, 9)),
          token(DateTime.utc(2026, 11, 8, 20)),
          token(DateTime.utc(2026, 11, 9, 9)),
          token(DateTime.utc(2026, 10, 30, 9)),
        ],
      );

      expect(result.fromDate, '2026-11-02');
      expect(result.toDate, '2026-11-08');
      expect(result.series.map((p) => p.key).first, '2026-11-02');
      expect(result.series, hasLength(7));
      // Monday and Sunday are in; the next Monday is not.
      expect(result.totals.tokens, 2);
      expect(result.previous?.tokens, 1);
      expect(result.previousFromDate, '2026-10-26');
      expect(result.previousToDate, '2026-11-01');
    });

    test('should count tokens and fees per weekday, Monday first', () {
      final result = compute(
        AnalyticsPeriod.week,
        saturday,
        tokens: [
          token(DateTime.utc(2026, 11, 7, 9), fee: 300),
          token(DateTime.utc(2026, 11, 7, 10), fee: 200),
        ],
      );

      // Saturday is the sixth day.
      expect(result.byWeekday[5].tokens, 2);
      expect(result.byWeekday[5].feeBdt, 500);
      expect(result.byWeekday[0].tokens, 0);
    });
  });

  group('a month, a year and all time', () {
    test('should give a point for each day of the month', () {
      final result = compute(AnalyticsPeriod.month, saturday);

      expect(result.series, hasLength(30));
      expect(result.fromDate, '2026-11-01');
      expect(result.toDate, '2026-11-30');
      expect(result.previousFromDate, '2026-10-01');
      expect(result.previousToDate, '2026-10-31');
    });

    test('should give a point for each month of the year', () {
      final result = compute(
        AnalyticsPeriod.year,
        saturday,
        tokens: [
          token(DateTime.utc(2026, 3, 5, 9), fee: 100),
          token(DateTime.utc(2025, 3, 5, 9)),
        ],
      );

      expect(result.series, hasLength(12));
      expect(result.series[2].key, '2026-03');
      expect(result.series[2].totals.feeBdt, 100);
      expect(result.previous?.tokens, 1);
    });

    test(
      'should start all time on the first recorded day, a point per year',
      () {
        final result = compute(
          AnalyticsPeriod.all,
          saturday,
          tokens: [
            token(DateTime.utc(2024, 6, 1, 9)),
            token(DateTime.utc(2026, 11, 7, 9)),
          ],
        );

        expect(result.fromDate, '2024-06-01');
        expect(result.series.map((p) => p.key), ['2024', '2025', '2026']);
        expect(result.series[1].totals.tokens, 0);
        expect(result.totals.tokens, 2);
        expect(result.previous, isNull);
      },
    );
  });

  group('the figures', () {
    test('should tell how the tokens ended and add up the fees', () {
      final result = compute(
        AnalyticsPeriod.day,
        saturday,
        tokens: [
          token(DateTime.utc(2026, 11, 7, 9), fee: 500),
          token(DateTime.utc(2026, 11, 7, 9), status: 'SKIPPED', fee: 300),
          // A cancelled token paid nothing.
          token(DateTime.utc(2026, 11, 7, 9), status: 'CANCELLED', fee: 700),
          token(DateTime.utc(2026, 11, 7, 9), status: 'WAITING'),
          token(DateTime.utc(2026, 11, 7, 9), status: 'CALLED'),
        ],
      );

      final totals = result.totals;
      expect(totals.tokens, 5);
      expect(totals.entered, 1);
      expect(totals.skipped, 1);
      expect(totals.cancelled, 1);
      expect(totals.notSeen, 2);
      expect(totals.feeBdt, 800);
    });

    test('should average the wait of the tokens that were called', () {
      final result = compute(
        AnalyticsPeriod.day,
        saturday,
        tokens: [
          token(DateTime.utc(2026, 11, 7, 9), waitedMinutes: 10),
          token(DateTime.utc(2026, 11, 7, 9), waitedMinutes: 30),
          token(DateTime.utc(2026, 11, 7, 9), status: 'WAITING'),
        ],
      );

      expect(result.totals.averageWaitSeconds, 1200);
      expect(result.totals.longestWaitSeconds, 1800);
    });

    test('should leave the wait out when nobody was called', () {
      final result = compute(
        AnalyticsPeriod.day,
        saturday,
        tokens: [token(DateTime.utc(2026, 11, 7, 9), status: 'WAITING')],
      );

      expect(result.totals.averageWaitSeconds, isNull);
      expect(result.totals.longestWaitSeconds, isNull);
    });

    test('should count different patients once', () {
      final result = compute(
        AnalyticsPeriod.day,
        saturday,
        tokens: [
          token(DateTime.utc(2026, 11, 7, 9), patient: 'a'),
          token(DateTime.utc(2026, 11, 7, 10), patient: 'a'),
          token(DateTime.utc(2026, 11, 7, 11), patient: 'b'),
        ],
      );

      expect(result.totals.tokens, 3);
      expect(result.totals.patients, 2);
    });

    test('should count new patients and sessions, with the session length', () {
      final result = compute(
        AnalyticsPeriod.week,
        saturday,
        patients: [
          DateTime.utc(2026, 11, 3, 9),
          DateTime.utc(2026, 11, 7, 9),
          DateTime.utc(2026, 10, 20, 9),
        ],
        sessions: [
          AnalyticsSession(
            chamberId: 'c1',
            openedAtMs: DateTime.utc(2026, 11, 7, 9).millisecondsSinceEpoch,
            closedAtMs: DateTime.utc(2026, 11, 7, 12).millisecondsSinceEpoch,
          ),
          AnalyticsSession(
            chamberId: 'c1',
            openedAtMs: DateTime.utc(2026, 11, 3, 9).millisecondsSinceEpoch,
            closedAtMs: DateTime.utc(2026, 11, 3, 10).millisecondsSinceEpoch,
          ),
          // Still open: counted, but it has no length yet.
          AnalyticsSession(
            chamberId: 'c1',
            openedAtMs: DateTime.utc(2026, 11, 6, 9).millisecondsSinceEpoch,
          ),
        ],
      );

      expect(result.totals.newPatients, 2);
      expect(result.totals.sessions, 3);
      expect(result.totals.averageSessionMinutes, 120);
    });

    test('should split the tokens by queue, busiest first', () {
      final result = computeAnalytics(
        period: AnalyticsPeriod.day,
        day: saturday,
        offset: _dhaka,
        timeZone: 'Asia/Dhaka',
        tokens: [
          token(DateTime.utc(2026, 11, 7, 9), queue: 'regular', fee: 500),
          token(DateTime.utc(2026, 11, 7, 9), queue: 'report', fee: 100),
          token(DateTime.utc(2026, 11, 7, 10), queue: 'report', fee: 100),
        ],
        sessions: const [],
        patientCreatedMs: const [],
        queueNames: {
          'regular': (english: 'Regular', bengali: 'সাধারণ'),
          'report': (english: 'Report', bengali: 'রিপোর্ট'),
        },
      );

      expect(result.byQueue.map((q) => q.englishName), ['Report', 'Regular']);
      expect(result.byQueue.first.totals.feeBdt, 200);
      expect(result.byQueue.last.bengaliName, 'সাধারণ');
    });

    test('should split the tokens by hour of the clinic day', () {
      final result = compute(
        AnalyticsPeriod.month,
        saturday,
        tokens: [
          token(DateTime.utc(2026, 11, 7, 10), fee: 100),
          token(DateTime.utc(2026, 11, 8, 10), fee: 200),
          token(DateTime.utc(2026, 11, 8, 15)),
        ],
      );

      expect(result.byHour[10].tokens, 2);
      expect(result.byHour[10].feeBdt, 300);
      expect(result.byHour[15].tokens, 1);
      expect(result.byHour[0].tokens, 0);
    });
  });

  test('should read a period with nothing in it as zeros', () {
    final result = compute(AnalyticsPeriod.week, saturday);

    expect(result.totals.tokens, 0);
    expect(result.totals.feeBdt, 0);
    expect(result.totals.averageWaitSeconds, isNull);
    expect(result.series.every((p) => p.totals.tokens == 0), isTrue);
    expect(result.byQueue, isEmpty);
  });

  test('should write the result as JSON for the web', () {
    final json = compute(
      AnalyticsPeriod.day,
      saturday,
      tokens: [token(DateTime.utc(2026, 11, 7, 9), fee: 500)],
    ).toJson();

    expect(json['period'], 'day');
    expect(json['granularity'], 'hour');
    expect((json['series']! as List), hasLength(24));
    expect((json['totals']! as Map)['feeBdt'], 500);
    expect((json['byHour']! as List), hasLength(24));
    expect((json['byWeekday']! as List), hasLength(7));
  });
}
