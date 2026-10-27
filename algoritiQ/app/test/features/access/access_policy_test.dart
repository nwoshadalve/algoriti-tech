import 'package:algoritiq_app/features/access/domain/access_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CredentialProblem? check(String username, String password) =>
      AccessPolicy.check(username: username, password: password);

  test('should accept a plain username and a long password', () {
    expect(check('dr.khan', 'a-long-passphrase'), isNull);
  });

  test('should ignore case and spaces around the username', () {
    expect(AccessPolicy.normalizeUsername('  DR.Khan '), 'dr.khan');
  });

  for (final name in ['ab', 'has space', 'bad/char', 'x' * 33, '']) {
    test('should refuse the username "$name"', () {
      expect(
        check(name, 'a-long-passphrase'),
        CredentialProblem.usernameInvalid,
      );
    });
  }

  test('should refuse a password shorter than eight characters', () {
    expect(check('owner', 'short'), CredentialProblem.passwordTooShort);
  });

  test('should refuse a password longer than 128 characters', () {
    expect(check('owner', 'x' * 129), CredentialProblem.passwordTooLong);
  });

  test('should refuse a password that contains the username', () {
    expect(
      check('owner', 'my-OWNER-password'),
      CredentialProblem.passwordContainsUsername,
    );
  });
}
