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
import '../domain/patient_id.dart';
import '../domain/phone_normalize.dart';
import '../domain/token_query.dart';

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

  Future<void> saveIdempotentResult(
    String commandId,
    Map<String, Object?> json,
  ) async {
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

  Future<int> _nextInternalPatientNumber() async {
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
  }

  /// Allocates the next patient id for [chamberId] (prefix + sequence transaction).
  Future<
    ({
      int patientNumber,
      String patientIdPrefix,
      int patientIdSequence,
      String clinicPatientId,
    })
  >
  allocatePatientIdForChamber(String chamberId) async {
    return _db.transaction(() async {
      final chamber = await (_db.select(
        _db.chambers,
      )..where((c) => c.id.equals(chamberId))).getSingleOrNull();
      if (chamber == null) {
        throw StateError('chamber_not_found');
      }
      final sequence = chamber.patientIdNextSequence;
      final prefix = chamber.patientIdPrefix;
      final clinicPatientId = formatChamberPatientId(prefix, sequence);
      final patientNumber = await _nextInternalPatientNumber();
      await (_db.update(_db.chambers)..where((c) => c.id.equals(chamberId)))
          .write(ChambersCompanion(patientIdNextSequence: Value(sequence + 1)));
      return (
        patientNumber: patientNumber,
        patientIdPrefix: prefix,
        patientIdSequence: sequence,
        clinicPatientId: clinicPatientId,
      );
    });
  }

  @Deprecated('Use allocatePatientIdForChamber')
  Future<int> allocatePatientNumber() async {
    return _db.transaction(() async {
      return _nextInternalPatientNumber();
    });
  }

  /// A page of the session table, with the total after all filters and the
  /// per-status counts (which ignore the status filter, so the chips can show
  /// what each would list).
  Future<TokenRows> querySessionTokens({
    required String sessionId,
    required TokenQuery query,
    required int nowMs,
    required Map<String, int> queueOrder,
  }) async {
    final t = _db.queueTokens;
    final p = _db.patients;
    final join = innerJoin(p, p.id.equalsExp(t.patientId));

    Expression<bool> where({required bool withStatus}) {
      var predicate = t.sessionId.equals(sessionId);
      final search = query.search.trim();
      if (search.isNotEmpty) predicate &= _tokenSearch(search);
      if (withStatus && query.status != null) {
        predicate &= t.status.equals(query.status!.apiValue);
      }
      if (query.queueTypeId != null) {
        predicate &= t.queueTypeId.equals(query.queueTypeId!);
      }
      if (query.notPrintedOnly) {
        predicate &=
            t.latestPrintStatus.isNull() |
            t.latestPrintStatus.isNotValue('SENT');
      }
      return predicate;
    }

    final rowsQuery = _db.select(t).join([join])
      ..where(where(withStatus: true))
      ..orderBy(_tokenOrder(query, nowMs, queueOrder))
      ..limit(query.limit, offset: query.offset);
    final rows = [for (final row in await rowsQuery.get()) row.readTable(t)];

    final totalCount = t.id.count();
    final totalQuery = _db.selectOnly(t).join([join])
      ..addColumns([totalCount])
      ..where(where(withStatus: true));
    final total = (await totalQuery.getSingle()).read(totalCount) ?? 0;

    final perStatus = t.id.count();
    final countsQuery = _db.selectOnly(t).join([join])
      ..addColumns([t.status, perStatus])
      ..where(where(withStatus: false))
      ..groupBy([t.status]);
    final counts = <TokenStatus, int>{};
    for (final row in await countsQuery.get()) {
      final status = TokenStatus.parse(row.read(t.status));
      if (status != null) counts[status] = row.read(perStatus) ?? 0;
    }
    return TokenRows(rows: rows, total: total, counts: counts);
  }

  /// Name, patient ID, serial or phone, as plain text (no wildcards).
  Expression<bool> _tokenSearch(String typed) {
    final p = _db.patients;
    final search = _asciiDigits(typed);
    final digits = RegExp(r'^[0-9]+$').hasMatch(search);
    var match =
        _likeContains(p.bengaliName, search) |
        _likeContains(p.englishName, search) |
        _likeStarts(p.clinicPatientId, search);
    if (digits) {
      final phone = normalizeClinicPhone(search);
      match |= _likeStarts(_db.queueTokens.serial.cast<String>(), search);
      // A short run of digits is a serial or an ID; as a phone prefix it would
      // match every number on the same operator.
      if (phone.isNotEmpty && search.length >= _minPhoneSearchDigits) {
        match |= _likeStarts(p.phoneNormalized, phone);
      }
    }
    return match;
  }

  static const _minPhoneSearchDigits = 5;

  /// Bengali digits (০-৯) typed on the Bengali keyboard, as 0-9.
  static String _asciiDigits(String text) => text.replaceAllMapped(
    RegExp('[০-৯]'),
    (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0x09E6 + 0x30),
  );

  List<OrderingTerm> _tokenOrder(
    TokenQuery query,
    int nowMs,
    Map<String, int> queueOrder,
  ) {
    final t = _db.queueTokens;
    final p = _db.patients;
    final mode = query.ascending ? OrderingMode.asc : OrderingMode.desc;
    OrderingTerm by(Expression<Object> e) =>
        OrderingTerm(expression: e, mode: mode);
    final terms = switch (query.sort) {
      TokenSort.issued => [by(t.issuedAt)],
      // Same length first, so 7769 sorts before 77610.
      TokenSort.id => [by(p.clinicPatientId.length), by(p.clinicPatientId)],
      TokenSort.name => [by(p.bengaliName)],
      TokenSort.serial => [by(t.serial)],
      TokenSort.queue => [
        by(
          t.queueTypeId.caseMatch<int>(
            when: {
              for (final e in queueOrder.entries)
                Constant<String>(e.key): Constant<int>(e.value),
            },
            orElse: const Constant<int>(1 << 20),
          ),
        ),
        by(t.serial),
      ],
      TokenSort.wait => [by(_waitMs(nowMs))],
      TokenSort.status => [
        by(
          t.status.caseMatch<int>(
            when: {
              for (final (i, s) in _statusOrder.indexed)
                Constant<String>(s.apiValue): Constant<int>(i),
            },
            orElse: const Constant<int>(99),
          ),
        ),
      ],
    };
    // The id last, so ties never move between pages.
    return [...terms, by(t.id)];
  }

  static const _statusOrder = [
    TokenStatus.waiting,
    TokenStatus.called,
    TokenStatus.skipped,
    TokenStatus.entered,
    TokenStatus.cancelled,
  ];

  /// Time waited: until the first call, entry or cancellation, otherwise
  /// until now.
  Expression<int> _waitMs(int nowMs) {
    final t = _db.queueTokens;
    final end = coalesce<int>([
      t.firstCalledAt,
      t.enteredAt,
      t.cancelledAt,
      Variable<int>(nowMs),
    ]);
    final wait = end - t.issuedAt;
    return const Constant<int>(0).iif(wait.isSmallerThanValue(0), wait);
  }

  static Expression<bool> _likeContains(
    Expression<String> column,
    String text,
  ) => column.like('%${_escapeLike(text)}%', escapeChar: r'\');

  static Expression<bool> _likeStarts(Expression<String> column, String text) =>
      column.like('${_escapeLike(text)}%', escapeChar: r'\');

  /// Makes `%`, `_` and `\` match themselves in a `LIKE` pattern.
  static String _escapeLike(String text) => text
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

  /// Suggestions for the desk search box: Bengali or English name (any part),
  /// phone (any leading digits), clinic patient id, or legacy `P-` number.
  /// Newest registrations first, at most [searchLimit].
  Future<List<PatientSummary>> searchPatients(String query) async {
    final trimmed = _asciiDigits(query.trim());
    if (trimmed.isEmpty) return [];
    final digitsOnly = RegExp(r'^[0-9]+$').hasMatch(trimmed);
    final legacyNumber = parseLegacyPatientNumberQuery(trimmed);
    final phone = normalizeClinicPhone(trimmed);
    final select = _db.select(_db.patients)
      ..where((p) {
        final byId = _likeStarts(p.clinicPatientId, trimmed);
        final byNumber = legacyNumber == null
            ? const Constant(false)
            : p.patientNumber.equals(legacyNumber);
        if (digitsOnly) {
          final byPhone = phone.isEmpty
              ? const Constant(false)
              : _likeStarts(p.phoneNormalized, phone);
          return byId | byNumber | byPhone;
        }
        return byId |
            byNumber |
            _likeContains(p.bengaliName, trimmed) |
            _likeContains(p.englishName, trimmed);
      })
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
      ..limit(searchLimit);
    return [for (final row in await select.get()) _patientSummary(row)];
  }

  static const searchLimit = 20;

  Future<PatientRow> updatePatient({
    required String id,
    required PatientInput input,
    required int nowMs,
  }) async {
    await (_db.update(_db.patients)..where((p) => p.id.equals(id))).write(
      PatientsCompanion(
        bengaliName: Value(input.bengaliName.trim()),
        englishName: Value(input.englishName?.trim()),
        phoneNormalized: Value(normalizeClinicPhone(input.phone)),
        gender: Value(input.gender?.apiValue),
        approximateAgeYears: Value(input.approximateAgeYears),
        approximateAgeRecordedAt: input.approximateAgeYears == null
            ? const Value(null)
            : Value(nowMs),
      ),
    );
    return (_db.select(
      _db.patients,
    )..where((p) => p.id.equals(id))).getSingle();
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
    required String clinicPatientId,
    required String patientIdPrefix,
    required int patientIdSequence,
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
            clinicPatientId: clinicPatientId,
            patientIdPrefix: Value(patientIdPrefix),
            patientIdSequence: Value(patientIdSequence),
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
                (t) =>
                    t.sessionId.equals(sessionId) & t.status.equals('CALLED'),
              )
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> previewNextSerial(String sessionId, String queueTypeId) async {
    final counter =
        await (_db.select(_db.sessionQueueCounters)..where(
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
          await (_db.select(_db.sessionQueueCounters)..where(
                (c) =>
                    c.sessionId.equals(sessionId) &
                    c.queueTypeId.equals(queueTypeId),
              ))
              .getSingle();
      final serial = counter.nextNumber;
      // A type id repeats per owner (clinic default and chamber override), so
      // the lookup must name the owner or it can match two rows.
      final owner = await _queueRepo.effectiveOwnerKey(chamberId);
      final typeRow =
          await (_db.select(_db.queueTypes)..where(
                (t) => t.id.equals(queueTypeId) & t.ownerKey.equals(owner),
              ))
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
          ..orderBy([(t) => OrderingTerm.desc(t.issuedAt)]))
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

  /// Waiting serials per queue type, ascending, for the TV waiting lists.
  Future<Map<String, List<int>>> waitingSerialsByQueueType(
    String sessionId,
  ) async {
    final rows =
        await (_db.select(_db.queueTokens)
              ..where(
                (t) =>
                    t.sessionId.equals(sessionId) &
                    t.status.equals(TokenStatus.waiting.apiValue),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.serial)]))
            .get();
    final map = <String, List<int>>{};
    for (final row in rows) {
      map.putIfAbsent(row.queueTypeId, () => []).add(row.serial);
    }
    return map;
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

  Future<QueueTokenRow?> tokenById(String id) async {
    return (_db.select(
      _db.queueTokens,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
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
    await (_db.update(_db.queueTokens)..where((t) => t.id.equals(tokenId)))
        .write(QueueTokensCompanion(latestPrintStatus: Value(status)));
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

  Future<T> inTransaction<T>(Future<T> Function() action) =>
      _db.transaction(action);

  Future<void> setPrintAttemptStatus(String attemptId, String status) async {
    await (_db.update(_db.tokenPrintAttempts)
          ..where((a) => a.id.equals(attemptId)))
        .write(TokenPrintAttemptsCompanion(status: Value(status)));
  }

  /// Marks print attempts still pending since before [cutoffMs] as failed, so
  /// a print that never reported back cannot lock the printer for good.
  Future<void> expireStalePrintAttempts(int cutoffMs) async {
    final stale =
        await (_db.select(_db.tokenPrintAttempts)..where(
              (a) =>
                  a.status.equals('PENDING') &
                  a.createdAt.isSmallerThanValue(cutoffMs),
            ))
            .get();
    await _db.transaction(() async {
      for (final attempt in stale) {
        await setPrintAttemptStatus(attempt.id, 'FAILED');
      }
      // A token left PENDING with no pending attempt (the app was closed
      // between the two writes) would otherwise block printing for good.
      await _db.customUpdate(
        'UPDATE queue_tokens SET latest_print_status = ? '
        'WHERE latest_print_status = ? AND id NOT IN '
        '(SELECT token_id FROM token_print_attempts WHERE status = ?)',
        variables: [
          Variable.withString('FAILED'),
          Variable.withString('PENDING'),
          Variable.withString('PENDING'),
        ],
        updates: {_db.queueTokens},
      );
    });
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

  Future<void> ensureClinicDefaults() =>
      _queueRepo.ensureClinicDefaultsSeeded();

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
      clinicPatientId: clinicPatientIdFromRow(
        patientNumber: row.patientNumber,
        patientIdPrefix: row.patientIdPrefix,
        clinicPatientId: row.clinicPatientId,
      ),
      bengaliName: row.bengaliName,
      englishName: row.englishName ?? '',
      phoneNormalized: row.phoneNormalized,
      gender: PatientGender.parse(row.gender),
      ageLabel: ageLabel,
    );
  }
}

/// One page of tokens straight from the database.
final class TokenRows {
  const TokenRows({
    required this.rows,
    required this.total,
    required this.counts,
  });

  final List<QueueTokenRow> rows;

  /// Matches after every filter, across all pages.
  final int total;

  /// Tokens per status for the search and queue filter, whatever the status
  /// filter is.
  final Map<TokenStatus, int> counts;
}
