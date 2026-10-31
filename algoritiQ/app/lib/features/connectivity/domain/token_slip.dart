// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
/// The queues a patient can join.
enum QueueType {
  regular('নিয়মিত'),
  report('রিপোর্ট'),
  dressing('ড্রেসিং');

  const QueueType(this.bengaliLabel);

  /// How it is printed. Slips are always in Bengali.
  final String bengaliLabel;
}

/// Everything printed on one patient token. Nothing else goes on the slip:
/// no product name, no patient name or phone.
final class TokenSlip {
  const TokenSlip({
    required this.chamberName,
    required this.doctorName,
    required this.queueType,
    required this.tokenNumber,
    required this.registrationId,
    required this.issuedAt,
  });

  final String chamberName;
  final String doctorName;
  final QueueType queueType;

  /// Counts from 1 per queue type per day.
  final int tokenNumber;

  /// The patient's registration ID, as it should read (e.g. `PT-26-00421`).
  final String registrationId;
  final DateTime issuedAt;

  /// `০১`, `১২`: Bengali digits, at least two.
  String get tokenText => bengaliDigits(tokenNumber.toString().padLeft(2, '0'));

  /// `৩০/১০/২৬ · ১২:১৪ PM`
  String get issuedText {
    String two(int n) => n.toString().padLeft(2, '0');
    final at = issuedAt;
    final hour12 = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final period = at.hour < 12 ? 'AM' : 'PM';
    return bengaliDigits(
      '${two(at.day)}/${two(at.month)}/${two(at.year % 100)}'
      ' · ${two(hour12)}:${two(at.minute)} $period',
    );
  }

  /// The registration ID with Bengali digits, letters unchanged.
  String get idText => bengaliDigits(registrationId);
}

/// Replaces `0-9` with `০-৯`; everything else stays.
String bengaliDigits(String input) {
  const digits = '০১২৩৪৫৬৭৮৯';
  final out = StringBuffer();
  for (final unit in input.runes) {
    final i = unit - 0x30;
    out.write(i >= 0 && i <= 9 ? digits[i] : String.fromCharCode(unit));
  }
  return out.toString();
}
