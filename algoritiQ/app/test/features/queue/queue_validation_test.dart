// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_test/flutter_test.dart';

import 'package:algoritiq_app/features/queue/domain/queue_models.dart';
import 'package:algoritiq_app/features/queue/domain/queue_validation.dart';

void main() {
  test('should reject overlapping enabled ranges', () {
    const regular = QueueTypeConfig(
      id: 'regular',
      englishName: 'Regular',
      bengaliName: 'সাধারণ',
      startNumber: 1001,
      endNumber: 1099,
      displayOrder: 1,
      enabled: true,
    );
    final problems = validateQueueType(
      englishName: 'Extra',
      bengaliName: 'অতিরিক্ত',
      startNumber: 1050,
      endNumber: 1100,
      siblings: [regular],
      editingId: null,
      hasOpenSession: false,
    );
    expect(problems.containsKey(QueueTypeProblem.rangeOverlap), isTrue);
  });
}
