// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../queue/data/drift_queue_repository.dart';
import '../../queue/domain/queue_models.dart';
import '../domain/board_models.dart';
import '../domain/phone_normalize.dart';

const _nextPatientNumberKey = 'patients.nextNumber';

/// SQLite reads and writes for patients and queue tokens on the board.
class DriftQueueBoardRepository {
  DriftQueueBoardRepository(this._db, this._queueRepo);

  final AppDatabase _db;
  final DriftQueueRepository _queueRepo;

  Future<String?> readIdempotentResult(String commandId) async {
    final row = await (_db.select(
      _db.idempotentCommands,
    )..where((c) => c.commandId.equals(commandId))).getSingleOrNull();
    return row?.resultJson;
  }

  Future<void> saveIdempotentResult(String commandId, Map<String, Object?> json) async {
    await _db
        .into(_db.idempotentCommands)
        .insertOnConflictUpdate(
          IdempotentCommandsCompanion.insert(
            commandId: commandId,
            resultJson: jsonEncode(json),
            createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
          ),
        );
  }

  Future<int> allocatePatientNumber() async {
    return _db.transaction(() async {
      final key = _nextPatientNumberKey;
      final row = await (_db.select(
        _db.appSettings,
      )..where((s) => s.key.equals(key))).getSingleOrNull();
      var next = row == null
          ? 1
          : (jsonDecode(row.value) as Map<String, dynamic>)['next'] as int? ?? 1;
      final maxRow =
          await (_db.select(_db.patients)
                ..orderBy([(p) => OrderingTerm.desc(p.patientNumber)])
                ..limit(1))
              .getSingleOrNull();
      if (maxRow != null && maxRow.patientNumber >= next) {
        next = maxRow.patientNumber + 1;
      }
      final assigned = next;
      await _db
          .into(_db.appSettings)
          .insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              key: key,
              value: jsonEncode({'next': assigned + 1}),
            ),
          );
      return assigned;
    });
  }

  Future<List<PatientSummary>> searchPatients(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    final byNumber = parsePatientNumberQuery(trimmed);
    if (byNumber != null) {
      final rows =
          await (_db.select(_db.patients)
                ..where((p) => p.patientNumber.equals(byNumber))
                ..limit(20))
              .get();
      return [for (final row in rows) _patientSummary(row)];
    }
    final phone = normalizeClinicPhone(trimmed);
    if (phone.isEmpty) return [];
    final rows =
        await (_db.select(_db.patients)
              ..where((p) => p.phoneNormalized.equals(phone))
              ..orderBy([(p) => OrderingTerm.asc(p.patientNumber)])
              ..limit(20))
            .get();
    return [for (final row in rows) _patientSummary(row)];
  }

  Future<List<PatientSummary>> patientsWithPhone(String phoneNormalized) async {
    final rows =
        await (_db.select(_db.patients)
              ..where((p) => p.phoneNormalized.equals(phoneNormalized))
              ..orderBy([(p) => OrderingTerm.asc(p.patientNumber)]))
            .get();
    return [for (final row in rows) _patientSummary(row)];
  }

  Future<PatientRow> insertPatient({
    required String id,
    required int patientNumber,
    required PatientInput input,
    required int createdAtMs,
  }) async {
    final phone = normalizeClinicPhone(input.phone);
    await _db
        .into(_db.patients)
        .insert(
          PatientsCompanion.insert(
            id: id,
            patientNumber: patientNumber,
            bengaliName: input.bengaliName.trim(),
            englishName: Value(input.englishName?.trim()),
            phoneNormalized: phone,
            gender: Value(input.gender?.apiValue),
            dateOfBirthMs: Value(input.dateOfBirthMs),
            birthYear: Value(input.birthYear),
            approximateAgeYears: Value(input.approximateAgeYears),
            approximateAgeRecordedAt: input.approximateAgeYears == null
                ? const Value.absent()
                : Value(createdAtMs),
            locality: Value(input.locality?.trim()),
            legacyFileNumber: Value(input.legacyFileNumber?.trim()),
            adminNote: Value(input.adminNote?.trim()),
            hasPaperFile: Value(input.hasPaperFile),
            createdAt: createdAtMs,
          ),
        );
    return (_db.select(
      _db.patients,
    )..where((p) => p.id.equals(id))).getSingle();
  }

  Future<PatientRow?> patientById(String id) async {
    return (_db.select(
      _db.patients,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<QueueTokenRow?> activeTokenForPatientInSession(
    String sessionId,
    String patientId,
  ) async {
    const active = ['WAITING', 'CALLED', 'SKIPPED'];
    final rows =
        await (_db.select(_db.queueTokens)
              ..where(
                (t) =>
                    t.sessionId.equals(sessionId) &
                    t.patientId.equals(patientId) &
                    t.status.isIn(active),
              )
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<QueueTokenRow?> calledTokenForSession(String sessionId) async {
    final rows =
        await (_db.select(_db.queueTokens)
              ..where(
                (t) => t.sessionId.equals(sessionId) & t.status.equals('CALLED'),
              )
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> previewNextSerial(String sessionId, String queueTypeId) async {
    final counter =
        await (_db.select(_db.sessionQueueCounters)
              ..where(
                (c) =>
                    c.sessionId.equals(sessionId) &
                    c.queueTypeId.equals(queueTypeId),
              ))
            .getSingleOrNull();
    return counter?.nextNumber ?? 0;
  }

  Future<({QueueTokenRow token, int serial})> issueToken({
    required String tokenId,
    required String sessionId,
    required String chamberId,
    required String patientId,
    required String queueTypeId,
    required int? feeBdt,
    required int issuedAtMs,
  }) async {
    return _db.transaction(() async {
      final counter =
          await (_db.select(_db.sessionQueueCounters)
                ..where(
                  (c) =>
                      c.sessionId.equals(sessionId) &
                      c.queueTypeId.equals(queueTypeId),
                ))
              .getSingle();
      final serial = counter.nextNumber;
      final typeRow =
          await (_db.select(_db.queueTypes)
                ..where((t) => t.id.equals(queueTypeId)))
              .getSingleOrNull();
      final end = typeRow?.endNumber ?? serial;
      if (serial > end) {
        throw StateError('exhausted');
      }
      await (_db.update(_db.sessionQueueCounters)..where(
            (c) =>
                c.sessionId.equals(sessionId) &
                c.queueTypeId.equals(queueTypeId),
          ))
          .write(
            SessionQueueCountersCompanion(
              nextNumber: Value(serial + 1),
              issuedCount: Value(counter.issuedCount + 1),
            ),
          );
      await _db
          .into(_db.queueTokens)
          .insert(
            QueueTokensCompanion.insert(
              id: tokenId,
              sessionId: sessionId,
              chamberId: chamberId,
              patientId: patientId,
              queueTypeId: queueTypeId,
              serial: serial,
              status: TokenStatus.waiting.apiValue,
              feeBdt: Value(feeBdt),
              issuedAt: issuedAtMs,
              latestPrintStatus: const Value('PENDING'),
            ),
          );
      final token = await (_db.select(
        _db.queueTokens,
      )..where((t) => t.id.equals(tokenId))).getSingle();
      return (token: token, serial: serial);
    });
  }

  Future<List<QueueTokenRow>> tokensForSession(String sessionId) async {
    return (_db.select(_db.queueTokens)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.issuedAt),
          ]))
        .get();
  }

  Future<int> waitingCount(String sessionId, String queueTypeId) async {
    final count = _db.queueTokens.id.count();
    final query = _db.selectOnly(_db.queueTokens)
      ..addColumns([count])
      ..where(
        _db.queueTokens.sessionId.equals(sessionId) &
            _db.queueTokens.queueTypeId.equals(queueTypeId) &
            _db.queueTokens.status.equals(TokenStatus.waiting.apiValue),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<QueueTokenRow?> latestCalledForQueueType(
    String sessionId,
    String queueTypeId,
  ) async {
    final rows =
        await (_db.select(_db.queueTokens)
              ..where(
                (t) =>
                    t.sessionId.equals(sessionId) &
                    t.queueTypeId.equals(queueTypeId) &
                    t.status.equals(TokenStatus.called.apiValue),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.firstCalledAt)])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<QueueTokenRow?> oldestWaiting(
    String sessionId,
    String queueTypeId,
  ) async {
    final rows =
        await (_db.select(_db.queueTokens)
              ..where(
                (t) =>
                    t.sessionId.equals(sessionId) &
                    t.queueTypeId.equals(queueTypeId) &
                    t.status.equals(TokenStatus.waiting.apiValue),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.issuedAt)])
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<QueueTokenRow> updateTokenStatus({
    required String tokenId,
    required String status,
    int? firstCalledAt,
    int? enteredAt,
    int? cancelledAt,
    String? cancelReason,
  }) async {
    await (_db.update(
      _db.queueTokens,
    )..where((t) => t.id.equals(tokenId))).write(
      QueueTokensCompanion(
        status: Value(status),
        firstCalledAt: firstCalledAt == null
            ? const Value.absent()
            : Value(firstCalledAt),
        enteredAt: enteredAt == null ? const Value.absent() : Value(enteredAt),
        cancelledAt: cancelledAt == null
            ? const Value.absent()
            : Value(cancelledAt),
        cancelReason: cancelReason == null
            ? const Value.absent()
            : Value(cancelReason),
      ),
    );
    return (_db.select(
      _db.queueTokens,
    )..where((t) => t.id.equals(tokenId))).getSingle();
  }

  Future<void> setLatestPrintStatus(String tokenId, String status) async {
    await (_db.update(
      _db.queueTokens,
    )..where((t) => t.id.equals(tokenId))).write(
      QueueTokensCompanion(latestPrintStatus: Value(status)),
    );
  }

  Future<TokenPrintAttemptRow> insertPrintAttempt({
    required String id,
    required String tokenId,
    required int attemptNumber,
    required String status,
    required String? reason,
    required String? actorId,
    required int createdAtMs,
  }) async {
    await _db
        .into(_db.tokenPrintAttempts)
        .insert(
          TokenPrintAttemptsCompanion.insert(
            id: id,
            tokenId: tokenId,
            attemptNumber: attemptNumber,
            status: status,
            reason: Value(reason),
            actorAccountId: Value(actorId),
            createdAt: createdAtMs,
          ),
        );
    return (_db.select(
      _db.tokenPrintAttempts,
    )..where((a) => a.id.equals(id))).getSingle();
  }

  Future<int> printAttemptCount(String tokenId) async {
    final count = _db.tokenPrintAttempts.id.count();
    final query = _db.selectOnly(_db.tokenPrintAttempts)
      ..addColumns([count])
      ..where(_db.tokenPrintAttempts.tokenId.equals(tokenId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<String?> pendingPrintTokenId() async {
    final rows =
        await (_db.select(_db.queueTokens)
              ..where((t) => t.latestPrintStatus.equals('PENDING'))
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first.id;
  }

  Future<void> ensureClinicDefaults() => _queueRepo.ensureClinicDefaultsSeeded();

  Future<QueueSessionRow?> openSessionForChamber(String chamberId) =>
      _queueRepo.openSessionForChamber(chamberId);

  Future<List<QueueTypeConfig>> typesForChamber(String chamberId) async {
    final owner = await _queueRepo.effectiveOwnerKey(chamberId);
    return _queueRepo.loadTypesForOwner(owner);
  }

  PatientSummary patientSummaryOf(PatientRow row) => _patientSummary(row);

  PatientSummary _patientSummary(PatientRow row) {
    String? ageLabel;
    if (row.dateOfBirthMs != null) {
      final dob = DateTime.fromMillisecondsSinceEpoch(
        row.dateOfBirthMs!,
        isUtc: true,
      );
      final now = DateTime.now().toUtc();
      var years = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        years--;
      }
      ageLabel = '$years';
    } else if (row.approximateAgeYears != null) {
      ageLabel = '~${row.approximateAgeYears}';
    } else if (row.birthYear != null) {
      ageLabel = '${DateTime.now().toUtc().year - row.birthYear!}';
    }
    return PatientSummary(
      id: row.id,
      patientNumber: row.patientNumber,
      clinicPatientId: formatClinicPatientId(row.patientNumber),
      bengaliName: row.bengaliName,
      englishName: row.englishName ?? '',
      phoneNormalized: row.phoneNormalized,
      gender: PatientGender.parse(row.gender),
      ageLabel: ageLabel,
    );
  }
}
