import 'package:algoritiq_app/features/access/application/access_service.dart';
import 'package:algoritiq_app/features/access/application/claim_codes.dart';
import 'package:algoritiq_app/features/access/domain/access_policy.dart';
import 'package:algoritiq_app/features/access/domain/account.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/access_kit.dart';

void main() {
  late AccessKit kit;

  setUp(() async => kit = await AccessKit.create());
  tearDown(() => kit.close());

  group('registering the first admin', () {
    test('should create the admin with the code from the screen', () async {
      final result = await kit.registerAdmin();

      expect(result, isA<Registered>());
      final account = (result as Registered).account;
      expect(account.username, 'owner');
      expect(account.displayName, 'The Owner');
      expect(account.role, Role.admin);
      expect(await kit.service.hasAdmin, isTrue);
    });

    test(
      'should refuse a wrong claim code and say how many tries are left',
      () async {
        kit.claimCodes.current();

        final result = await kit.registerAdmin(claimCode: 'WRONG123');

        expect(result, isA<ClaimRefused>());
        expect((result as ClaimRefused).reason, ClaimCheck.wrong);
        expect(result.attemptsLeft, 4);
        expect(await kit.service.hasAdmin, isFalse);
      },
    );

    test('should refuse an expired claim code', () async {
      final code = kit.claimCodes.current().code;
      kit.clock.advance(const Duration(minutes: 16));

      final result = await kit.registerAdmin(claimCode: code);

      expect((result as ClaimRefused).reason, ClaimCheck.expired);
    });

    test('should use the claim code up', () async {
      final code = kit.claimCodes.current().code;
      await kit.registerAdmin(claimCode: code);

      expect(kit.claimCodes.check(code), ClaimCheck.expired);
    });

    test('should keep the claim code when the password is refused', () async {
      final code = kit.claimCodes.current().code;

      final result = await kit.registerAdmin(claimCode: code, pass: 'short');

      expect(
        (result as CredentialsRefused).problem,
        CredentialProblem.passwordTooShort,
      );
      expect(kit.claimCodes.check(code), ClaimCheck.ok);
    });

    test('should check the claim code before looking at the form', () async {
      kit.claimCodes.current();

      final result = await kit.registerAdmin(claimCode: 'WRONG123', pass: 'x');

      expect(result, isA<ClaimRefused>());
    });

    test('should close registration once an admin exists', () async {
      await kit.registerAdmin();

      final second = await kit.registerAdmin(username: 'someone-else');

      expect(second, isA<AdminAlreadyRegistered>());
    });

    test('should store a hash, never the password', () async {
      await kit.registerAdmin();

      final stored = await kit.repository.findCredentials('owner');

      expect(stored!.passwordHash, startsWith('argon2id'));
      expect(stored.passwordHash, isNot(contains(AccessKit.password)));
    });

    test('should not allow the same name in another case', () async {
      await kit.registerAdmin(username: 'Owner');

      expect(
        (await kit.repository.findCredentials('owner'))!.account.username,
        'owner',
      );
    });
  });

  group('signing in', () {
    setUp(() => kit.registerAdmin());

    Future<LoginResult> login({
      String username = 'owner',
      String password = AccessKit.password,
      String client = '10.0.0.5',
    }) => kit.service.login(
      username: username,
      password: password,
      clientKey: client,
    );

    test('should sign in with the right password and give a token', () async {
      final result = await login();

      expect(result, isA<LoggedIn>());
      final token = (result as LoggedIn).token;
      expect(token.length, greaterThanOrEqualTo(40));
      expect((await kit.service.authenticate(token))!.username, 'owner');
    });

    test('should ignore the case of the username', () async {
      expect(await login(username: 'OWNER'), isA<LoggedIn>());
    });

    test('should refuse a wrong password', () async {
      expect(
        await login(password: 'not-the-password'),
        isA<InvalidCredentials>(),
      );
    });

    test('should refuse an unknown user the same way', () async {
      expect(await login(username: 'nobody'), isA<InvalidCredentials>());
    });

    test('should make the sixth wrong try wait', () async {
      for (var i = 0; i < 5; i++) {
        await login(password: 'wrong-password-$i');
      }

      final result = await login();

      expect(result, isA<TooManyAttempts>());
      expect(
        (result as TooManyAttempts).retryAfter,
        const Duration(seconds: 30),
      );
    });

    test('should slow a guesser who tries many different names', () async {
      for (var i = 0; i < 5; i++) {
        await login(username: 'guess$i', password: 'wrong-password');
      }

      expect(await login(client: '10.0.0.5'), isA<TooManyAttempts>());
      expect(await login(client: '10.0.0.9'), isA<LoggedIn>());
    });

    test('should accept the right password again after the wait', () async {
      for (var i = 0; i < 5; i++) {
        await login(password: 'wrong-password-$i');
      }
      kit.clock.advance(const Duration(seconds: 31));

      expect(await login(), isA<LoggedIn>());
    });

    test('should stop a token working after logout', () async {
      final token = ((await login()) as LoggedIn).token;

      await kit.service.logout(token);

      expect(await kit.service.authenticate(token), isNull);
    });

    test('should stop a token working after twelve hours', () async {
      final token = ((await login()) as LoggedIn).token;

      kit.clock.advance(const Duration(hours: 12));

      expect(await kit.service.authenticate(token), isNull);
    });

    test('should not know a made-up token', () async {
      expect(await kit.service.authenticate('made-up-token'), isNull);
    });

    test('should keep only a hash of the token', () async {
      final token = ((await login()) as LoggedIn).token;

      final rows = await kit.database.select(kit.database.authSessions).get();

      expect(rows.single.tokenHash, isNot(token));
      expect(rows.single.tokenHash, hasLength(64));
    });
  });

  group('audit trail', () {
    test('should record registration, sign-ins and failures', () async {
      await kit.registerAdmin();
      await kit.service.login(
        username: 'owner',
        password: 'wrong-password',
        clientKey: 'c',
      );
      final token = ((await kit.service.login(
        username: 'owner',
        password: AccessKit.password,
        clientKey: 'c',
      )) as LoggedIn).token;
      await kit.service.logout(token);

      final actions =
          (await kit.database.select(kit.database.auditEntries).get()).map(
            (e) => e.action,
          );

      expect(actions, [
        'admin.registered',
        'auth.login_failed',
        'auth.login',
        'auth.logout',
      ]);
    });

    test('should record a refused claim code', () async {
      kit.claimCodes.current();

      await kit.registerAdmin(claimCode: 'WRONG123');

      final entry =
          (await kit.database.select(kit.database.auditEntries).get()).single;
      expect(entry.action, 'admin.claim_refused');
      expect(entry.detail, 'wrong');
    });

    test('should never put a password or token in the trail', () async {
      await kit.registerAdmin();
      final token = ((await kit.service.login(
        username: 'owner',
        password: AccessKit.password,
        clientKey: 'c',
      )) as LoggedIn).token;

      final text = (await kit.database.select(kit.database.auditEntries).get())
          .map((e) => '${e.action} ${e.detail}')
          .join(' ');

      expect(text, isNot(contains(AccessKit.password)));
      expect(text, isNot(contains(token)));
    });

    test('should be intact, and detect an edited entry', () async {
      await kit.registerAdmin();
      await kit.service.login(
        username: 'owner',
        password: AccessKit.password,
        clientKey: 'c',
      );
      expect(await kit.repository.auditTrailIsIntact(), isTrue);

      await kit.database.customStatement(
        "UPDATE audit_entries SET action = 'auth.nothing' WHERE seq = 1",
      );

      expect(await kit.repository.auditTrailIsIntact(), isFalse);
    });

    test('should detect a removed entry', () async {
      await kit.registerAdmin();
      await kit.service.login(
        username: 'owner',
        password: AccessKit.password,
        clientKey: 'c',
      );

      await kit.database.customStatement(
        'DELETE FROM audit_entries WHERE seq = 1',
      );

      expect(await kit.repository.auditTrailIsIntact(), isFalse);
    });
  });
}
