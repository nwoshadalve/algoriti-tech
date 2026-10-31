// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:math';

import 'package:algoritiq_app/features/access/application/claim_codes.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/access_kit.dart';

void main() {
  late TestClock clock;
  late ClaimCodes codes;

  setUp(() {
    clock = TestClock();
    codes = ClaimCodes(clock: clock.call, random: Random(1));
  });

  test('should show an eight character code, grouped for reading', () {
    final code = codes.current();

    expect(code.code, matches(RegExp(r'^[0-9A-HJKMNP-TV-Z]{8}$')));
    expect(
      code.display,
      '${code.code.substring(0, 4)}-${code.code.substring(4)}',
    );
  });

  test('should keep showing the same code until it changes', () {
    expect(codes.current().code, codes.current().code);
  });

  test('should accept the code however it is typed', () {
    final code = codes.current().code;

    expect(codes.check(code.toLowerCase()), ClaimCheck.ok);
    expect(
      codes.check('${code.substring(0, 4)} - ${code.substring(4)}'),
      ClaimCheck.ok,
    );
  });

  test('should refuse a wrong code and count the attempt', () {
    codes.current();

    expect(codes.check('WRONG123'), ClaimCheck.wrong);
    expect(codes.attemptsLeft, 4);
  });

  test(
    'should lock the code after five wrong attempts, even for the right one',
    () {
      final code = codes.current().code;
      for (var i = 0; i < 4; i++) {
        expect(codes.check('WRONG123'), ClaimCheck.wrong);
      }

      expect(codes.check('WRONG123'), ClaimCheck.locked);
      expect(codes.check(code), ClaimCheck.locked);
    },
  );

  test('should show a new code once the old one is locked', () {
    final first = codes.current().code;
    for (var i = 0; i < 5; i++) {
      codes.check('WRONG123');
    }

    expect(codes.current().code, isNot(first));
    expect(codes.attemptsLeft, 5);
  });

  test('should expire after fifteen minutes', () {
    final code = codes.current().code;

    clock.advance(const Duration(minutes: 15));

    expect(codes.check(code), ClaimCheck.expired);
    expect(codes.current().code, isNot(code));
  });

  test('should work only once', () {
    final code = codes.current().code;
    expect(codes.check(code), ClaimCheck.ok);

    codes.consume();

    expect(codes.check(code), ClaimCheck.expired);
  });

  test('should not use the code up when only checking it', () {
    final code = codes.current().code;

    expect(codes.check(code), ClaimCheck.ok);
    expect(codes.check(code), ClaimCheck.ok);
  });

  test('should replace the code on request', () {
    final first = codes.current().code;

    expect(codes.refresh().code, isNot(first));
    expect(codes.check(first), ClaimCheck.wrong);
  });
}
