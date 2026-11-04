// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/presentation/queue_desk_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should read a number typed in English or Bengali digits', () {
    expect(queueDeskParseNumber('35'), 35);
    expect(queueDeskParseNumber(' ৩৫ '), 35);
    expect(queueDeskParseNumber('৫০০'), 500);
  });

  test('should give null for text that is not a number', () {
    expect(queueDeskParseNumber(''), isNull);
    expect(queueDeskParseNumber('abc'), isNull);
  });
}
