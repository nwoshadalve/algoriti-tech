// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/access/application/access_service.dart';
import 'package:algoritiq_app/features/access/domain/access_policy.dart';
import 'package:algoritiq_app/features/access/domain/account.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/access_kit.dart';

const _newPassword = 'a-better-passphrase';

void main() {
  late AccessKit kit;
  late Account owner;
  late String token;

  Future<String> signIn({String pass = AccessKit.password}) async {
    final result = await kit.service.login(
      username: 'owner',
      password: pass,
      clientKey: 'c',
    );
    return (result as LoggedIn).token;
  }

  setUp(() async {
    kit = await AccessKit.create();
    owner = ((await kit.registerAdmin()) as Registered).account;
    token = await signIn();
  });
  tearDown(() => kit.close());

  Future<ChangePasswordResult> change({
    String current = AccessKit.password,
    String next = _newPassword,
    String? withToken,
  }) => kit.service.changePassword(
    account: owner,
    token: withToken ?? token,
    currentPassword: current,
    newPassword: next,
  );

  test('should change the password and sign in with the new one', () async {
    final result = await change();

    expect(result, isA<PasswordChanged>());
    expect(await signIn(pass: _newPassword), isNotEmpty);
    final old = await kit.service.login(
      username: 'owner',
      password: AccessKit.password,
      clientKey: 'c',
    );
    expect(old, isA<InvalidCredentials>());
  });

  test('should keep this sign-in and end the others', () async {
    final other = await signIn();

    await change();

    expect(await kit.service.authenticate(token), isNotNull);
    expect(await kit.service.authenticate(other), isNull);
  });

  test('should refuse a wrong current password and change nothing', () async {
    final result = await change(current: 'not-the-password');

    expect(result, isA<CurrentPasswordWrong>());
    expect(await signIn(), isNotEmpty);
  });

  test('should slow down repeated wrong current passwords', () async {
    for (var i = 0; i < 5; i++) {
      await change(current: 'wrong-$i');
    }

    final result = await change();

    expect(result, isA<ChangeThrottled>());
  });

  test('should check the new password with the usual rules', () async {
    final short = await change(next: 'short');
    final withName = await change(next: 'my-owner-password');

    expect(
      (short as NewPasswordRefused).problem,
      CredentialProblem.passwordTooShort,
    );
    expect(
      (withName as NewPasswordRefused).problem,
      CredentialProblem.passwordContainsUsername,
    );
  });

  test('should refuse the password already in use', () async {
    final result = await change(next: AccessKit.password);

    expect(result, isA<NewPasswordSame>());
  });

  test('should audit the change without writing any password', () async {
    await change();
    await change(current: 'wrong-wrong');

    expect(await kit.repository.auditTrailIsIntact(), isTrue);
  });
}
