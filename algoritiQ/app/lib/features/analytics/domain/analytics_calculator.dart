// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'analytics_models.dart';

/// The days an analytics period covers, in clinic time. [from] and [to] are
/// both included; each is midnight UTC of that calendar day.
final class AnalyticsRange {
  const AnalyticsRange({
    required this.from,
    required this.to,
    this.previousFrom,
    this.previousTo,
  });

  final DateTime from;
  final DateTime to;
  final DateTime? previousFrom;
  final DateTime? previousTo;

  /// The range [period] gives around [day]. For [AnalyticsPeriod.all] it runs
  /// from [firstDay] (or [day]) to [day].
  static AnalyticsRange of(
    AnalyticsPeriod period,
    DateTime day, {
    DateTime? firstDay,
  }) {
    final d = DateTime.utc(day.year, day.month, day.day);
    switch (period) {
      case AnalyticsPeriod.day:
        final before = d.subtract(const Duration(days: 1));
        return AnalyticsRange(
          from: d,
          to: d,
          previousFrom: before,
          previousTo: before,
        );
      case AnalyticsPeriod.week:
        final monday = d.subtract(Duration(days: d.weekday - 1));
        return AnalyticsRange(
          from: monday,
          to: monday.add(const Duration(days: 6)),
          previousFrom: monday.subtract(const Duration(days: 7)),
          previousTo: monday.subtract(const Duration(days: 1)),
        );
      case AnalyticsPeriod.month:
        return AnalyticsRange(
          from: DateTime.utc(d.year, d.month),
          to: DateTime.utc(d.year, d.month + 1, 0),
          previousFrom: DateTime.utc(d.year, d.month - 1),
          previousTo: DateTime.utc(d.year, d.month, 0),
        );
      case AnalyticsPeriod.year:
        return AnalyticsRange(
          from: DateTime.utc(d.year),
          to: DateTime.utc(d.year, 12, 31),
          previousFrom: DateTime.utc(d.year - 1),
          previousTo: DateTime.utc(d.year - 1, 12, 31),
        );
      case AnalyticsPeriod.all:
        final first = firstDay == null || firstDay.isAfter(d) ? d : firstDay;
        return AnalyticsRange(
          from: DateTime.utc(first.year, first.month, first.day),
          to: d,
        );
    }
  }

  bool contains(DateTime day) => !day.isBefore(from) && !day.isAfter(to);

  bool containsPrevious(DateTime day) =>
      previousFrom != null &&
      !day.isBefore(previousFrom!) &&
      !day.isAfter(previousTo!);
}

String _two(int n) => n.toString().padLeft(2, '0');

/// `YYYY-MM-DD` of a calendar day held as a UTC DateTime.
String analyticsDateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

/// The clinic's wall clock for an instant, held in a UTC DateTime so the
/// calendar maths is plain.
DateTime _wall(int ms, Duration offset) =>
    DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).add(offset);

DateTime _dayOf(DateTime wall) => DateTime.utc(wall.year, wall.month, wall.day);

/// Adds figures up as tokens, sessions and patients arrive.
final class _Tally {
  int tokens = 0;
  int entered = 0;
  int skipped = 0;
  int cancelled = 0;
  int notSeen = 0;
  int fee = 0;
  int sessions = 0;
  int closedSessions = 0;
  int sessionMinutes = 0;
  int newPatients = 0;
  int waitSum = 0;
  int waitCount = 0;
  int longestWait = 0;
  final patients = <String>{};

  void addToken(AnalyticsToken t) {
    tokens++;
    patients.add(t.patientId);
    switch (t.status) {
      case 'ENTERED':
        entered++;
      case 'SKIPPED':
        skipped++;
      case 'CANCELLED':
        cancelled++;
      default:
        notSeen++;
    }
    if (!t.cancelled) fee += t.feeBdt ?? 0;
    final wait = t.waitSeconds;
    if (wait != null) {
      waitSum += wait;
      waitCount++;
      if (wait > longestWait) longestWait = wait;
    }
  }

  void addSession(AnalyticsSession s) {
    sessions++;
    if (s.closedAtMs != null && s.closedAtMs! >= s.openedAtMs) {
      closedSessions++;
      sessionMinutes += ((s.closedAtMs! - s.openedAtMs) / 60000).round();
    }
  }

  AnalyticsTotals get totals => AnalyticsTotals(
    sessions: sessions,
    tokens: tokens,
    entered: entered,
    skipped: skipped,
    cancelled: cancelled,
    notSeen: notSeen,
    feeBdt: fee,
    newPatients: newPatients,
    patients: patients.length,
    averageWaitSeconds: waitCount == 0 ? null : (waitSum / waitCount).round(),
    longestWaitSeconds: waitCount == 0 ? null : longestWait,
    averageSessionMinutes: closedSessions == 0
        ? null
        : (sessionMinutes / closedSessions).round(),
  );
}

/// Works out every figure of one analytics period from the raw rows.
///
/// [tokens], [sessions] and [patientCreatedMs] may reach beyond the period (the
/// previous period is read from the same rows); anything outside it and the
/// period before it is ignored. [offset] is how far the clinic clock is ahead
/// of UTC, and [day] is today (or the chosen day) on that clock.
AnalyticsResult computeAnalytics({
  required AnalyticsPeriod period,
  required DateTime day,
  required Duration offset,
  required String timeZone,
  required List<AnalyticsToken> tokens,
  required List<AnalyticsSession> sessions,
  required List<int> patientCreatedMs,
  Map<String, ({String english, String bengali})> queueNames = const {},
  Map<String, String> chamberNames = const {},
}) {
  // "All time" starts on the first day anything was recorded.
  DateTime? firstDay;
  if (period == AnalyticsPeriod.all) {
    final days = [
      for (final t in tokens) _dayOf(_wall(t.issuedAtMs, offset)),
      for (final s in sessions) _dayOf(_wall(s.openedAtMs, offset)),
      for (final ms in patientCreatedMs) _dayOf(_wall(ms, offset)),
    ];
    if (days.isNotEmpty) {
      firstDay = days.reduce((a, b) => a.isBefore(b) ? a : b);
    }
  }
  final range = AnalyticsRange.of(period, day, firstDay: firstDay);

  String bucketKey(DateTime wall) => switch (period) {
    AnalyticsPeriod.day =>
      '${analyticsDateKey(_dayOf(wall))}T${_two(wall.hour)}',
    AnalyticsPeriod.week ||
    AnalyticsPeriod.month => analyticsDateKey(_dayOf(wall)),
    AnalyticsPeriod.year =>
      '${wall.year.toString().padLeft(4, '0')}-${_two(wall.month)}',
    AnalyticsPeriod.all => wall.year.toString().padLeft(4, '0'),
  };

  // Every point exists, empty or not, so a quiet day still shows as zero.
  final keys = <String>[];
  switch (period) {
    case AnalyticsPeriod.day:
      for (var h = 0; h < 24; h++) {
        keys.add('${analyticsDateKey(range.from)}T${_two(h)}');
      }
    case AnalyticsPeriod.week || AnalyticsPeriod.month:
      for (
        var d = range.from;
        !d.isAfter(range.to);
        d = d.add(const Duration(days: 1))
      ) {
        keys.add(analyticsDateKey(d));
      }
    case AnalyticsPeriod.year:
      for (var m = 1; m <= 12; m++) {
        keys.add('${range.from.year.toString().padLeft(4, '0')}-${_two(m)}');
      }
    case AnalyticsPeriod.all:
      for (var y = range.from.year; y <= range.to.year; y++) {
        keys.add(y.toString().padLeft(4, '0'));
      }
  }
  final points = {for (final k in keys) k: _Tally()};
  final whole = _Tally();
  final before = _Tally();
  final perQueue = <String, _Tally>{};
  final perChamber = <String, _Tally>{};
  final hourTokens = List<int>.filled(24, 0);
  final hourFees = List<int>.filled(24, 0);
  final weekdayTokens = List<int>.filled(7, 0);
  final weekdayFees = List<int>.filled(7, 0);

  for (final token in tokens) {
    final wall = _wall(token.issuedAtMs, offset);
    final date = _dayOf(wall);
    if (range.contains(date)) {
      whole.addToken(token);
      points[bucketKey(wall)]?.addToken(token);
      (perQueue[token.queueTypeId] ??= _Tally()).addToken(token);
      (perChamber[token.chamberId] ??= _Tally()).addToken(token);
      hourTokens[wall.hour]++;
      weekdayTokens[wall.weekday - 1]++;
      if (!token.cancelled) {
        hourFees[wall.hour] += token.feeBdt ?? 0;
        weekdayFees[wall.weekday - 1] += token.feeBdt ?? 0;
      }
    } else if (range.containsPrevious(date)) {
      before.addToken(token);
    }
  }
  for (final session in sessions) {
    final wall = _wall(session.openedAtMs, offset);
    final date = _dayOf(wall);
    if (range.contains(date)) {
      whole.addSession(session);
      points[bucketKey(wall)]?.addSession(session);
      (perChamber[session.chamberId] ??= _Tally()).addSession(session);
    } else if (range.containsPrevious(date)) {
      before.addSession(session);
    }
  }
  for (final ms in patientCreatedMs) {
    final wall = _wall(ms, offset);
    final date = _dayOf(wall);
    if (range.contains(date)) {
      whole.newPatients++;
      points[bucketKey(wall)]?.newPatients++;
    } else if (range.containsPrevious(date)) {
      before.newPatients++;
    }
  }

  final byQueue = [
    for (final entry in perQueue.entries)
      AnalyticsQueueStat(
        queueTypeId: entry.key,
        englishName: queueNames[entry.key]?.english ?? entry.key,
        bengaliName: queueNames[entry.key]?.bengali ?? entry.key,
        totals: entry.value.totals,
      ),
  ]..sort((a, b) => b.totals.tokens.compareTo(a.totals.tokens));
  final byChamber = [
    for (final entry in perChamber.entries)
      AnalyticsChamberStat(
        chamberId: entry.key,
        name: chamberNames[entry.key] ?? entry.key,
        totals: entry.value.totals,
      ),
  ]..sort((a, b) => b.totals.tokens.compareTo(a.totals.tokens));

  return AnalyticsResult(
    period: period,
    timeZone: timeZone,
    fromDate: analyticsDateKey(range.from),
    toDate: analyticsDateKey(range.to),
    previousFromDate: range.previousFrom == null
        ? null
        : analyticsDateKey(range.previousFrom!),
    previousToDate: range.previousTo == null
        ? null
        : analyticsDateKey(range.previousTo!),
    totals: whole.totals,
    previous: range.previousFrom == null ? null : before.totals,
    series: [
      for (final key in keys)
        AnalyticsPoint(key: key, totals: points[key]!.totals),
    ],
    byQueue: byQueue,
    byChamber: byChamber,
    byHour: [
      for (var h = 0; h < 24; h++)
        AnalyticsSlot(tokens: hourTokens[h], feeBdt: hourFees[h]),
    ],
    byWeekday: [
      for (var d = 0; d < 7; d++)
        AnalyticsSlot(tokens: weekdayTokens[d], feeBdt: weekdayFees[d]),
    ],
  );
}
