// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/domain/phone_normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should normalize Bangladesh phones for search', () {
    expect(normalizeClinicPhone('01712-345678'), '1712345678');
    expect(normalizeClinicPhone('+880 1712 345678'), '1712345678');
  });

  test('should parse clinic patient id queries', () {
    expect(parsePatientNumberQuery('P-000042'), 42);
    expect(parsePatientNumberQuery('42'), 42);
    expect(formatClinicPatientId(42), 'P-000042');
  });
}
