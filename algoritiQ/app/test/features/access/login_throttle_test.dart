// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/access/application/login_throttle.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/access_kit.dart';

void main() {
  late TestClock clock;
  late LoginThrottle throttle;

  setUp(() {
    clock = TestClock();
    throttle = LoginThrottle(clock: clock.call);
  });

  void fail(String key, int times) {
    for (var i = 0; i < times; i++) {
      throttle.recordFailure(key);
    }
  }

  test('should allow a few mistakes without waiting', () {
    fail('user:a', 4);

    expect(throttle.waitFor('user:a'), isNull);
  });

  test('should make the sixth failure wait twenty seconds', () {
    fail('user:a', 5);

    expect(throttle.waitFor('user:a'), const Duration(seconds: 20));
  });

  test('should double the wait with each further failure', () {
    fail('user:a', 6);

    expect(throttle.waitFor('user:a'), const Duration(seconds: 40));

    fail('user:a', 1);
    expect(throttle.waitFor('user:a'), const Duration(seconds: 80));

    fail('user:a', 1);
    expect(throttle.waitFor('user:a'), const Duration(seconds: 160));
  });

  test('should cap further failures at one day', () {
    fail('user:a', 25);

    expect(throttle.waitFor('user:a'), const Duration(hours: 24));
  });

  test('should let the person try again after the wait', () {
    fail('user:a', 5);

    clock.advance(const Duration(seconds: 21));

    expect(throttle.waitFor('user:a'), isNull);
  });

  test('should not slow down other names', () {
    fail('user:a', 5);

    expect(throttle.waitFor('user:b'), isNull);
  });

  test('should forget the failures after a successful sign-in', () {
    fail('user:a', 4);
    throttle.recordSuccess('user:a');
    fail('user:a', 4);

    expect(throttle.waitFor('user:a'), isNull);
  });
}
