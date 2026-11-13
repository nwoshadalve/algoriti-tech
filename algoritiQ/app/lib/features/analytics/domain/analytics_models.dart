// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

/// How much time one analytics reading covers.
enum AnalyticsPeriod {
  /// One day, in hours.
  day,

  /// Monday to Sunday, in days.
  week,

  /// One calendar month, in days.
  month,

  /// One calendar year, in months.
  year,

  /// Everything the clinic has recorded, in years.
  all;

  static AnalyticsPeriod? parse(String? raw) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }

  /// What one point of the series stands for.
  String get granularity => switch (this) {
    day => 'hour',
    week || month => 'day',
    year => 'month',
    all => 'year',
  };
}

/// One token as analytics sees it: only what the figures need.
final class AnalyticsToken {
  const AnalyticsToken({
    required this.issuedAtMs,
    required this.status,
    required this.queueTypeId,
    required this.patientId,
    required this.chamberId,
    this.feeBdt,
    this.firstCalledAtMs,
  });

  final int issuedAtMs;
  final int? firstCalledAtMs;

  /// `WAITING`, `CALLED`, `ENTERED`, `SKIPPED` or `CANCELLED`.
  final String status;
  final String queueTypeId;
  final String patientId;
  final String chamberId;
  final int? feeBdt;

  bool get cancelled => status == 'CANCELLED';

  /// Seconds from issuing to the first call; null if never called.
  int? get waitSeconds => firstCalledAtMs == null
      ? null
      : ((firstCalledAtMs! - issuedAtMs) / 1000).round().clamp(0, 1 << 31);
}

final class AnalyticsSession {
  const AnalyticsSession({
    required this.chamberId,
    required this.openedAtMs,
    this.closedAtMs,
  });

  final String chamberId;
  final int openedAtMs;
  final int? closedAtMs;
}

/// The figures of one stretch of time (a whole period, or one point of it).
final class AnalyticsTotals {
  const AnalyticsTotals({
    this.sessions = 0,
    this.tokens = 0,
    this.entered = 0,
    this.skipped = 0,
    this.cancelled = 0,
    this.notSeen = 0,
    this.feeBdt = 0,
    this.newPatients = 0,
    this.patients = 0,
    this.averageWaitSeconds,
    this.longestWaitSeconds,
    this.averageSessionMinutes,
  });

  final int sessions;
  final int tokens;

  /// Seen by the doctor.
  final int entered;

  /// Called but did not come in.
  final int skipped;
  final int cancelled;

  /// Still waiting, or called and never resolved, when the session ended.
  final int notSeen;

  /// Fees in BDT of every token that was not cancelled.
  final int feeBdt;

  /// Patients registered in the period.
  final int newPatients;

  /// Different patients who had a token.
  final int patients;
  final int? averageWaitSeconds;
  final int? longestWaitSeconds;
  final int? averageSessionMinutes;

  Map<String, Object?> toJson() => {
    'sessions': sessions,
    'tokens': tokens,
    'entered': entered,
    'skipped': skipped,
    'cancelled': cancelled,
    'notSeen': notSeen,
    'feeBdt': feeBdt,
    'newPatients': newPatients,
    'patients': patients,
    'averageWaitSeconds': averageWaitSeconds,
    'longestWaitSeconds': longestWaitSeconds,
    'averageSessionMinutes': averageSessionMinutes,
  };
}

/// One point of the series: an hour, a day, a month or a year.
final class AnalyticsPoint {
  const AnalyticsPoint({required this.key, required this.totals});

  /// `YYYY-MM-DDTHH`, `YYYY-MM-DD`, `YYYY-MM` or `YYYY`, in clinic time.
  final String key;
  final AnalyticsTotals totals;

  Map<String, Object?> toJson() => {'key': key, ...totals.toJson()};
}

final class AnalyticsQueueStat {
  const AnalyticsQueueStat({
    required this.queueTypeId,
    required this.englishName,
    required this.bengaliName,
    required this.totals,
  });

  final String queueTypeId;
  final String englishName;
  final String bengaliName;
  final AnalyticsTotals totals;

  Map<String, Object?> toJson() => {
    'queueTypeId': queueTypeId,
    'englishName': englishName,
    'bengaliName': bengaliName,
    ...totals.toJson(),
  };
}

final class AnalyticsChamberStat {
  const AnalyticsChamberStat({
    required this.chamberId,
    required this.name,
    required this.totals,
  });

  final String chamberId;
  final String name;
  final AnalyticsTotals totals;

  Map<String, Object?> toJson() => {
    'chamberId': chamberId,
    'name': name,
    ...totals.toJson(),
  };
}

/// Tokens and fees for one hour of the day, or one weekday.
final class AnalyticsSlot {
  const AnalyticsSlot({this.tokens = 0, this.feeBdt = 0});

  final int tokens;
  final int feeBdt;

  Map<String, Object?> toJson() => {'tokens': tokens, 'feeBdt': feeBdt};
}

/// Everything the analytics page shows for one period.
final class AnalyticsResult {
  const AnalyticsResult({
    required this.period,
    required this.timeZone,
    required this.fromDate,
    required this.toDate,
    required this.totals,
    required this.series,
    required this.byQueue,
    required this.byChamber,
    required this.byHour,
    required this.byWeekday,
    this.previousFromDate,
    this.previousToDate,
    this.previous,
  });

  final AnalyticsPeriod period;
  final String timeZone;

  /// First and last day of the period, in clinic time (`YYYY-MM-DD`).
  final String fromDate;
  final String toDate;
  final String? previousFromDate;
  final String? previousToDate;
  final AnalyticsTotals totals;

  /// The same period one step back (the day before, the week before...);
  /// null for [AnalyticsPeriod.all].
  final AnalyticsTotals? previous;
  final List<AnalyticsPoint> series;
  final List<AnalyticsQueueStat> byQueue;
  final List<AnalyticsChamberStat> byChamber;

  /// 24 slots, hour 0 to 23 of the clinic's clock.
  final List<AnalyticsSlot> byHour;

  /// 7 slots, Monday first.
  final List<AnalyticsSlot> byWeekday;

  Map<String, Object?> toJson() => {
    'period': period.name,
    'granularity': period.granularity,
    'timeZone': timeZone,
    'fromDate': fromDate,
    'toDate': toDate,
    'previousFromDate': previousFromDate,
    'previousToDate': previousToDate,
    'totals': totals.toJson(),
    'previous': previous?.toJson(),
    'series': [for (final p in series) p.toJson()],
    'byQueue': [for (final q in byQueue) q.toJson()],
    'byChamber': [for (final c in byChamber) c.toJson()],
    'byHour': [for (final s in byHour) s.toJson()],
    'byWeekday': [for (final s in byWeekday) s.toJson()],
  };
}
