// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

/// One fee the admin defined for the whole clinic: a short [code] the
/// receptionist picks when a patient joins a queue, and the [amountBdt] it
/// stands for. The visit stores the amount, never the code, so changing a
/// code later does not rewrite past visits.
final class FeeCode {
  const FeeCode({
    required this.id,
    required this.code,
    required this.amountBdt,
  });

  factory FeeCode.fromJson(Map<String, Object?> json) => FeeCode(
    id: json['id'] as String? ?? '',
    code: (json['code'] as String? ?? '').trim(),
    amountBdt: json['amountBdt'] is int ? json['amountBdt']! as int : 0,
  );

  final String id;
  final String code;
  final int amountBdt;

  Map<String, Object?> toJson() => {
    'id': id,
    'code': code,
    'amountBdt': amountBdt,
  };
}

enum FeeCodeProblem {
  /// The list is longer than [FeeCodes.maxCount].
  tooMany,
  codeRequired,
  codeTooLong,
  codeDuplicate,

  /// Not a whole number from 1 to [FeeCodes.maxAmountBdt].
  amountInvalid,
}

abstract final class FeeCodes {
  static const maxCount = 50;
  static const maxCodeLength = 16;
  static const maxAmountBdt = 9999999;

  /// The first problem in [codes], or null when the list can be saved. Codes
  /// are compared without regard to case, so `Reg` and `REG` clash.
  static FeeCodeProblem? validate(List<FeeCode> codes) {
    if (codes.length > maxCount) return FeeCodeProblem.tooMany;
    final seen = <String>{};
    for (final fee in codes) {
      final code = fee.code.trim();
      if (code.isEmpty) return FeeCodeProblem.codeRequired;
      if (code.length > maxCodeLength) return FeeCodeProblem.codeTooLong;
      if (!seen.add(code.toLowerCase())) return FeeCodeProblem.codeDuplicate;
      if (fee.amountBdt < 1 || fee.amountBdt > maxAmountBdt) {
        return FeeCodeProblem.amountInvalid;
      }
    }
    return null;
  }
}
