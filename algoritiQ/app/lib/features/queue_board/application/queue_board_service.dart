// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/id_generator.dart';
import '../../access/domain/account.dart';
import '../../access/domain/account_repository.dart';
import '../../clinic/domain/chamber.dart';
import '../../clinic/domain/clinic_repository.dart';
import '../../queue/application/queue_service.dart';
import '../../queue/domain/queue_models.dart';
import '../data/drift_queue_board_repository.dart';
import '../domain/board_models.dart';
import '../domain/phone_normalize.dart';

enum QueueBoardProblem {
  forbidden,
  chamberNotFound,
  sessionClosed,
  validation,
  duplicatePhoneNeedsConfirm,
  patientHasActiveToken,
  rangeExhausted,
  noWaitingToken,
  noCalledToken,
  unresolvedCalledToken,
  commandRequired,
  printerBusy,
}

final class QueueBoardRefused implements Exception {
  const QueueBoardRefused(this.problem, {this.code});

  final QueueBoardProblem problem;
  final String? code;
}

/// Patient entry and queue operations for the web board ([patient-entry-and-queue-operations.md]).
class QueueBoardService {
  QueueBoardService({
    required DriftQueueBoardRepository boardRepo,
    required QueueService queueService,
    required ClinicRepository clinic,
    required AccountRepository accounts,
    required Clock clock,
    required IdGenerator newId,
  }) : _board = boardRepo,
       _queue = queueService,
       _clinic = clinic,
       _accounts = accounts,
       _clock = clock,
       _newId = newId;

  final DriftQueueBoardRepository _board;
  final QueueService _queue;
  final ClinicRepository _clinic;
  final AccountRepository _accounts;
  final Clock _clock;
  final IdGenerator _newId;

  Future<void> _requireAdmin(Account account) async {
    if (account.role != Role.admin) {
      throw const QueueBoardRefused(QueueBoardProblem.forbidden);
    }
  }

  Future<void> _audit(Account admin, String action, Map<String, Object?> meta) async {
    await _accounts.audit(
      at: _clock(),
      action: action,
      actorId: admin.id,
      detail: jsonEncode(meta),
    );
  }

  Future<Chamber?> _chamber(String chamberId) async {
    return _clinic.chamberById(chamberId);
  }

  Future<BoardSnapshot> loadBoard(Account admin, String chamberId) async {
    await _requireAdmin(admin);
    final chamber = await _chamber(chamberId);
    if (chamber == null) {
      throw const QueueBoardRefused(QueueBoardProblem.chamberNotFound);
    }
    await _board.ensureClinicDefaults();
    final session = await _board.openSessionForChamber(chamberId);
    final types = (await _board.typesForChamber(chamberId))
        .where((t) => t.enabled)
        .toList();
    if (session == null) {
      return BoardSnapshot(
        chamberId: chamberId,
        chamberName: chamber.name,
        sessionId: null,
        sessionOpen: false,
        calledToken: null,
        queueControls: [
          for (final type in types)
            QueueTypeBoardControl(
              queueTypeId: type.id,
              englishName: type.englishName,
              bengaliName: type.bengaliName,
              waitingCount: 0,
              nextSerial: type.startNumber,
              canCallNext: false,
              canRecall: false,
            ),
        ],
        tokens: const [],
        printerBusyTokenId: await _board.pendingPrintTokenId(),
      );
    }
    return _snapshotForSession(chamber, session, types);
  }

  Future<BoardSnapshot> _snapshotForSession(
    Chamber chamber,
    QueueSessionRow session,
    List<QueueTypeConfig> types,
  ) async {
    final called = await _board.calledTokenForSession(session.id);
    BoardTokenView? calledView;
    if (called != null) {
      calledView = await _tokenView(called, types);
    }
    final tokenRows = await _board.tokensForSession(session.id);
    final tokens = <BoardTokenView>[];
    for (final row in tokenRows) {
      tokens.add(await _tokenView(row, types));
    }
    final controls = <QueueTypeBoardControl>[];
    final blocked = called != null;
    for (final type in types) {
      final waiting = await _board.waitingCount(session.id, type.id);
      final next = await _board.previewNextSerial(session.id, type.id);
      final latestCalled = await _board.latestCalledForQueueType(
        session.id,
        type.id,
      );
      controls.add(
        QueueTypeBoardControl(
          queueTypeId: type.id,
          englishName: type.englishName,
          bengaliName: type.bengaliName,
          waitingCount: waiting,
          nextSerial: next,
          canCallNext: !blocked && waiting > 0,
          canRecall:
              latestCalled != null &&
              called != null &&
              called.id == latestCalled.id,
        ),
      );
    }
    return BoardSnapshot(
      chamberId: chamber.id,
      chamberName: chamber.name,
      sessionId: session.id,
      sessionOpen: true,
      calledToken: calledView,
      queueControls: controls,
      tokens: tokens,
      printerBusyTokenId: await _board.pendingPrintTokenId(),
    );
  }

  Future<void> startSession(Account admin, String chamberId) async {
    await _requireAdmin(admin);
    await _queue.startSession(admin, chamberId);
  }

  Future<List<PatientSummary>> searchPatients(Account admin, String query) async {
    await _requireAdmin(admin);
    return _board.searchPatients(query);
  }

  Future<PatientSummary> registerPatient(
    Account admin,
    PatientInput input, {
    required String commandId,
  }) async {
    await _requireAdmin(admin);
    if (commandId.trim().isEmpty) {
      throw const QueueBoardRefused(QueueBoardProblem.commandRequired);
    }
    final cached = await _board.readIdempotentResult(commandId);
    if (cached != null) {
      return _patientFromJson(
        Map<String, Object?>.from(jsonDecode(cached) as Map),
      );
    }
    if (input.bengaliName.trim().isEmpty || input.phone.trim().isEmpty) {
      throw const QueueBoardRefused(QueueBoardProblem.validation);
    }
    final phone = normalizeClinicPhone(input.phone);
    final existing = await _board.patientsWithPhone(phone);
    if (existing.isNotEmpty && !input.confirmDuplicatePhone) {
      throw const QueueBoardRefused(
        QueueBoardProblem.duplicatePhoneNeedsConfirm,
      );
    }
    final now = _clock().toUtc().millisecondsSinceEpoch;
    final id = _newId();
    final number = await _board.allocatePatientNumber();
    final row = await _board.insertPatient(
      id: id,
      patientNumber: number,
      input: input,
      createdAtMs: now,
    );
    final summary = _board.patientSummaryOf(row);
    await _board.saveIdempotentResult(commandId, _patientToJson(summary));
    await _audit(admin, 'patient.created', {'patientId': id});
    return summary;
  }

  Future<IssuePreview> previewIssue(
    Account admin,
    String chamberId,
    String patientId,
    String queueTypeId, {
    int? feeBdt,
  }) async {
    await _requireAdmin(admin);
    final session = await _requireOpenSession(chamberId);
    final patient = await _board.patientById(patientId);
    if (patient == null) {
      throw const QueueBoardRefused(QueueBoardProblem.validation);
    }
    final types = await _board.typesForChamber(chamberId);
    final type = _typeById(types, queueTypeId);
    final active = await _board.activeTokenForPatientInSession(
      session.id,
      patientId,
    );
    if (active != null) {
      throw const QueueBoardRefused(QueueBoardProblem.patientHasActiveToken);
    }
    final previewSerial = await _board.previewNextSerial(session.id, type.id);
    if (previewSerial > type.endNumber) {
      throw const QueueBoardRefused(QueueBoardProblem.rangeExhausted);
    }
    final chamber = await _chamber(chamberId);
    return IssuePreview(
      patient: _board.patientSummaryOf(patient),
      chamberName: chamber?.name ?? '',
      queueTypeId: type.id,
      queueEnglishName: type.englishName,
      queueBengaliName: type.bengaliName,
      previewSerial: previewSerial,
      feeBdt: feeBdt,
    );
  }

  Future<IssuedTokenResult> issueToken(
    Account admin,
    String chamberId,
    String patientId,
    String queueTypeId, {
    int? feeBdt,
    required String commandId,
  }) async {
    await _requireAdmin(admin);
    if (commandId.trim().isEmpty) {
      throw const QueueBoardRefused(QueueBoardProblem.commandRequired);
    }
    final cached = await _board.readIdempotentResult(commandId);
    if (cached != null) {
      return _issuedFromJson(cached);
    }
    await previewIssue(admin, chamberId, patientId, queueTypeId, feeBdt: feeBdt);
    final session = await _requireOpenSession(chamberId);
    final tokenId = _newId();
    final now = _clock().toUtc().millisecondsSinceEpoch;
    final issued = await _board.issueToken(
      tokenId: tokenId,
      sessionId: session.id,
      chamberId: chamberId,
      patientId: patientId,
      queueTypeId: queueTypeId,
      feeBdt: feeBdt,
      issuedAtMs: now,
    );
    final attemptId = _newId();
    await _board.insertPrintAttempt(
      id: attemptId,
      tokenId: tokenId,
      attemptNumber: 1,
      status: PrintAttemptStatus.pending.apiValue,
      reason: null,
      actorId: admin.id,
      createdAtMs: now,
    );
    final types = await _board.typesForChamber(chamberId);
    final view = await _tokenView(issued.token, types);
    final result = IssuedTokenResult(
      token: view,
      printAttemptId: attemptId,
      printStatus: PrintAttemptStatus.pending.apiValue,
    );
    await _board.saveIdempotentResult(commandId, _issuedToJson(result));
    await _audit(admin, 'queue.token.issued', {
      'tokenId': tokenId,
      'chamberId': chamberId,
      'serial': issued.serial,
    });
    return result;
  }

  Future<BoardTokenView> callNext(
    Account admin,
    String chamberId,
    String queueTypeId,
  ) async {
    await _requireAdmin(admin);
    final session = await _requireOpenSession(chamberId);
    if (await _board.calledTokenForSession(session.id) != null) {
      throw const QueueBoardRefused(QueueBoardProblem.unresolvedCalledToken);
    }
    final next = await _board.oldestWaiting(session.id, queueTypeId);
    if (next == null) {
      throw const QueueBoardRefused(QueueBoardProblem.noWaitingToken);
    }
    final now = _clock().toUtc().millisecondsSinceEpoch;
    final updated = await _board.updateTokenStatus(
      tokenId: next.id,
      status: TokenStatus.called.apiValue,
      firstCalledAt: next.firstCalledAt ?? now,
    );
    final types = await _board.typesForChamber(chamberId);
    await _audit(admin, 'queue.token.called', {'tokenId': next.id});
    return _tokenView(updated, types);
  }

  Future<void> recall(Account admin, String chamberId, String queueTypeId) async {
    await _requireAdmin(admin);
    final session = await _requireOpenSession(chamberId);
    final called = await _board.latestCalledForQueueType(session.id, queueTypeId);
    if (called == null) {
      throw const QueueBoardRefused(QueueBoardProblem.noCalledToken);
    }
    await _audit(admin, 'queue.token.recalled', {'tokenId': called.id});
  }

  Future<BoardTokenView> markEntered(Account admin, String tokenId) async {
    await _requireAdmin(admin);
    return _transition(admin, tokenId, TokenStatus.entered);
  }

  Future<BoardTokenView> markSkipped(Account admin, String tokenId) async {
    await _requireAdmin(admin);
    return _transition(admin, tokenId, TokenStatus.skipped);
  }

  Future<BoardTokenView> cancelToken(
    Account admin,
    String tokenId,
    String reason,
  ) async {
    await _requireAdmin(admin);
    final now = _clock().toUtc().millisecondsSinceEpoch;
    final updated = await _board.updateTokenStatus(
      tokenId: tokenId,
      status: TokenStatus.cancelled.apiValue,
      cancelledAt: now,
      cancelReason: reason.trim().isEmpty ? 'CANCELLED' : reason.trim(),
    );
    final types = await _board.typesForChamber(updated.chamberId);
    await _audit(admin, 'queue.token.cancelled', {'tokenId': tokenId});
    return _tokenView(updated, types);
  }

  Future<String> reprint(Account admin, String tokenId, String reason) async {
    await _requireAdmin(admin);
    if (await _board.pendingPrintTokenId() != null) {
      throw const QueueBoardRefused(QueueBoardProblem.printerBusy);
    }
    final count = await _board.printAttemptCount(tokenId);
    final attemptId = _newId();
    final now = _clock().toUtc().millisecondsSinceEpoch;
    await _board.insertPrintAttempt(
      id: attemptId,
      tokenId: tokenId,
      attemptNumber: count + 1,
      status: PrintAttemptStatus.pending.apiValue,
      reason: reason.trim(),
      actorId: admin.id,
      createdAtMs: now,
    );
    await _board.setLatestPrintStatus(
      tokenId,
      PrintAttemptStatus.pending.apiValue,
    );
    await _audit(admin, 'queue.token.reprint', {'tokenId': tokenId});
    return attemptId;
  }

  Future<QueueSessionRow> _requireOpenSession(String chamberId) async {
    final session = await _board.openSessionForChamber(chamberId);
    if (session == null) {
      throw const QueueBoardRefused(QueueBoardProblem.sessionClosed);
    }
    return session;
  }

  QueueTypeConfig _typeById(List<QueueTypeConfig> types, String id) {
    for (final type in types) {
      if (type.id == id) return type;
    }
    throw const QueueBoardRefused(QueueBoardProblem.validation);
  }

  Future<BoardTokenView> _transition(
    Account admin,
    String tokenId,
    TokenStatus status,
  ) async {
    final now = _clock().toUtc().millisecondsSinceEpoch;
    final updated = await _board.updateTokenStatus(
      tokenId: tokenId,
      status: status.apiValue,
      enteredAt: status == TokenStatus.entered ? now : null,
    );
    final types = await _board.typesForChamber(updated.chamberId);
    await _audit(admin, 'queue.token.${status.apiValue.toLowerCase()}', {
      'tokenId': tokenId,
    });
    return _tokenView(updated, types);
  }

  Future<BoardTokenView> _tokenView(
    QueueTokenRow row,
    List<QueueTypeConfig> types,
  ) async {
    final patient = await _board.patientById(row.patientId);
    QueueTypeConfig? type;
    for (final candidate in types) {
      if (candidate.id == row.queueTypeId) {
        type = candidate;
        break;
      }
    }
    return BoardTokenView(
      id: row.id,
      serial: row.serial,
      queueTypeId: row.queueTypeId,
      queueEnglishName: type?.englishName ?? row.queueTypeId,
      queueBengaliName: type?.bengaliName ?? row.queueTypeId,
      patientId: row.patientId,
      clinicPatientId: patient == null
          ? ''
          : formatClinicPatientId(patient.patientNumber),
      patientBengaliName: patient?.bengaliName ?? '',
      status: TokenStatus.parse(row.status) ?? TokenStatus.waiting,
      issuedAt: DateTime.fromMillisecondsSinceEpoch(row.issuedAt, isUtc: true),
      firstCalledAt: row.firstCalledAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.firstCalledAt!, isUtc: true),
      enteredAt: row.enteredAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.enteredAt!, isUtc: true),
      feeBdt: row.feeBdt,
      latestPrintStatus: row.latestPrintStatus,
    );
  }

  Map<String, Object?> _patientToJson(PatientSummary p) => {
    'id': p.id,
    'patientNumber': p.patientNumber,
    'clinicPatientId': p.clinicPatientId,
    'bengaliName': p.bengaliName,
    'englishName': p.englishName,
    'phoneNormalized': p.phoneNormalized,
    'ageLabel': p.ageLabel,
    'gender': p.gender?.apiValue,
  };

  PatientSummary _patientFromJson(Map<String, Object?> map) => PatientSummary(
    id: map['id']! as String,
    patientNumber: map['patientNumber']! as int,
    clinicPatientId: map['clinicPatientId']! as String,
    bengaliName: map['bengaliName']! as String,
    englishName: map['englishName']! as String? ?? '',
    phoneNormalized: map['phoneNormalized']! as String,
    gender: PatientGender.parse(map['gender'] as String?),
    ageLabel: map['ageLabel'] as String?,
  );

  Map<String, Object?> _issuedToJson(IssuedTokenResult r) => {
    'token': _tokenToJson(r.token),
    'printAttemptId': r.printAttemptId,
    'printStatus': r.printStatus,
  };

  IssuedTokenResult _issuedFromJson(String raw) {
    final map = Map<String, Object?>.from(jsonDecode(raw) as Map);
    return IssuedTokenResult(
      token: _tokenFromJson(
        Map<String, Object?>.from(map['token']! as Map),
      ),
      printAttemptId: map['printAttemptId']! as String,
      printStatus: map['printStatus']! as String,
    );
  }

  Map<String, Object?> _tokenToJson(BoardTokenView t) => {
    'id': t.id,
    'serial': t.serial,
    'queueTypeId': t.queueTypeId,
    'queueEnglishName': t.queueEnglishName,
    'queueBengaliName': t.queueBengaliName,
    'patientId': t.patientId,
    'clinicPatientId': t.clinicPatientId,
    'patientBengaliName': t.patientBengaliName,
    'status': t.status.apiValue,
    'issuedAt': t.issuedAt.toIso8601String(),
    'firstCalledAt': t.firstCalledAt?.toIso8601String(),
    'enteredAt': t.enteredAt?.toIso8601String(),
    'feeBdt': t.feeBdt,
    'latestPrintStatus': t.latestPrintStatus,
  };

  BoardTokenView _tokenFromJson(Map<String, Object?> map) => BoardTokenView(
    id: map['id']! as String,
    serial: map['serial']! as int,
    queueTypeId: map['queueTypeId']! as String,
    queueEnglishName: map['queueEnglishName']! as String,
    queueBengaliName: map['queueBengaliName']! as String,
    patientId: map['patientId']! as String,
    clinicPatientId: map['clinicPatientId']! as String,
    patientBengaliName: map['patientBengaliName']! as String,
    status: TokenStatus.parse(map['status'] as String?) ?? TokenStatus.waiting,
    issuedAt: DateTime.parse(map['issuedAt']! as String),
    firstCalledAt: map['firstCalledAt'] == null
        ? null
        : DateTime.parse(map['firstCalledAt']! as String),
    enteredAt: map['enteredAt'] == null
        ? null
        : DateTime.parse(map['enteredAt']! as String),
    feeBdt: map['feeBdt'] as int?,
    latestPrintStatus: map['latestPrintStatus'] as String?,
  );
}
