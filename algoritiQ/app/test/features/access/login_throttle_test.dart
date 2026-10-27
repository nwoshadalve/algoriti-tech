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

  test('should make the fifth failure wait thirty seconds', () {
    fail('user:a', 5);

    expect(throttle.waitFor('user:a'), const Duration(seconds: 30));
  });

  test('should double the wait with each further failure', () {
    fail('user:a', 6);

    expect(throttle.waitFor('user:a'), const Duration(seconds: 60));
  });

  test('should never wait longer than fifteen minutes', () {
    fail('user:a', 40);

    expect(throttle.waitFor('user:a'), const Duration(minutes: 15));
  });

  test('should let the person try again after the wait', () {
    fail('user:a', 5);

    clock.advance(const Duration(seconds: 31));

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
