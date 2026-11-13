// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../queue/data/drift_queue_repository.dart';
import '../../queue/domain/session_stop_time.dart';
import '../domain/analytics_calculator.dart';
import '../domain/analytics_models.dart';

/// Reads the clinic's queue history as the figures of the admin analytics page.
class AnalyticsService {
  AnalyticsService(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  /// [date] is a day in clinic time (`YYYY-MM-DD`) inside the period wanted;
  /// today when null. [chamberId] limits tokens and sessions to one chamber.
  Future<AnalyticsResult> read({
    required AnalyticsPeriod period,
    String? date,
    String? chamberId,
  }) async {
    final policy = await DriftQueueRepository(_db).loadClinicPolicy();
    final now = _clock().toUtc();
    final offset = clinicUtcOffset(policy.timeZone, now);
    final wallNow = now.add(offset);
    final today = DateTime.utc(wallNow.year, wallNow.month, wallNow.day);
    final parsed = date == null ? null : DateTime.tryParse(date);
    final day = parsed == null
        ? today
        : DateTime.utc(parsed.year, parsed.month, parsed.day);

    // Read from the start of the period before to the end of this one, so the
    // comparison needs no second trip. "All time" reads everything.
    final range = AnalyticsRange.of(
      period,
      period == AnalyticsPeriod.all ? today : day,
    );
    int? fromMs;
    int? toMs;
    if (period != AnalyticsPeriod.all) {
      final start = range.previousFrom ?? range.from;
      fromMs = start.millisecondsSinceEpoch - offset.inMilliseconds;
      toMs =
          range.to.add(const Duration(days: 1)).millisecondsSinceEpoch -
          offset.inMilliseconds;
    }

    final t = _db.queueTokens;
    final tokenRows =
        await (_db.select(t)..where((r) {
              Expression<bool> p = const Constant(true);
              if (fromMs != null) p &= r.issuedAt.isBiggerOrEqualValue(fromMs);
              if (toMs != null) p &= r.issuedAt.isSmallerThanValue(toMs);
              if (chamberId != null && chamberId.isNotEmpty) {
                p &= r.chamberId.equals(chamberId);
              }
              return p;
            }))
            .get();

    final s = _db.queueSessions;
    final sessionRows =
        await (_db.select(s)..where((r) {
              Expression<bool> p = const Constant(true);
              if (fromMs != null) p &= r.openedAt.isBiggerOrEqualValue(fromMs);
              if (toMs != null) p &= r.openedAt.isSmallerThanValue(toMs);
              if (chamberId != null && chamberId.isNotEmpty) {
                p &= r.chamberId.equals(chamberId);
              }
              return p;
            }))
            .get();

    final p = _db.patients;
    final created = p.createdAt;
    final patientRows =
        await (_db.selectOnly(p)
              ..addColumns([created])
              ..where(
                fromMs == null
                    ? const Constant(true)
                    : created.isBiggerOrEqualValue(fromMs) &
                          created.isSmallerThanValue(toMs!),
              ))
            .get();

    final queueNames = <String, ({String english, String bengali})>{};
    for (final row in await _db.select(_db.queueTypes).get()) {
      queueNames.putIfAbsent(
        row.id,
        () => (english: row.englishName, bengali: row.bengaliName),
      );
    }
    final chamberNames = {
      for (final row in await _db.select(_db.chambers).get()) row.id: row.name,
    };

    return computeAnalytics(
      period: period,
      day: day,
      offset: offset,
      timeZone: policy.timeZone,
      tokens: [
        for (final r in tokenRows)
          AnalyticsToken(
            issuedAtMs: r.issuedAt,
            firstCalledAtMs: r.firstCalledAt,
            status: r.status,
            queueTypeId: r.queueTypeId,
            patientId: r.patientId,
            chamberId: r.chamberId,
            feeBdt: r.feeBdt,
          ),
      ],
      sessions: [
        for (final r in sessionRows)
          AnalyticsSession(
            chamberId: r.chamberId,
            openedAtMs: r.openedAt,
            closedAtMs: r.closedAt,
          ),
      ],
      patientCreatedMs: [for (final r in patientRows) r.read(created)!],
      queueNames: queueNames,
      chamberNames: chamberNames,
    );
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
  ),
);
