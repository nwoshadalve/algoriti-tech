// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

/// Normalizes a Bangladesh clinic phone for search and storage.
String normalizeClinicPhone(String input) {
  final digits = StringBuffer();
  for (final unit in input.runes) {
    if (unit >= 0x30 && unit <= 0x39) {
      digits.writeCharCode(unit);
    }
  }
  var raw = digits.toString();
  if (raw.startsWith('880')) {
    raw = raw.substring(3);
  }
  if (raw.startsWith('0')) {
    raw = raw.substring(1);
  }
  return raw;
}

/// Parses a clinic patient id query (`P-1`, `p-000042`, `42`).
int? parsePatientNumberQuery(String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return null;
  final upper = trimmed.toUpperCase();
  final withoutPrefix = upper.startsWith('P-') ? upper.substring(2) : upper;
  final digits = int.tryParse(withoutPrefix.replaceAll(RegExp(r'[^0-9]'), ''));
  return digits;
}

String formatClinicPatientId(int patientNumber) {
  return 'P-${patientNumber.toString().padLeft(6, '0')}';
}
