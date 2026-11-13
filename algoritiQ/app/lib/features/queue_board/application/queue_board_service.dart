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
import '../domain/patient_id.dart';
import '../domain/patient_query.dart';
import '../domain/phone_normalize.dart';
import '../domain/session_history_models.dart';
import '../domain/token_query.dart';
import '../../tv_live/application/announcement_service.dart';
import '../../tv_live/application/tv_live_publisher.dart';

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

  /// Another chamber's session is open; [QueueBoardRefused.code] is its name.
  otherSessionOpen,
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
    TvLivePublisher tvLive = const NullTvLivePublisher(),
    AnnouncementPreparer announcer = const NullAnnouncementPreparer(),
  }) : _board = boardRepo,
       _queue = queueService,
       _clinic = clinic,
       _accounts = accounts,
       _clock = clock,
       _newId = newId,
       _tvLive = tvLive,
       _announcer = announcer;

  final DriftQueueBoardRepository _board;
  final QueueService _queue;
  final ClinicRepository _clinic;
  final AccountRepository _accounts;
  final Clock _clock;
  final IdGenerator _newId;
  final TvLivePublisher _tvLive;
  final AnnouncementPreparer _announcer;

  /// A print that has not reported back by then counts as failed, so it cannot
  /// lock the printer.
  static const printAttemptTimeout = Duration(seconds: 60);

  /// Admin or receptionist assigned to [chamberId] when it is set.
  Future<void> _requireDeskUser(Account account, [String? chamberId]) async {
    if (account.role == Role.admin) return;
    if (account.role == Role.receptionist) {
      final scopes = await _accounts.getUserScopes(account.id);
      if (scopes.isEmpty) {
        throw const QueueBoardRefused(QueueBoardProblem.forbidden);
      }
      if (chamberId != null && !scopes.contains(chamberId)) {
        throw const QueueBoardRefused(QueueBoardProblem.forbidden);
      }
      return;
    }
    throw const QueueBoardRefused(QueueBoardProblem.forbidden);
  }

  Future<void> _requireTokenDeskUser(Account account, String tokenId) async {
    final row = await _board.tokenById(tokenId);
    if (row == null) {
      throw const QueueBoardRefused(QueueBoardProblem.validation);
    }
    await _requireDeskUser(account, row.chamberId);
  }

  /// Token view and chamber for printing from the HTTP desk API.
  Future<({BoardTokenView view, String chamberId})> deskTokenContext(
    Account account,
    String tokenId,
  ) async {
    await _requireTokenDeskUser(account, tokenId);
    final row = await _board.tokenById(tokenId);
    if (row == null) {
      throw const QueueBoardRefused(QueueBoardProblem.validation);
    }
    final types = await _board.typesForChamber(row.chamberId);
    final view = await _tokenView(row, types);
    return (view: view, chamberId: row.chamberId);
  }

  Future<void> _audit(
    Account admin,
    String action,
    Map<String, Object?> meta,
  ) async {
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

  /// The board: queue controls, the called patient and, unless
  /// [includeTokens] is false, every token of the session. The desk reads its
  /// table through [searchSessionTokens] instead and skips the full list.
  Future<BoardSnapshot> loadBoard(
    Account account,
    String chamberId, {
    bool includeTokens = true,
  }) async {
    await _requireDeskUser(account, chamberId);
    final chamber = await _chamber(chamberId);
    if (chamber == null) {
      throw const QueueBoardRefused(QueueBoardProblem.chamberNotFound);
    }
    await _board.ensureClinicDefaults();
    await _board.expireStalePrintAttempts(
      _clock().toUtc().millisecondsSinceEpoch -
          printAttemptTimeout.inMilliseconds,
    );
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
        calledTokens: const [],
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
    return _snapshotForSession(chamber, session, types, includeTokens);
  }

  /// Clears print attempts that stayed pending too long (web desk without UI refresh).
  Future<void> expireStalePrintAttempts() async {
    await _board.expireStalePrintAttempts(
      _clock().toUtc().millisecondsSinceEpoch -
          printAttemptTimeout.inMilliseconds,
    );
  }

  Future<TokenPage> searchSessionTokens(
    Account account,
    String chamberId,
    TokenQuery query,
  ) async {
    await _requireDeskUser(account, chamberId);
    final session = await _board.openSessionForChamber(chamberId);
    if (session == null) return TokenPage.empty;
    final types = await _board.typesForChamber(chamberId);
    final found = await _board.querySessionTokens(
      sessionId: session.id,
      query: query,
      nowMs: _clock().toUtc().millisecondsSinceEpoch,
      queueOrder: {for (final t in types) t.id: t.displayOrder},
    );
    return TokenPage(
      items: [for (final row in found.rows) await _tokenView(row, types)],
      total: found.total,
      counts: found.counts,
    );
  }

  /// The chambers whose history [account] may read: null for an admin (all),
  /// else the ones the receptionist is assigned to (directly or through the
  /// doctor, on a chamber-license clinic).
  Future<Set<String>?> _historyChambers(Account account) async {
    if (account.role == Role.admin) return null;
    await _requireDeskUser(account);
    final scopes = (await _accounts.getUserScopes(account.id)).toSet();
    final chambers = await _clinic.watchChambers().first;
    return {
      for (final c in chambers)
        if (scopes.contains(c.id) || scopes.contains(c.doctorId)) c.id,
    };
  }

  /// The chambers [account] can look at in the session history.
  Future<List<({String id, String name})>> historyChambers(
    Account account,
  ) async {
    final allowed = await _historyChambers(account);
    final chambers = await _clinic.watchChambers().first;
    return [
      for (final c in chambers)
        if (allowed == null || allowed.contains(c.id)) (id: c.id, name: c.name),
    ];
  }

  /// Sessions, newest first, with what happened in each. A receptionist sees
  /// only their own chambers.
  Future<SessionHistoryPage> listSessions(
    Account account,
    SessionHistoryQuery query,
  ) async {
    var allowed = await _historyChambers(account);
    final wanted = query.chamberId;
    if (wanted != null && wanted.isNotEmpty) {
      if (allowed != null && !allowed.contains(wanted)) {
        throw const QueueBoardRefused(QueueBoardProblem.forbidden);
      }
      allowed = {wanted};
    }
    if (allowed != null && allowed.isEmpty) return SessionHistoryPage.empty;
    final found = await _board.sessionsPage(
      chamberIds: allowed,
      fromMs: query.from?.toUtc().millisecondsSinceEpoch,
      toMs: query.to?.toUtc().millisecondsSinceEpoch,
      limit: query.limit,
      offset: query.offset,
    );
    final ids = [for (final r in found.rows) r.id];
    final totals = await _board.sessionTotals(ids);
    final fees = await _board.sessionFees(ids);
    final free = await _board.sessionFreeCounts(ids);
    return SessionHistoryPage(
      items: [
        for (final row in found.rows)
          await _sessionSummary(
            row,
            totals[row.id],
            fees[row.id] ?? 0,
            free[row.id] ?? 0,
          ),
      ],
      total: found.total,
    );
  }

  /// One session with its tokens counted per queue.
  Future<SessionDetail> sessionDetail(Account account, String sessionId) async {
    final row = await _board.sessionById(sessionId);
    if (row == null) {
      throw const QueueBoardRefused(QueueBoardProblem.validation);
    }
    final allowed = await _historyChambers(account);
    if (allowed != null && !allowed.contains(row.chamberId)) {
      throw const QueueBoardRefused(QueueBoardProblem.forbidden);
    }
    final totals = await _board.sessionTotals([row.id]);
    final perQueue = await _board.queueTotals(row.id);
    final queueFees = await _board.queueFees(row.id);
    final fees = await _board.sessionFees([row.id]);
    final free = await _board.sessionFreeCounts([row.id]);
    final extra = await _board.sessionPeopleAndWaits(row.id);
    final types = await _board.typesForChamber(row.chamberId);
    final known = {for (final t in types) t.id: t};
    final ids = [
      ...[for (final t in types) t.id].where(perQueue.containsKey),
      ...perQueue.keys.where((id) => !known.containsKey(id)),
    ];
    return SessionDetail(
      summary: await _sessionSummary(
        row,
        totals[row.id],
        fees[row.id] ?? 0,
        free[row.id] ?? 0,
      ),
      patientCount: extra.patients,
      averageWaitSeconds: extra.averageWaitMs == null
          ? null
          : (extra.averageWaitMs! / 1000).round(),
      longestWaitSeconds: extra.longestWaitMs == null
          ? null
          : (extra.longestWaitMs! / 1000).round(),
      queues: [
        for (final id in ids)
          SessionQueueStat(
            queueTypeId: id,
            englishName: known[id]?.englishName ?? id,
            bengaliName: known[id]?.bengaliName ?? id,
            counts: perQueue[id]!,
            feeBdt: queueFees[id] ?? 0,
          ),
      ],
    );
  }

  /// A page of the tokens of any session, for the history detail.
  Future<TokenPage> searchHistoryTokens(
    Account account,
    String sessionId,
    TokenQuery query,
  ) async {
    final row = await _board.sessionById(sessionId);
    if (row == null) {
      throw const QueueBoardRefused(QueueBoardProblem.validation);
    }
    final allowed = await _historyChambers(account);
    if (allowed != null && !allowed.contains(row.chamberId)) {
      throw const QueueBoardRefused(QueueBoardProblem.forbidden);
    }
    final types = await _board.typesForChamber(row.chamberId);
    final found = await _board.querySessionTokens(
      sessionId: row.id,
      query: query,
      nowMs: _clock().toUtc().millisecondsSinceEpoch,
      queueOrder: {for (final t in types) t.id: t.displayOrder},
    );
    return TokenPage(
      items: [for (final r in found.rows) await _tokenView(r, types)],
      total: found.total,
      counts: found.counts,
    );
  }

  Future<SessionSummary> _sessionSummary(
    QueueSessionRow row,
    ({Map<TokenStatus, int> counts, int? firstCalledAt, int? lastCalledAt})?
    totals,
    int totalFeeBdt,
    int freeCount,
  ) async {
    DateTime? at(int? ms) => ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    Future<String?> nameOf(String? id) async {
      if (id == null) return null;
      return (await _accounts.findAccountById(id))?.account.displayName;
    }

    return SessionSummary(
      id: row.id,
      chamberId: row.chamberId,
      chamberName: (await _chamber(row.chamberId))?.name ?? '',
      businessDate: row.businessDate,
      status: row.status,
      openedAt: at(row.openedAt)!,
      openedByName: await nameOf(row.openedByAccountId),
      closedAt: at(row.closedAt),
      closedByName: await nameOf(row.closedByAccountId),
      closeReason: row.closeReason,
      firstCalledAt: at(totals?.firstCalledAt),
      lastCalledAt: at(totals?.lastCalledAt),
      counts: totals?.counts ?? const {},
      totalFeeBdt: totalFeeBdt,
      freeCount: freeCount,
    );
  }

  Future<BoardSnapshot> _snapshotForSession(
    Chamber chamber,
    QueueSessionRow session,
    List<QueueTypeConfig> types,
    bool includeTokens,
  ) async {
    // One call per queue; listed in the queues' order.
    final calledRows = await _board.calledTokensForSession(session.id);
    final calledViews = <BoardTokenView>[];
    final calling = <String>{};
    for (final type in types) {
      for (final row in calledRows) {
        if (row.queueTypeId != type.id) continue;
        calledViews.add(await _tokenView(row, types));
        calling.add(type.id);
      }
    }
    final tokens = <BoardTokenView>[];
    if (includeTokens) {
      for (final row in await _board.tokensForSession(session.id)) {
        tokens.add(await _tokenView(row, types));
      }
    }
    final controls = <QueueTypeBoardControl>[];
    for (final type in types) {
      final waiting = await _board.waitingCount(session.id, type.id);
      final next = await _board.previewNextSerial(session.id, type.id);
      controls.add(
        QueueTypeBoardControl(
          queueTypeId: type.id,
          englishName: type.englishName,
          bengaliName: type.bengaliName,
          waitingCount: waiting,
          nextSerial: next,
          // A queue speaks for one patient at a time; the others are free.
          canCallNext: !calling.contains(type.id) && waiting > 0,
          canRecall: calling.contains(type.id),
        ),
      );
    }
    return BoardSnapshot(
      chamberId: chamber.id,
      chamberName: chamber.name,
      sessionId: session.id,
      sessionOpen: true,
      calledTokens: calledViews,
      queueControls: controls,
      tokens: tokens,
      printerBusyTokenId: await _board.pendingPrintTokenId(),
    );
  }

  Future<void> startSession(Account admin, String chamberId) async {
    await _requireDeskUser(admin, chamberId);
    try {
      await _queue.startSession(admin, chamberId);
    } on QueueServiceRefused catch (refused) {
      if (refused.problem == QueueServiceProblem.otherChamberOpen) {
        throw QueueBoardRefused(
          QueueBoardProblem.otherSessionOpen,
          code: refused.code,
        );
      }
      rethrow;
    }
    await _tvLive.notifyQueueUpdated(chamberId);
  }

  /// Ends the open session. Patients still waiting stay in it, as history;
  /// a new session starts from empty queues.
  Future<void> endSession(Account admin, String chamberId) async {
    await _requireDeskUser(admin, chamberId);
    await _queue.closeSession(admin, chamberId);
    await _tvLive.notifyQueueUpdated(chamberId);
  }

  /// Ends the sessions that reached their automatic stop time and tells the
  /// waiting-room TV and the web desk. Safe to call as often as you like.
  Future<void> closeSessionsDueForAutoStop() async {
    for (final chamberId in await _queue.closeSessionsDueForAutoStop()) {
      await _tvLive.notifyQueueUpdated(chamberId);
    }
  }

  Future<List<PatientSummary>> searchPatients(
    Account admin,
    String query,
  ) async {
    await _requireDeskUser(admin);
    return _board.searchPatients(query);
  }

  Future<PatientSummary> registerPatient(
    Account admin,
    PatientInput input, {
    required String chamberId,
    required String commandId,
  }) async {
    await _requireDeskUser(admin, chamberId);
    if (commandId.trim().isEmpty) {
      throw const QueueBoardRefused(QueueBoardProblem.commandRequired);
    }
    final cached = await _board.readIdempotentResult(commandId);
    if (cached != null) {
      return _patientFromJson(
        Map<String, Object?>.from(jsonDecode(cached) as Map),
      );
    }
    if (input.name.trim().isEmpty || input.phone.trim().isEmpty) {
      throw const QueueBoardRefused(QueueBoardProblem.validation);
    }
    if (await _chamber(chamberId) == null) {
      throw const QueueBoardRefused(QueueBoardProblem.chamberNotFound);
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
    final allocated = await _board.allocatePatientIdForChamber(chamberId);
    final row = await _board.insertPatient(
      id: id,
      patientNumber: allocated.patientNumber,
      clinicPatientId: allocated.clinicPatientId,
      patientIdPrefix: allocated.patientIdPrefix,
      patientIdSequence: allocated.patientIdSequence,
      input: input,
      createdAtMs: now,
    );
    final summary = _board.patientSummaryOf(row);
    await _board.saveIdempotentResult(commandId, _patientToJson(summary));
    await _audit(admin, 'patient.created', {'patientId': id});
    return summary;
  }

  /// Saves a new patient and puts them in the session queue in one step, so a
  /// patient is never left saved without a token. Printing is separate and
  /// must never be a condition of this call.
  Future<IssuedTokenResult> registerAndIssue(
    Account admin,
    PatientInput input,
    String queueTypeId, {
    required String chamberId,
    required String commandId,
    int? feeBdt,
    bool isFree = false,
  }) async {
    await _requireDeskUser(admin, chamberId);
    if (commandId.trim().isEmpty) {
      throw const QueueBoardRefused(QueueBoardProblem.commandRequired);
    }
    final session = await _requireOpenSession(chamberId);
    final type = _typeById(
      await _board.typesForChamber(chamberId),
      queueTypeId,
    );
    if (await _board.previewNextSerial(session.id, type.id) > type.endNumber) {
      throw const QueueBoardRefused(QueueBoardProblem.rangeExhausted);
    }
    return _board.inTransaction(() async {
      final patient = await registerPatient(
        admin,
        input,
        chamberId: chamberId,
        commandId: commandId,
      );
      return issueToken(
        admin,
        chamberId,
        patient.id,
        queueTypeId,
        feeBdt: feeBdt,
        isFree: isFree,
        commandId: '$commandId:issue',
      );
    });
  }

  /// The patient list: searched, filtered and ordered by the database.
  Future<PatientPage> listPatients(Account account, PatientQuery query) async {
    await _requireDeskUser(account);
    final found = await _board.queryPatients(query);
    return PatientPage(
      items: found.rows,
      total: found.total,
      registeredTotal: found.registeredTotal,
    );
  }

  Future<PatientSummary> getPatient(Account admin, String patientId) async {
    await _requireDeskUser(admin);
    final row = await _board.patientById(patientId);
    if (row == null) {
      throw const QueueBoardRefused(QueueBoardProblem.validation);
    }
    return _board.patientSummaryOf(row);
  }

  /// The most a visit fee can be (BDT); anything above is a typing slip.
  static const maxFeeBdt = 1000000;

  /// Changes name, phone, age and gender; the clinic ID and the paper-file
  /// flag are never touched here. With [fee], the fee on the patient's token in
  /// the open session is changed in the same step (and nothing is saved when
  /// that cannot be done).
  Future<PatientSummary> updatePatient(
    Account admin,
    String patientId,
    PatientInput input, {
    TokenFeeChange? fee,
  }) async {
    await _requireDeskUser(admin);
    if (input.name.trim().isEmpty || input.phone.trim().isEmpty) {
      throw const QueueBoardRefused(QueueBoardProblem.validation);
    }
    if (await _board.patientById(patientId) == null) {
      throw const QueueBoardRefused(QueueBoardProblem.validation);
    }
    if (fee != null) await _requireFeeToken(admin, patientId, fee);
    return _board.inTransaction(() async {
      final row = await _board.updatePatient(
        id: patientId,
        input: input,
        nowMs: _clock().toUtc().millisecondsSinceEpoch,
      );
      await _audit(admin, 'patient.updated', {'patientId': patientId});
      if (fee != null) {
        // A free visit has no fee, whatever amount came with it.
        final amount = fee.isFree ? null : fee.feeBdt;
        await _board.setTokenFee(fee.tokenId, amount, isFree: fee.isFree);
        await _audit(admin, 'queue.token.fee.updated', {
          'tokenId': fee.tokenId,
          'feeBdt': amount,
          'isFree': fee.isFree,
        });
      }
      return _board.patientSummaryOf(row);
    });
  }

  /// The token whose fee changes must be this patient's, in a session that is
  /// still open, and the fee a sensible amount.
  Future<void> _requireFeeToken(
    Account admin,
    String patientId,
    TokenFeeChange fee,
  ) async {
    final token = await _board.tokenById(fee.tokenId);
    if (token == null || token.patientId != patientId) {
      throw const QueueBoardRefused(QueueBoardProblem.validation);
    }
    await _requireDeskUser(admin, token.chamberId);
    final open = await _board.openSessionForChamber(token.chamberId);
    if (open == null || open.id != token.sessionId) {
      throw const QueueBoardRefused(QueueBoardProblem.sessionClosed);
    }
    final amount = fee.isFree ? null : fee.feeBdt;
    if (amount != null && (amount < 0 || amount > maxFeeBdt)) {
      throw const QueueBoardRefused(QueueBoardProblem.validation);
    }
  }

  /// Records how a print attempt ended; the token itself is unaffected.
  Future<void> recordPrintResult(
    Account admin,
    String tokenId,
    String attemptId,
    PrintAttemptStatus status,
  ) async {
    await _requireTokenDeskUser(admin, tokenId);
    await _board.setPrintAttemptStatus(attemptId, status.apiValue);
    await _board.setLatestPrintStatus(tokenId, status.apiValue);
  }

  Future<String?> pendingPrintTokenId() => _board.pendingPrintTokenId();

  Future<IssuePreview> previewIssue(
    Account admin,
    String chamberId,
    String patientId,
    String queueTypeId, {
    int? feeBdt,
    bool isFree = false,
  }) async {
    await _requireDeskUser(admin, chamberId);
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
      feeBdt: isFree ? null : feeBdt,
      isFree: isFree,
    );
  }

  Future<IssuedTokenResult> issueToken(
    Account admin,
    String chamberId,
    String patientId,
    String queueTypeId, {
    int? feeBdt,
    bool isFree = false,
    required String commandId,
  }) async {
    await _requireDeskUser(admin, chamberId);
    if (commandId.trim().isEmpty) {
      throw const QueueBoardRefused(QueueBoardProblem.commandRequired);
    }
    final cached = await _board.readIdempotentResult(commandId);
    if (cached != null) {
      return _issuedFromJson(cached);
    }
    await previewIssue(
      admin,
      chamberId,
      patientId,
      queueTypeId,
      feeBdt: feeBdt,
      isFree: isFree,
    );
    final session = await _requireOpenSession(chamberId);
    final tokenId = _newId();
    final now = _clock().toUtc().millisecondsSinceEpoch;
    final issued = await _board.issueToken(
      tokenId: tokenId,
      sessionId: session.id,
      chamberId: chamberId,
      patientId: patientId,
      queueTypeId: queueTypeId,
      feeBdt: isFree ? null : feeBdt,
      isFree: isFree,
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
    await _tvLive.notifyQueueUpdated(chamberId);
    return result;
  }

  Future<BoardTokenView> callNext(
    Account admin,
    String chamberId,
    String queueTypeId,
  ) async {
    await _requireDeskUser(admin, chamberId);
    final session = await _requireOpenSession(chamberId);
    // Only this queue must be free: the other queues may be calling too.
    if (await _board.latestCalledForQueueType(session.id, queueTypeId) !=
        null) {
      throw const QueueBoardRefused(QueueBoardProblem.unresolvedCalledToken);
    }
    final view = await _callOldestWaiting(
      admin,
      chamberId,
      session.id,
      queueTypeId,
      announce: true,
    );
    if (view == null) {
      throw const QueueBoardRefused(QueueBoardProblem.noWaitingToken);
    }
    return view;
  }

  /// Calls the oldest waiting token of the queue and returns it, or returns
  /// null when nobody is waiting. With [announce] the call is spoken and
  /// flashed on the board at once; without it the token only appears on the
  /// board as the current one, and the receptionist announces it when ready.
  Future<BoardTokenView?> _callOldestWaiting(
    Account admin,
    String chamberId,
    String sessionId,
    String queueTypeId, {
    required bool announce,
  }) async {
    final next = await _board.oldestWaiting(sessionId, queueTypeId);
    if (next == null) return null;
    final now = _clock().toUtc().millisecondsSinceEpoch;
    final updated = await _board.updateTokenStatus(
      tokenId: next.id,
      status: TokenStatus.called.apiValue,
      firstCalledAt: next.firstCalledAt ?? now,
      announcedAt: announce ? now : null,
    );
    final types = await _board.typesForChamber(chamberId);
    await _audit(admin, 'queue.token.called', {
      'tokenId': next.id,
      'announced': announce,
    });
    final view = await _tokenView(updated, types);
    if (announce) {
      await _announceCall(chamberId, view);
    } else {
      await _tvLive.notifyQueueUpdated(chamberId);
    }
    return view;
  }

  /// A called patient was resolved (entered, missed or cancelled): the queue's
  /// next patient appears on the board as the current one, with no sound. The
  /// receptionist chooses when to announce it (Announce). Nothing happens when
  /// nobody waits. This never fails the action that was just done: the patient
  /// is already resolved.
  Future<void> _callNextAfterResolved(
    Account admin,
    QueueTokenRow resolved,
  ) async {
    try {
      final session = await _board.openSessionForChamber(resolved.chamberId);
      if (session == null || session.id != resolved.sessionId) return;
      // A queue calls one patient at a time: leave it if it is busy again.
      if (await _board.latestCalledForQueueType(
            session.id,
            resolved.queueTypeId,
          ) !=
          null) {
        return;
      }
      await _callOldestWaiting(
        admin,
        resolved.chamberId,
        session.id,
        resolved.queueTypeId,
        announce: false,
      );
    } on Object {
      // The next call can still be made by hand with Call.
    }
  }

  Future<void> recall(
    Account admin,
    String chamberId,
    String queueTypeId,
  ) async {
    await _requireDeskUser(admin, chamberId);
    final session = await _requireOpenSession(chamberId);
    final called = await _board.latestCalledForQueueType(
      session.id,
      queueTypeId,
    );
    if (called == null) {
      throw const QueueBoardRefused(QueueBoardProblem.noCalledToken);
    }
    // The first announcement of a token that came up by itself is worded as a
    // call; after that it is a reminder.
    final first = called.announcedAt == null;
    if (first) {
      await _board.markAnnounced(
        called.id,
        _clock().toUtc().millisecondsSinceEpoch,
      );
    }
    await _audit(admin, 'queue.token.recalled', {
      'tokenId': called.id,
      'first': first,
    });
    final types = await _board.typesForChamber(chamberId);
    final view = await _tokenView(
      first ? (await _board.tokenById(called.id))! : called,
      types,
    );
    await _announceCall(chamberId, view, recall: !first);
  }

  /// Tells the TV a token is called: the screen update and, when the tablet's
  /// voice could make it, the spoken call. Without a voice the call still goes
  /// out, silent. A [recall] is spoken as a reminder, not as a first call.
  Future<void> _announceCall(
    String chamberId,
    BoardTokenView view, {
    bool recall = false,
  }) async {
    final callId = _newId();
    final announcementUrl = await _announcer.prepare(
      callId: callId,
      serial: view.serial,
      queueTypeId: view.queueTypeId,
      queueLabelBn: view.queueBengaliName,
      recall: recall,
    );
    await _tvLive.notifyTokenCalled(
      chamberId: chamberId,
      tokenId: view.id,
      queueTypeId: view.queueTypeId,
      serial: view.serial,
      callId: callId,
      announcementUrl: announcementUrl,
    );
  }

  Future<BoardTokenView> markEntered(Account admin, String tokenId) async {
    await _requireTokenDeskUser(admin, tokenId);
    return _transition(admin, tokenId, TokenStatus.entered);
  }

  Future<BoardTokenView> markSkipped(Account admin, String tokenId) async {
    await _requireTokenDeskUser(admin, tokenId);
    return _transition(admin, tokenId, TokenStatus.skipped);
  }

  Future<BoardTokenView> cancelToken(
    Account admin,
    String tokenId,
    String reason,
  ) async {
    await _requireTokenDeskUser(admin, tokenId);
    final now = _clock().toUtc().millisecondsSinceEpoch;
    final wasCalled = (await _board.tokenById(tokenId))?.status == 'CALLED';
    final updated = await _board.updateTokenStatus(
      tokenId: tokenId,
      status: TokenStatus.cancelled.apiValue,
      cancelledAt: now,
      cancelReason: reason.trim().isEmpty ? 'CANCELLED' : reason.trim(),
    );
    final types = await _board.typesForChamber(updated.chamberId);
    await _audit(admin, 'queue.token.cancelled', {'tokenId': tokenId});
    final view = await _tokenView(updated, types);
    await _tvLive.notifyQueueUpdated(updated.chamberId);
    if (wasCalled) await _callNextAfterResolved(admin, updated);
    return view;
  }

  Future<String> reprint(Account admin, String tokenId, String reason) async {
    await _requireTokenDeskUser(admin, tokenId);
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
    final wasCalled = (await _board.tokenById(tokenId))?.status == 'CALLED';
    final updated = await _board.updateTokenStatus(
      tokenId: tokenId,
      status: status.apiValue,
      enteredAt: status == TokenStatus.entered ? now : null,
    );
    final types = await _board.typesForChamber(updated.chamberId);
    await _audit(admin, 'queue.token.${status.apiValue.toLowerCase()}', {
      'tokenId': tokenId,
    });
    final view = await _tokenView(updated, types);
    await _tvLive.notifyQueueUpdated(updated.chamberId);
    if (wasCalled) await _callNextAfterResolved(admin, updated);
    return view;
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
          : clinicPatientIdFromRow(
              patientNumber: patient.patientNumber,
              patientIdPrefix: patient.patientIdPrefix,
              clinicPatientId: patient.clinicPatientId,
            ),
      patientName: patient == null
          ? ''
          : (patient.name.trim().isNotEmpty
                ? patient.name
                : patient.bengaliName),
      status: TokenStatus.parse(row.status) ?? TokenStatus.waiting,
      issuedAt: DateTime.fromMillisecondsSinceEpoch(row.issuedAt, isUtc: true),
      firstCalledAt: row.firstCalledAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              row.firstCalledAt!,
              isUtc: true,
            ),
      enteredAt: row.enteredAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.enteredAt!, isUtc: true),
      cancelledAt: row.cancelledAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.cancelledAt!, isUtc: true),
      cancelReason: row.cancelReason,
      feeBdt: row.feeBdt,
      isFree: row.isFree,
      latestPrintStatus: row.latestPrintStatus,
      announced: row.announcedAt != null,
    );
  }

  Map<String, Object?> _patientToJson(PatientSummary p) => {
    'id': p.id,
    'patientNumber': p.patientNumber,
    'clinicPatientId': p.clinicPatientId,
    'name': p.name,
    'phoneNormalized': p.phoneNormalized,
    'ageLabel': p.ageLabel,
    'gender': p.gender?.apiValue,
    'hasPaperFile': p.hasPaperFile,
    'registeredAt': p.registeredAt?.toUtc().toIso8601String(),
  };

  PatientSummary _patientFromJson(Map<String, Object?> map) => PatientSummary(
    id: map['id']! as String,
    patientNumber: map['patientNumber']! as int,
    clinicPatientId: map['clinicPatientId']! as String,
    // A result saved before the single name has the Bengali name only.
    name: (map['name'] ?? map['bengaliName'])! as String,
    phoneNormalized: map['phoneNormalized']! as String,
    gender: PatientGender.parse(map['gender'] as String?),
    ageLabel: map['ageLabel'] as String?,
    hasPaperFile: map['hasPaperFile'] as bool? ?? false,
    registeredAt: DateTime.tryParse(map['registeredAt'] as String? ?? ''),
  );

  Map<String, Object?> _issuedToJson(IssuedTokenResult r) => {
    'token': _tokenToJson(r.token),
    'printAttemptId': r.printAttemptId,
    'printStatus': r.printStatus,
  };

  IssuedTokenResult _issuedFromJson(String raw) {
    final map = Map<String, Object?>.from(jsonDecode(raw) as Map);
    return IssuedTokenResult(
      token: _tokenFromJson(Map<String, Object?>.from(map['token']! as Map)),
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
    'patientName': t.patientName,
    'status': t.status.apiValue,
    'issuedAt': t.issuedAt.toIso8601String(),
    'firstCalledAt': t.firstCalledAt?.toIso8601String(),
    'enteredAt': t.enteredAt?.toIso8601String(),
    'feeBdt': t.feeBdt,
    'isFree': t.isFree,
    'latestPrintStatus': t.latestPrintStatus,
    'announced': t.announced,
  };

  BoardTokenView _tokenFromJson(Map<String, Object?> map) => BoardTokenView(
    id: map['id']! as String,
    serial: map['serial']! as int,
    queueTypeId: map['queueTypeId']! as String,
    queueEnglishName: map['queueEnglishName']! as String,
    queueBengaliName: map['queueBengaliName']! as String,
    patientId: map['patientId']! as String,
    clinicPatientId: map['clinicPatientId']! as String,
    patientName: (map['patientName'] ?? map['patientName'])! as String,
    status: TokenStatus.parse(map['status'] as String?) ?? TokenStatus.waiting,
    issuedAt: DateTime.parse(map['issuedAt']! as String),
    firstCalledAt: map['firstCalledAt'] == null
        ? null
        : DateTime.parse(map['firstCalledAt']! as String),
    enteredAt: map['enteredAt'] == null
        ? null
        : DateTime.parse(map['enteredAt']! as String),
    feeBdt: map['feeBdt'] as int?,
    isFree: map['isFree'] as bool? ?? false,
    latestPrintStatus: map['latestPrintStatus'] as String?,
    announced: map['announced'] as bool? ?? true,
  );
}
