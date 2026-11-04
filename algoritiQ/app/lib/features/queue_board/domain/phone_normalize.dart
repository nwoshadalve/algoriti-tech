// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

export 'patient_id.dart'
    show
        clinicPatientIdFromRow,
        formatChamberPatientId,
        formatClinicPatientId,
        formatLegacyClinicPatientId,
        parseLegacyPatientNumberQuery,
        parsePatientNumberQuery;

/// Normalizes a Bangladesh clinic phone for search and storage.
String normalizeClinicPhone(String input) {
  final digits = StringBuffer();
  for (final unit in input.runes) {
    if (unit >= 0x30 && unit <= 0x39) {
      digits.writeCharCode(unit);
    } else if (unit >= 0x09E6 && unit <= 0x09EF) {
      // Bengali digits ০-৯, typed on the Bengali keyboard.
      digits.writeCharCode(unit - 0x09E6 + 0x30);
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
