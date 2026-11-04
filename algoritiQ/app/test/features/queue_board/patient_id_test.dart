// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/domain/patient_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should format chamber patient ids by concatenation', () {
    expect(formatChamberPatientId('776', 1), '7761');
    expect(formatChamberPatientId('776', 2), '7762');
    expect(formatChamberPatientId('776', 100), '776100');
    expect(formatChamberPatientId('776', 1001), '7761001');
    expect(formatChamberPatientId('6652', 1), '66521');
  });

  test('should validate editable prefixes', () {
    expect(isValidChamberPatientIdPrefix('776'), isTrue);
    expect(isValidChamberPatientIdPrefix('6652'), isTrue);
    expect(isValidChamberPatientIdPrefix('12'), isFalse);
    expect(isValidChamberPatientIdPrefix('776a'), isFalse);
  });
}
