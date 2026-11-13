// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'board_models.dart';

/// One queue session (today's or an earlier one) with what happened in it.
final class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.chamberId,
    required this.chamberName,
    required this.businessDate,
    required this.status,
    required this.openedAt,
    required this.counts,
    this.openedByName,
    this.closedAt,
    this.closedByName,
    this.closeReason,
    this.firstCalledAt,
    this.lastCalledAt,
    this.totalFeeBdt = 0,
    this.freeCount = 0,
  });

  final String id;
  final String chamberId;
  final String chamberName;

  /// Local calendar day the session was opened for (`YYYY-MM-DD`).
  final String businessDate;

  /// The stored status: `OPEN`, `CLOSED`, `ROLLOVER_DUE`, ...
  final String status;
  final DateTime openedAt;
  final String? openedByName;
  final DateTime? closedAt;
  final String? closedByName;

  /// Why an admin ended it by force; null for a normal end.
  final String? closeReason;

  /// First and last time a patient was called in this session.
  final DateTime? firstCalledAt;
  final DateTime? lastCalledAt;

  /// Tokens per status. Tokens still waiting when the session ended stay
  /// `waiting`: they were never seen.
  final Map<TokenStatus, int> counts;

  /// Fees (BDT) of the session's tokens, cancelled ones left out.
  final int totalFeeBdt;

  /// Patients seen free in the session, cancelled tokens left out.
  final int freeCount;

  bool get isOpen => closedAt == null;

  int count(TokenStatus status) => counts[status] ?? 0;

  /// Every token issued in the session.
  int get issued => counts.values.fold(0, (a, b) => a + b);
}

/// Tokens of one queue in one session, by outcome.
final class SessionQueueStat {
  const SessionQueueStat({
    required this.queueTypeId,
    required this.englishName,
    required this.bengaliName,
    required this.counts,
    this.feeBdt = 0,
  });

  final String queueTypeId;
  final String englishName;
  final String bengaliName;
  final Map<TokenStatus, int> counts;

  /// Fees (BDT) of this queue's tokens, cancelled ones left out.
  final int feeBdt;

  int get issued => counts.values.fold(0, (a, b) => a + b);
}

final class SessionDetail {
  const SessionDetail({
    required this.summary,
    required this.queues,
    this.patientCount = 0,
    this.averageWaitSeconds,
    this.longestWaitSeconds,
  });

  final SessionSummary summary;
  final List<SessionQueueStat> queues;

  /// Different patients who had a token in the session.
  final int patientCount;

  /// Time from issuing a token to its first call, over the tokens that were
  /// called; null when none was.
  final int? averageWaitSeconds;
  final int? longestWaitSeconds;
}

final class SessionHistoryPage {
  const SessionHistoryPage({required this.items, required this.total});

  static const empty = SessionHistoryPage(items: [], total: 0);

  final List<SessionSummary> items;
  final int total;
}

/// Which sessions to list: newest first.
final class SessionHistoryQuery {
  const SessionHistoryQuery({
    this.chamberId,
    this.from,
    this.to,
    this.limit = 20,
    this.offset = 0,
  });

  /// One chamber, or every chamber the person may see.
  final String? chamberId;

  /// Sessions opened at or after [from] and before [to] (instants).
  final DateTime? from;
  final DateTime? to;
  final int limit;
  final int offset;
}
