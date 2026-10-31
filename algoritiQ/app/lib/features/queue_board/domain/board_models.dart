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
    required this.bengaliName,
    required this.englishName,
    required this.phoneNormalized,
    this.gender,
    this.ageLabel,
  });

  final String id;
  final int patientNumber;
  final String clinicPatientId;
  final String bengaliName;
  final String englishName;
  final String phoneNormalized;
  final PatientGender? gender;
  final String? ageLabel;
}

final class PatientInput {
  const PatientInput({
    required this.bengaliName,
    required this.phone,
    this.englishName,
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

  final String bengaliName;
  final String phone;
  final String? englishName;
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

final class BoardTokenView {
  const BoardTokenView({
    required this.id,
    required this.serial,
    required this.queueTypeId,
    required this.queueEnglishName,
    required this.queueBengaliName,
    required this.patientId,
    required this.clinicPatientId,
    required this.patientBengaliName,
    required this.status,
    required this.issuedAt,
    this.firstCalledAt,
    this.enteredAt,
    this.feeBdt,
    this.latestPrintStatus,
  });

  final String id;
  final int serial;
  final String queueTypeId;
  final String queueEnglishName;
  final String queueBengaliName;
  final String patientId;
  final String clinicPatientId;
  final String patientBengaliName;
  final TokenStatus status;
  final DateTime issuedAt;
  final DateTime? firstCalledAt;
  final DateTime? enteredAt;
  final int? feeBdt;
  final String? latestPrintStatus;
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
    required this.calledToken,
    required this.queueControls,
    required this.tokens,
    required this.printerBusyTokenId,
  });

  final String chamberId;
  final String chamberName;
  final String? sessionId;
  final bool sessionOpen;
  final BoardTokenView? calledToken;
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
  });

  final PatientSummary patient;
  final String chamberName;
  final String queueTypeId;
  final String queueEnglishName;
  final String queueBengaliName;
  final int previewSerial;
  final int? feeBdt;
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
