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

const _jpeg = [0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3];
const _png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 1, 2];
const _webp = [0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x45, 0x42, 0x50];

void main() {
  late AccessKit kit;
  late Account owner;

  setUp(() async {
    kit = await AccessKit.create();
    owner = ((await kit.registerAdmin()) as Registered).account;
  });
  tearDown(() => kit.close());

  Future<ProfileResult> save({
    String first = 'Rafi',
    String last = 'Ahmed',
    String email = 'rafi@clinic.test',
    String phone = '+880 1711-000000',
  }) => kit.service.updateProfile(
    accountId: owner.id,
    firstName: first,
    lastName: last,
    email: email,
    phone: phone,
  );

  group('updating the profile', () {
    test('should keep the names, email and phone', () async {
      final result = await save();

      final account = (result as ProfileSaved).account;
      expect(account.firstName, 'Rafi');
      expect(account.lastName, 'Ahmed');
      expect(account.displayName, 'Rafi Ahmed');
      expect(account.email, 'rafi@clinic.test');
      expect(account.phone, '+880 1711-000000');
    });

    test('should be what the next sign-in shows', () async {
      await save();

      final login = await kit.service.login(
        username: 'owner',
        password: AccessKit.password,
        clientKey: 'c',
      );

      expect((login as LoggedIn).account.displayName, 'Rafi Ahmed');
    });

    test('should lower-case the email', () async {
      final result = await save(email: ' Rafi@Clinic.TEST ');

      expect((result as ProfileSaved).account.email, 'rafi@clinic.test');
    });

    test('should allow a missing last name and phone', () async {
      final result = await save(last: '', phone: '');

      expect((result as ProfileSaved).account.displayName, 'Rafi');
    });

    test('should need a first name', () async {
      final result = await save(first: '  ');

      expect(
        (result as ProfileRefused).problem,
        ProfileProblem.firstNameMissing,
      );
    });

    test('should refuse a very long name', () async {
      final result = await save(last: 'x' * 65);

      expect((result as ProfileRefused).problem, ProfileProblem.nameTooLong);
    });

    test('should refuse a bad email', () async {
      final result = await save(email: 'not-an-email');

      expect((result as ProfileRefused).problem, ProfileProblem.emailInvalid);
    });

    test('should refuse letters in the phone number', () async {
      final result = await save(phone: 'call me');

      expect((result as ProfileRefused).problem, ProfileProblem.phoneInvalid);
    });

    test('should leave the profile alone when refused', () async {
      await save(email: 'bad');

      final login = await kit.service.login(
        username: 'owner',
        password: AccessKit.password,
        clientKey: 'c',
      );
      expect((login as LoggedIn).account.displayName, 'The Owner');
    });

    test('should audit the change without writing the values', () async {
      await save();

      expect(await kit.repository.auditTrailIsIntact(), isTrue);
    });

    test('should know the name of an account saved before first and last '
        'names existed', () {
      // Derived from the display name when the columns are empty.
      expect(owner.firstName, 'The');
      expect(owner.lastName, 'Owner');
    });
  });

  group('the profile picture', () {
    test('should keep a JPEG, PNG or WebP', () async {
      for (final bytes in [_jpeg, _png, _webp]) {
        final result = await kit.service.changePhoto(
          accountId: owner.id,
          bytes: bytes,
        );

        expect(result, isA<PhotoSaved>());
        expect(await kit.service.photoOf(owner.id), bytes);
      }
    });

    test('should change the photo version when the picture changes', () async {
      final first = (await kit.service.changePhoto(
        accountId: owner.id,
        bytes: _jpeg,
      ) as PhotoSaved).account;
      kit.clock.advance(const Duration(seconds: 5));
      final second = (await kit.service.changePhoto(
        accountId: owner.id,
        bytes: _png,
      ) as PhotoSaved).account;

      expect(first.photoVersion, greaterThan(0));
      expect(second.photoVersion, greaterThan(first.photoVersion));
    });

    test('should refuse something that is not a picture', () async {
      final result = await kit.service.changePhoto(
        accountId: owner.id,
        bytes: [1, 2, 3, 4],
      );

      expect(result, isA<PhotoUnsupported>());
      expect(await kit.service.photoOf(owner.id), isNull);
    });

    test('should refuse a picture that is too big', () async {
      final result = await kit.service.changePhoto(
        accountId: owner.id,
        bytes: [..._jpeg, ...List.filled(AccessPolicy.maxPhotoBytes, 0)],
      );

      expect(result, isA<PhotoTooLarge>());
    });

    test('should remove the picture', () async {
      await kit.service.changePhoto(accountId: owner.id, bytes: _jpeg);

      final account = await kit.service.removePhoto(owner.id);

      expect(account.photoVersion, 0);
      expect(await kit.service.photoOf(owner.id), isNull);
    });
  });

  group('image types', () {
    test('should not mistake a RIFF file that is not WebP for a picture', () {
      expect(
        AccessPolicy.imageType([
          0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x41, 0x56, 0x45, //
        ]),
        isNull,
      );
    });

    test('should handle short input', () {
      expect(AccessPolicy.imageType(const []), isNull);
      expect(AccessPolicy.imageType(const [0xFF]), isNull);
    });
  });
}
