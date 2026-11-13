// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

enum TokenStatus {
  waiting('WAITING'),
  called('CALLED'),
  entered('ENTERED'),
  skipped('SKIPPED'),
  cancelled('CANCELLED');

  const TokenStatus(this.apiValue);
  final String apiValue;

  static TokenStatus? parse(String? raw) {
    if (raw == null) return null;
    for (final value in TokenStatus.values) {
      if (value.apiValue == raw) return value;
    }
    return null;
  }
}

enum PrintAttemptStatus {
  pending('PENDING'),
  sent('SENT'),
  failed('FAILED'),
  unknown('UNKNOWN');

  const PrintAttemptStatus(this.apiValue);
  final String apiValue;
}

enum PatientGender {
  male('male'),
  female('female'),
  other('other'),
  notStated('not_stated');

  const PatientGender(this.apiValue);
  final String apiValue;

  static PatientGender? parse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final value in PatientGender.values) {
      if (value.apiValue == raw) return value;
    }
    return null;
  }
}

final class PatientSummary {
  const PatientSummary({
    required this.id,
    required this.patientNumber,
    required this.clinicPatientId,
    required this.name,
    required this.phoneNormalized,
    this.gender,
    this.ageLabel,
    this.hasPaperFile = false,
    this.registeredAt,
    this.visitCount = 0,
    this.lastVisitAt,
  });

  final String id;
  final int patientNumber;
  final String clinicPatientId;

  /// How many times the patient is on a queue session: every token record,
  /// whatever its status. Filled for the patient list; 0 where not asked for.
  final int visitCount;

  /// When the patient last took a token; null if never.
  final DateTime? lastVisitAt;

  /// The patient's one name, in whatever language it was written.
  final String name;
  final String phoneNormalized;
  final PatientGender? gender;
  final String? ageLabel;
  final bool hasPaperFile;
  final DateTime? registeredAt;
}

final class PatientInput {
  const PatientInput({
    required this.name,
    required this.phone,
    this.gender,
    this.dateOfBirthMs,
    this.birthYear,
    this.approximateAgeYears,
    this.locality,
    this.legacyFileNumber,
    this.adminNote,
    this.hasPaperFile = false,
    this.confirmDuplicatePhone = false,
  });

  final String name;
  final String phone;
  final PatientGender? gender;
  final int? dateOfBirthMs;
  final int? birthYear;
  final int? approximateAgeYears;
  final String? locality;
  final String? legacyFileNumber;
  final String? adminNote;
  final bool hasPaperFile;
  final bool confirmDuplicatePhone;
}

/// A change of the fee on a patient's token, made together with editing the
/// patient. [feeBdt] null clears the fee. A free visit ([isFree]) has no fee.
final class TokenFeeChange {
  const TokenFeeChange({
    required this.tokenId,
    this.feeBdt,
    this.isFree = false,
  });

  final String tokenId;
  final int? feeBdt;
  final bool isFree;
}

final class BoardTokenView {
  const BoardTokenView({
    required this.id,
    required this.serial,
    required this.queueTypeId,
    required this.queueEnglishName,
    required this.queueBengaliName,
    required this.patientId,
    required this.clinicPatientId,
    required this.patientName,
    required this.status,
    required this.issuedAt,
    this.firstCalledAt,
    this.enteredAt,
    this.cancelledAt,
    this.cancelReason,
    this.feeBdt,
    this.isFree = false,
    this.latestPrintStatus,
    this.announced = true,
  });

  final String id;
  final int serial;
  final String queueTypeId;
  final String queueEnglishName;
  final String queueBengaliName;
  final String patientId;
  final String clinicPatientId;
  final String patientName;
  final TokenStatus status;
  final DateTime issuedAt;
  final DateTime? firstCalledAt;
  final DateTime? enteredAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final int? feeBdt;

  /// The patient was seen without a fee ([feeBdt] is then null).
  final bool isFree;
  final String? latestPrintStatus;

  /// False for a token that is on the board as the next one (the queue moved
  /// on by itself) but whose call has not been announced yet.
  final bool announced;
}

/// One page of the session table: the tokens asked for, how many match in
/// all, and how many tokens each status has (for the filter chips).
final class TokenPage {
  const TokenPage({
    required this.items,
    required this.total,
    required this.counts,
  });

  static const empty = TokenPage(items: [], total: 0, counts: {});

  final List<BoardTokenView> items;
  final int total;
  final Map<TokenStatus, int> counts;
}

final class QueueTypeBoardControl {
  const QueueTypeBoardControl({
    required this.queueTypeId,
    required this.englishName,
    required this.bengaliName,
    required this.waitingCount,
    required this.nextSerial,
    required this.canCallNext,
    required this.canRecall,
  });

  final String queueTypeId;
  final String englishName;
  final String bengaliName;
  final int waitingCount;
  final int nextSerial;
  final bool canCallNext;
  final bool canRecall;
}

final class BoardSnapshot {
  const BoardSnapshot({
    required this.chamberId,
    required this.chamberName,
    required this.sessionId,
    required this.sessionOpen,
    required this.calledTokens,
    required this.queueControls,
    required this.tokens,
    required this.printerBusyTokenId,
  });

  final String chamberId;
  final String chamberName;
  final String? sessionId;
  final bool sessionOpen;

  /// The tokens being called now, one per queue at most, in queue order.
  final List<BoardTokenView> calledTokens;

  /// The token called most recently, or null when none is being called.
  BoardTokenView? get calledToken {
    BoardTokenView? latest;
    for (final token in calledTokens) {
      final at = token.firstCalledAt;
      if (latest == null ||
          (at != null &&
              (latest.firstCalledAt == null ||
                  at.isAfter(latest.firstCalledAt!)))) {
        latest = token;
      }
    }
    return latest;
  }

  final List<QueueTypeBoardControl> queueControls;
  final List<BoardTokenView> tokens;
  final String? printerBusyTokenId;
}

final class IssuePreview {
  const IssuePreview({
    required this.patient,
    required this.chamberName,
    required this.queueTypeId,
    required this.queueEnglishName,
    required this.queueBengaliName,
    required this.previewSerial,
    this.feeBdt,
    this.isFree = false,
  });

  final PatientSummary patient;
  final String chamberName;
  final String queueTypeId;
  final String queueEnglishName;
  final String queueBengaliName;
  final int previewSerial;
  final int? feeBdt;
  final bool isFree;
}

final class IssuedTokenResult {
  const IssuedTokenResult({
    required this.token,
    required this.printAttemptId,
    required this.printStatus,
  });

  final BoardTokenView token;
  final String printAttemptId;
  final String printStatus;
}
