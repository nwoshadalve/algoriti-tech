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

const _pin = '482913';

void main() {
  late AccessKit kit;
  late Account owner;

  setUp(() async {
    kit = await AccessKit.create();
    owner = ((await kit.registerAdmin()) as Registered).account;
  });
  tearDown(() => kit.close());

  Future<SetPinResult> setPin({
    String password = AccessKit.password,
    String pin = _pin,
    String? replace,
    String label = 'Laptop',
  }) => kit.service.setPin(
    account: owner,
    password: password,
    pin: pin,
    label: label,
    replaceDeviceId: replace,
  );

  Future<PinSet> newDevice({String pin = _pin}) async =>
      await setPin(pin: pin) as PinSet;

  Future<PinLoginResult> pinLogin(
    String token,
    String pin, {
    String client = 'c',
  }) =>
      kit.service.loginWithPin(deviceToken: token, pin: pin, clientKey: client);

  group('remembering a browser', () {
    test('should keep a normal sign-in for twelve hours', () async {
      final result = await kit.service.login(
        username: 'owner',
        password: AccessKit.password,
        clientKey: 'c',
      );

      expect(
        (result as LoggedIn).expiresAt.difference(kit.clock.now),
        const Duration(hours: 12),
      );
    });

    test('should keep a remembered sign-in for thirty days', () async {
      final result = await kit.service.login(
        username: 'owner',
        password: AccessKit.password,
        clientKey: 'c',
        remember: true,
      );

      final session = result as LoggedIn;
      expect(
        session.expiresAt.difference(kit.clock.now),
        const Duration(days: 30),
      );
      expect(await kit.service.authenticate(session.token), isNotNull);
      kit.clock.advance(const Duration(days: 29));
      expect(await kit.service.authenticate(session.token), isNotNull);
      kit.clock.advance(const Duration(days: 2));
      expect(await kit.service.authenticate(session.token), isNull);
    });
  });

  group('the PIN rules', () {
    test('should accept six digits that are not an obvious guess', () {
      expect(AccessPolicy.checkPin('482913'), isNull);
      expect(AccessPolicy.checkPin('135790'), isNull);
    });

    test('should need exactly six digits', () {
      for (final pin in ['', '12345', '1234567', '12a456', '12 456']) {
        expect(AccessPolicy.checkPin(pin), PinProblem.format, reason: pin);
      }
    });

    test('should refuse one digit repeated and straight runs', () {
      for (final pin in [
        '000000',
        '777777',
        '123456',
        '654321',
        '345678',
        '987654',
      ]) {
        expect(AccessPolicy.checkPin(pin), PinProblem.weak, reason: pin);
      }
    });
  });

  group('setting a PIN', () {
    test('should need the password', () async {
      final result = await setPin(password: 'not-the-password');

      expect(result, isA<PinPasswordWrong>());
      expect(await kit.service.pinDevices(owner), isEmpty);
    });

    test('should slow down wrong passwords', () async {
      for (var i = 0; i < 5; i++) {
        await setPin(password: 'wrong-$i');
      }

      expect(await setPin(), isA<PinSetThrottled>());
    });

    test('should refuse a weak or badly formed PIN', () async {
      expect(
        (await setPin(pin: '123456') as PinRefused).problem,
        PinProblem.weak,
      );
      expect(
        (await setPin(pin: '12') as PinRefused).problem,
        PinProblem.format,
      );
    });

    test(
      'should hand back a secret for the browser and list the browser',
      () async {
        final result = await newDevice();

        expect(result.deviceToken.length, greaterThan(30));
        final devices = await kit.service.pinDevices(owner);
        expect(devices.single.label, 'Laptop');
        expect(devices.single.lastUsedAt, isNull);
      },
    );

    test('should keep at most five browsers, dropping the oldest', () async {
      final first = await newDevice();
      for (var i = 0; i < 5; i++) {
        kit.clock.advance(const Duration(minutes: 1));
        await newDevice();
      }

      expect(await kit.service.pinDevices(owner), hasLength(5));
      expect(await pinLogin(first.deviceToken, _pin), isA<PinUnavailable>());
    });

    test('should replace this browser’s earlier PIN', () async {
      final old = await newDevice();

      await setPin(pin: '902417', replace: old.device.id);

      expect(await kit.service.pinDevices(owner), hasLength(1));
      expect(await pinLogin(old.deviceToken, _pin), isA<PinUnavailable>());
    });
  });

  group('signing in with a PIN', () {
    test('should open a session and remember when it was used', () async {
      final device = await newDevice();
      kit.clock.advance(const Duration(hours: 1));

      final result = await pinLogin(device.deviceToken, _pin);

      final session = (result as PinLoggedIn).session;
      expect((await kit.service.authenticate(session.token))!.id, owner.id);
      expect(
        session.expiresAt.difference(kit.clock.now),
        const Duration(hours: 12),
      );
      expect(
        (await kit.service.pinDevices(owner)).single.lastUsedAt,
        isNotNull,
      );
    });

    test('should say how many tries are left after a wrong PIN', () async {
      final device = await newDevice();

      final result = await pinLogin(device.deviceToken, '000111');

      expect((result as PinWrong).attemptsLeft, 2);
    });

    test('should remove the PIN after three wrong ones in a row', () async {
      final device = await newDevice();
      PinLoginResult last = const PinUnavailable();
      for (var i = 0; i < 3; i++) {
        last = await pinLogin(device.deviceToken, '00011$i');
      }

      expect(last, isA<PinLocked>());
      expect(await kit.service.pinDevices(owner), isEmpty);
      // Even the right PIN opens nothing now.
      expect(await pinLogin(device.deviceToken, _pin), isA<PinUnavailable>());
    });

    test('should start counting again after a right PIN', () async {
      final device = await newDevice();
      for (var i = 0; i < 2; i++) {
        await pinLogin(device.deviceToken, '00011$i');
      }

      expect(await pinLogin(device.deviceToken, _pin), isA<PinLoggedIn>());
      final next = await pinLogin(device.deviceToken, '000119');

      expect((next as PinWrong).attemptsLeft, 2);
    });

    test('should do nothing without the browser’s secret', () async {
      await newDevice();

      expect(await pinLogin('made-up-secret', _pin), isA<PinUnavailable>());
    });

    test(
      'should not open another account with this browser’s secret',
      () async {
        final device = await newDevice();

        // The right secret with the wrong PIN is just a wrong PIN.
        expect(await pinLogin(device.deviceToken, '111222'), isA<PinWrong>());
      },
    );

    test('should not work for a disabled account', () async {
      final device = await newDevice();
      await kit.repository.updateManagedUser(
        accountId: owner.id,
        firstName: 'The',
        lastName: 'Owner',
        email: 'owner@clinic.test',
        phone: '',
        status: 'inactive',
        actorId: owner.id,
        at: kit.clock.now,
      );

      expect(await pinLogin(device.deviceToken, _pin), isA<PinUnavailable>());
    });

    test('should audit without writing the PIN or the secret', () async {
      final device = await newDevice();
      await pinLogin(device.deviceToken, '000111');
      await pinLogin(device.deviceToken, _pin);

      expect(await kit.repository.auditTrailIsIntact(), isTrue);
    });
  });

  group('removing and revoking', () {
    test('should remove one browser the person owns', () async {
      final device = await newDevice();

      expect(
        await kit.service.removePinDevice(owner, device.device.id),
        isTrue,
      );
      expect(
        await kit.service.removePinDevice(owner, device.device.id),
        isFalse,
      );
      expect(await pinLogin(device.deviceToken, _pin), isA<PinUnavailable>());
    });

    test('should end every PIN when the password is changed', () async {
      final device = await newDevice();
      final login = await kit.service.login(
        username: 'owner',
        password: AccessKit.password,
        clientKey: 'c',
      );

      await kit.service.changePassword(
        account: owner,
        token: (login as LoggedIn).token,
        currentPassword: AccessKit.password,
        newPassword: 'a-better-passphrase',
      );

      expect(await kit.service.pinDevices(owner), isEmpty);
      expect(await pinLogin(device.deviceToken, _pin), isA<PinUnavailable>());
    });

    test('should end every PIN when the password is reset', () async {
      final device = await newDevice();

      await kit.resetPassword(password: 'a-better-passphrase');

      expect(await pinLogin(device.deviceToken, _pin), isA<PinUnavailable>());
    });
  });
}
