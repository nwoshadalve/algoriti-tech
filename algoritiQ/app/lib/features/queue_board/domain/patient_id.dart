// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

/// Minimum/maximum length for a manually edited chamber patient ID prefix.
const chamberPatientIdPrefixMinLength = 3;
const chamberPatientIdPrefixMaxLength = 6;

/// Forms the permanent clinic patient id for a chamber registration.
String formatChamberPatientId(String prefix, int sequence) {
  return '$prefix$sequence';
}

/// Legacy clinic-wide id (`P-000042`).
String formatLegacyClinicPatientId(int patientNumber) {
  return 'P-${patientNumber.toString().padLeft(6, '0')}';
}

/// Display/search id from stored patient columns.
String clinicPatientIdFromRow({
  required int patientNumber,
  required String patientIdPrefix,
  required String clinicPatientId,
}) {
  if (clinicPatientId.isNotEmpty) return clinicPatientId;
  if (patientIdPrefix.isEmpty)
    return formatLegacyClinicPatientId(patientNumber);
  return formatChamberPatientId(patientIdPrefix, patientNumber);
}

/// Parses legacy `P-000042` / `42` queries into [patientNumber].
int? parseLegacyPatientNumberQuery(String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return null;
  final upper = trimmed.toUpperCase();
  if (!upper.startsWith('P-') && upper.contains(RegExp(r'[A-Z]'))) {
    return null;
  }
  final withoutPrefix = upper.startsWith('P-') ? upper.substring(2) : upper;
  return int.tryParse(withoutPrefix.replaceAll(RegExp(r'[^0-9]'), ''));
}

/// Digits-only prefix validation for admin edits (auto-assign uses three digits).
bool isValidChamberPatientIdPrefix(String prefix) {
  if (prefix.length < chamberPatientIdPrefixMinLength ||
      prefix.length > chamberPatientIdPrefixMaxLength) {
    return false;
  }
  return RegExp(r'^[0-9]+$').hasMatch(prefix);
}

/// @deprecated Use [formatLegacyClinicPatientId] or [formatChamberPatientId].
String formatClinicPatientId(int patientNumber) =>
    formatLegacyClinicPatientId(patientNumber);

/// @deprecated Use [parseLegacyPatientNumberQuery].
int? parsePatientNumberQuery(String query) =>
    parseLegacyPatientNumberQuery(query);
