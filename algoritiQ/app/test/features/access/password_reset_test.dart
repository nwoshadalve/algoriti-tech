import 'package:algoritiq_app/features/access/application/access_service.dart';
import 'package:algoritiq_app/features/access/domain/access_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/access_kit.dart';

void main() {
  late AccessKit kit;

  const newPassword = 'a-brand-new-passphrase';

  setUp(() async {
    kit = await AccessKit.create();
    await kit.registerAdmin();
  });
  tearDown(() => kit.close());

  Future<ResetStartResult> start({
    String username = 'owner',
    String key = AccessKit.activationKey,
    String client = 'laptop',
  }) => kit.service.startReset(
    username: username,
    activationKey: key,
    clientKey: client,
  );

  Future<ResetFinishResult> finish(
    String ticket, {
    String password = newPassword,
    String client = 'laptop',
  }) => kit.service.finishReset(
    ticket: ticket,
    newPassword: password,
    clientKey: client,
  );

  Future<String> ticket() async => (await start() as ResetTicketIssued).ticket;

  Future<LoginResult> login(String password) => kit.service.login(
    username: 'owner',
    password: password,
    clientKey: 'tablet',
  );

  group('step 1: proving the activation key', () {
    test('should give a ticket when the key is right', () async {
      final result = await start();

      expect(result, isA<ResetTicketIssued>());
      expect((result as ResetTicketIssued).ticket, isNotEmpty);
      expect(
        result.expiresAt.difference(kit.clock.now),
        const Duration(minutes: 10),
      );
    });

    test('should change nothing yet', () async {
      await start();

      expect(await login(AccessKit.password), isA<LoggedIn>());
    });

    test('should accept the key in any case, with spaces or dashes', () async {
      expect(await start(key: ' 040g2 08501\n'), isA<ResetRefused>());
      expect(
        await start(key: ' 040g2 08501\n8h1zz-zq00n '),
        isA<ResetTicketIssued>(),
      );
    });

    test('should refuse a wrong key', () async {
      expect(await start(key: '040G2-08501-8H1ZZ-ZQ00M'), isA<ResetRefused>());
    });

    test('should refuse a key that is only part of the real one', () async {
      expect(await start(key: '040G2-08501'), isA<ResetRefused>());
      expect(await start(key: ''), isA<ResetRefused>());
    });

    test('should not say whether the username exists', () async {
      final wrongKey = await start(key: 'nope');
      final unknownUser = await start(username: 'nobody');

      expect(wrongKey.runtimeType, unknownUser.runtimeType);
    });

    test('should refuse when the tablet has no activation key', () async {
      final noKey = await AccessKit.create(activationKey: null);
      addTearDown(noKey.close);
      await noKey.registerAdmin();

      final result = await noKey.service.startReset(
        username: 'owner',
        activationKey: AccessKit.activationKey,
        clientKey: 'laptop',
      );

      expect(result, isA<ResetRefused>());
    });

    test('should slow down someone guessing keys', () async {
      for (var i = 0; i < 5; i++) {
        expect(await start(key: 'guess$i'), isA<ResetRefused>());
      }

      expect(await start(), isA<ResetThrottled>());
    });

    test('should let the owner try again after the wait', () async {
      for (var i = 0; i < 5; i++) {
        await start(key: 'guess$i');
      }
      kit.clock.advance(const Duration(minutes: 1));

      expect(await start(), isA<ResetTicketIssued>());
    });
  });

  group('step 2: choosing the new password', () {
    test('should set the new password', () async {
      expect(await finish(await ticket()), isA<PasswordWasReset>());

      expect(await login(newPassword), isA<LoggedIn>());
      expect(await login(AccessKit.password), isA<InvalidCredentials>());
    });

    test('should end every sign-in of the account', () async {
      final signedIn = await login(AccessKit.password) as LoggedIn;
      expect(await kit.service.authenticate(signedIn.token), isNotNull);

      await finish(await ticket());

      expect(await kit.service.authenticate(signedIn.token), isNull);
    });

    test('should work only once', () async {
      final once = await ticket();
      await finish(once);

      expect(await finish(once), isA<ResetTicketInvalid>());
    });

    test('should expire after ten minutes', () async {
      final late = await ticket();
      kit.clock.advance(const Duration(minutes: 10));

      expect(await finish(late), isA<ResetTicketInvalid>());
      expect(await login(AccessKit.password), isA<LoggedIn>());
    });

    test('should refuse a ticket nobody issued', () async {
      expect(await finish('not-a-ticket'), isA<ResetTicketInvalid>());
    });

    test('should replace an earlier ticket of the same account', () async {
      final first = await ticket();
      final second = await ticket();

      expect(await finish(first), isA<ResetTicketInvalid>());
      expect(await finish(second), isA<PasswordWasReset>());
    });

    test('should apply the same password rules as registering', () async {
      final t = await ticket();

      final tooShort = await finish(t, password: 'short');
      final hasName = await finish(t, password: 'owner-owner-owner');

      expect(
        (tooShort as ResetCredentialsRefused).problem,
        CredentialProblem.passwordTooShort,
      );
      expect(
        (hasName as ResetCredentialsRefused).problem,
        CredentialProblem.passwordContainsUsername,
      );
      expect(await login(AccessKit.password), isA<LoggedIn>());
    });

    test('should keep the ticket after a refused password', () async {
      final t = await ticket();
      await finish(t, password: 'short');

      expect(await finish(t), isA<PasswordWasReset>());
    });

    test('should slow down someone guessing tickets', () async {
      final real = await ticket();
      for (var i = 0; i < 5; i++) {
        expect(await finish('guess$i'), isA<ResetTicketInvalid>());
      }

      expect(await finish(real), isA<ResetThrottled>());
    });

    test('should lift the lockout on the account when it is reset', () async {
      // Guesses from different devices lock the account, not one device.
      for (var i = 0; i < 5; i++) {
        await kit.service.login(
          username: 'owner',
          password: 'wrong-password-$i',
          clientKey: 'phone$i',
        );
      }
      expect(await login(AccessKit.password), isA<TooManyAttempts>());

      await finish(await ticket());

      expect(await login(newPassword), isA<LoggedIn>());
    });

    test('should not keep tickets across a restart of the app', () async {
      final t = await ticket();
      final restarted = await AccessKit.create();
      addTearDown(restarted.close);
      await restarted.registerAdmin();

      final result = await restarted.service.finishReset(
        ticket: t,
        newPassword: newPassword,
        clientKey: 'laptop',
      );

      expect(result, isA<ResetTicketInvalid>());
    });
  });

  group('the audit trail', () {
    test('should record the key being accepted and the reset', () async {
      await finish(await ticket());
      await start(key: 'wrong');

      final actions = await kit.database
          .customSelect('SELECT action FROM audit_entries ORDER BY seq')
          .map((row) => row.read<String>('action'))
          .get();
      expect(
        actions,
        containsAllInOrder([
          'auth.reset_key_accepted',
          'auth.password_reset',
          'auth.reset_refused',
        ]),
      );
      expect(await kit.repository.auditTrailIsIntact(), isTrue);
    });

    test('should never put a key, ticket or password in it', () async {
      final t = await ticket();
      await finish(t);
      await start(key: 'wrong-key-value');

      final text =
          (await kit.database
                  .customSelect('SELECT action, detail FROM audit_entries')
                  .get())
              .map((row) => '${row.data}')
              .join();
      expect(text, isNot(contains(newPassword)));
      expect(text, isNot(contains(t)));
      expect(text, isNot(contains('wrong-key-value')));
      expect(text, isNot(contains(AccessKit.activationKey)));
    });
  });
}
