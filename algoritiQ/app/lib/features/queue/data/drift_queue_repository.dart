// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/queue_models.dart';

const clinicOwnerKey = 'clinic';

const _policyKey = 'queue.policy.clinic';
const _chamberSettingsPrefix = 'queue.chamber.';

/// SQLite persistence for queue defaults, overrides, and sessions.
class DriftQueueRepository {
  DriftQueueRepository(this._db);

  final AppDatabase _db;

  static const seededTypes = [
    (
      id: 'regular',
      en: 'Regular',
      bn: 'সাধারণ',
      start: 1001,
      end: 1099,
      order: 1,
    ),
    (
      id: 'report',
      en: 'Report',
      bn: 'রিপোর্ট',
      start: 2001,
      end: 2099,
      order: 2,
    ),
    (
      id: 'dressing',
      en: 'Dressing',
      bn: 'ড্রেসিং',
      start: 3001,
      end: 3099,
      order: 3,
    ),
  ];

  Future<void> ensureClinicDefaultsSeeded() async {
    for (final seed in seededTypes) {
      final existing = await (_db.select(_db.queueTypes)
            ..where(
              (t) =>
                  t.id.equals(seed.id) & t.ownerKey.equals(clinicOwnerKey),
            ))
          .getSingleOrNull();
      if (existing != null) continue;
      await _db.into(_db.queueTypes).insert(
            QueueTypesCompanion.insert(
              id: seed.id,
              ownerKey: clinicOwnerKey,
              englishName: seed.en,
              bengaliName: seed.bn,
              startNumber: seed.start,
              endNumber: seed.end,
              displayOrder: seed.order,
            ),
          );
    }
    await _ensureClinicPolicyRow();
  }

  Future<void> _ensureClinicPolicyRow() async {
    final policy = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(_policyKey))).getSingleOrNull();
    if (policy != null) return;
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _policyKey,
            value: jsonEncode({
              'timeZone': QueuePolicy.defaults.timeZone,
              'dayBoundary': QueuePolicy.defaults.dayBoundary,
              'autoStart': QueuePolicy.defaults.autoStart,
            }),
          ),
        );
  }

  Future<QueuePolicy> loadClinicPolicy() async {
    await ensureClinicDefaultsSeeded();
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(_policyKey))).getSingleOrNull();
    if (row == null) return QueuePolicy.defaults;
    return _policyFromSettingsJson(row.value);
  }

  QueuePolicy _policyFromSettingsJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return QueuePolicy.defaults;
      return QueuePolicy(
        timeZone:
            decoded['timeZone'] as String? ?? QueuePolicy.defaults.timeZone,
        dayBoundary: decoded['dayBoundary'] as String? ??
            QueuePolicy.defaults.dayBoundary,
        autoStart:
            _readStoredBool(decoded['autoStart']) ?? QueuePolicy.defaults.autoStart,
      );
    } on Object {
      return QueuePolicy.defaults;
    }
  }

  bool? _readStoredBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }

  Future<void> saveClinicPolicy(QueuePolicy policy) async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _policyKey,
            value: jsonEncode({
              'timeZone': policy.timeZone,
              'dayBoundary': policy.dayBoundary,
              'autoStart': policy.autoStart,
            }),
          ),
        );
  }

  Future<List<QueueTypeConfig>> loadTypesForOwner(String ownerKey) async {
    final rows =
        await (_db.select(_db.queueTypes)
              ..where((t) => t.ownerKey.equals(ownerKey))
              ..orderBy([(t) => OrderingTerm.asc(t.displayOrder)]))
            .get();
    return [for (final row in rows) _typeOf(row)];
  }

  Future<ChamberQueueSettings> loadChamberSettings(String chamberId) async {
    final key = '$_chamberSettingsPrefix$chamberId';
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    if (row == null) return ChamberQueueSettings.inherit;
    final map = jsonDecode(row.value) as Map<String, dynamic>;
    return ChamberQueueSettings(
      useClinicDefaults: map['useClinicDefaults'] as bool? ?? true,
      dayBoundaryOverride: map['dayBoundaryOverride'] as String?,
      autoStartOverride: map['autoStartOverride'] as bool?,
    );
  }

  Future<void> saveChamberSettings(
    String chamberId,
    ChamberQueueSettings settings,
  ) async {
    final key = '$_chamberSettingsPrefix$chamberId';
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: jsonEncode({
              'useClinicDefaults': settings.useClinicDefaults,
              'dayBoundaryOverride': settings.dayBoundaryOverride,
              'autoStartOverride': settings.autoStartOverride,
            }),
          ),
        );
  }

  Future<String> effectiveOwnerKey(String chamberId) async {
    final settings = await loadChamberSettings(chamberId);
    if (settings.useClinicDefaults) return clinicOwnerKey;
    return chamberId;
  }

  Future<bool> chamberExists(String chamberId) async {
    final row = await (_db.select(
      _db.chambers,
    )..where((c) => c.id.equals(chamberId))).getSingleOrNull();
    return row != null;
  }

  Future<void> upsertType({
    required String ownerKey,
    required QueueTypeConfig type,
  }) async {
    await _db
        .into(_db.queueTypes)
        .insertOnConflictUpdate(
          QueueTypesCompanion.insert(
            id: type.id,
            ownerKey: ownerKey,
            englishName: type.englishName,
            bengaliName: type.bengaliName,
            startNumber: type.startNumber,
            endNumber: type.endNumber,
            displayOrder: type.displayOrder,
            enabled: Value(type.enabled),
          ),
        );
  }

  Future<void> deleteType(String ownerKey, String typeId) async {
    await (_db.delete(_db.queueTypes)
          ..where(
            (t) => t.id.equals(typeId) & t.ownerKey.equals(ownerKey),
          ))
        .go();
  }

  Future<QueueSessionRow?> openSessionForChamber(String chamberId) async {
    final open = {QueueSessionStatus.open, QueueSessionStatus.rolloverDue};
    final rows =
        await (_db.select(_db.queueSessions)
              ..where(
                (s) =>
                    s.chamberId.equals(chamberId) &
                    s.status.isIn(open.map((e) => e.apiValue)),
              )
              ..orderBy([(s) => OrderingTerm.desc(s.openedAt)]))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<bool> hasOpenSessionForOwner(String ownerKey) async {
    final List<ChamberRow> chambers;
    if (ownerKey == clinicOwnerKey) {
      chambers = await _db.select(_db.chambers).get();
    } else {
      final row = await (_db.select(
        _db.chambers,
      )..where((c) => c.id.equals(ownerKey))).getSingleOrNull();
      if (row == null) return false;
      chambers = [row];
    }
    for (final chamber in chambers) {
      if (await openSessionForChamber(chamber.id) != null) return true;
    }
    return false;
  }

  Future<void> insertSession({
    required String id,
    required String chamberId,
    required String businessDate,
    required String status,
    required DateTime openedAt,
    required String? openedByAccountId,
    required Map<String, Object?> snapshot,
    required List<QueueTypeConfig> types,
  }) async {
    await _db.transaction(() async {
      await _db
          .into(_db.queueSessions)
          .insert(
            QueueSessionsCompanion.insert(
              id: id,
              chamberId: chamberId,
              businessDate: businessDate,
              status: status,
              openedAt: openedAt.toUtc().millisecondsSinceEpoch,
              openedByAccountId: Value(openedByAccountId),
              configSnapshotJson: jsonEncode(snapshot),
            ),
          );
      for (final type in types.where((t) => t.enabled)) {
        await _db
            .into(_db.sessionQueueCounters)
            .insert(
              SessionQueueCountersCompanion.insert(
                sessionId: id,
                queueTypeId: type.id,
                nextNumber: type.startNumber,
              ),
            );
      }
    });
  }

  Future<void> closeSession({
    required String sessionId,
    required DateTime closedAt,
    required String? closedByAccountId,
    String? reason,
  }) async {
    await (_db.update(
      _db.queueSessions,
    )..where((s) => s.id.equals(sessionId))).write(
      QueueSessionsCompanion(
        status: const Value('CLOSED'),
        closedAt: Value(closedAt.toUtc().millisecondsSinceEpoch),
        closedByAccountId: Value(closedByAccountId),
        closeReason: Value(reason),
      ),
    );
  }

  Future<QueueSessionRow?> sessionById(String sessionId) async {
    return (_db.select(
      _db.queueSessions,
    )..where((s) => s.id.equals(sessionId))).getSingleOrNull();
  }

  Future<List<SessionQueueCounterRow>> countersForSession(String sessionId) async {
    return (_db.select(
      _db.sessionQueueCounters,
    )..where((c) => c.sessionId.equals(sessionId))).get();
  }

  QueueTypeConfig _typeOf(QueueTypeRow row) => QueueTypeConfig(
    id: row.id,
    englishName: row.englishName,
    bengaliName: row.bengaliName,
    startNumber: row.startNumber,
    endNumber: row.endNumber,
    displayOrder: row.displayOrder,
    enabled: row.enabled,
  );
}
