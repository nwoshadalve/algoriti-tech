import 'package:algoritiq_app/features/licensing/application/license_controller.dart';
import 'package:algoritiq_app/features/licensing/domain/license_state.dart';
import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/licensing_kit.dart';

void main() {
  late LicensingKit kit;

  setUpAll(() async => kit = await LicensingKit.create());

  ProviderContainer containerWith(MemoryLicenseStore store) {
    final container = ProviderContainer(overrides: kit.overrides(store: store));
    addTearDown(container.dispose);
    return container;
  }

  Future<LicenseState> start(ProviderContainer container) =>
      container.read(licenseControllerProvider.future);

  group('on start', () {
    test('should be unlicensed with no stored key', () async {
      final state = await start(containerWith(MemoryLicenseStore()));

      expect(state, isA<Unlicensed>());
      expect((state as Unlicensed).problem, isNull);
    });

    test('should be licensed with a valid stored key', () async {
      final store = MemoryLicenseStore(await kit.issue());
      final state = await start(containerWith(store));

      expect(state, isA<Licensed>());
      expect((state as Licensed).status, LicenseStatus.active);
    });

    // regression: a key copied from another tablet must not unlock this one.
    test('should reject a stored key issued for another device', () async {
      final store = MemoryLicenseStore(
        await kit.issue(forDeviceId: 'someone-elses-tablet'),
      );
      final state = await start(containerWith(store));

      expect((state as Unlicensed).problem, LicenseProblem.wrongDevice);
    });

    test('should keep working during the grace period', () async {
      final store = MemoryLicenseStore(
        await kit.issue(expiresAt: testNow.subtract(const Duration(days: 5))),
      );
      final state = await start(containerWith(store));

      expect((state as Licensed).status, LicenseStatus.grace);
    });

    test('should ask for renewal after the grace period', () async {
      final store = MemoryLicenseStore(
        await kit.issue(expiresAt: testNow.subtract(const Duration(days: 40))),
      );
      final state = await start(containerWith(store));

      expect((state as Unlicensed).problem, LicenseProblem.expired);
    });
  });

  group('activate', () {
    test('should store a valid key and unlock the app', () async {
      final store = MemoryLicenseStore();
      final container = containerWith(store);
      await start(container);
      final token = await kit.issue();

      final problem = await container
          .read(licenseControllerProvider.notifier)
          .activate('  $token  ');

      expect(problem, isNull);
      expect(store.token, token);
      expect(container.read(licenseControllerProvider).value, isA<Licensed>());
    });

    test('should reject and not store a key for another device', () async {
      final store = MemoryLicenseStore();
      final container = containerWith(store);
      await start(container);

      final problem = await container
          .read(licenseControllerProvider.notifier)
          .activate(await kit.issue(forDeviceId: 'other-device'));

      expect(problem, LicenseProblem.wrongDevice);
      expect(store.token, isNull);
      expect(
        container.read(licenseControllerProvider).value,
        isA<Unlicensed>(),
      );
    });

    test('should reject text that is not a key', () async {
      final store = MemoryLicenseStore();
      final container = containerWith(store);
      await start(container);

      final problem = await container
          .read(licenseControllerProvider.notifier)
          .activate('not a key');

      expect(problem, LicenseProblem.malformed);
      expect(store.token, isNull);
    });

    test('should replace an expired license with a renewed key', () async {
      final store = MemoryLicenseStore(
        await kit.issue(expiresAt: testNow.subtract(const Duration(days: 40))),
      );
      final container = containerWith(store);
      await start(container);
      final renewed = await kit.issue(
        expiresAt: testNow.add(const Duration(days: 365)),
      );

      final problem = await container
          .read(licenseControllerProvider.notifier)
          .activate(renewed);

      expect(problem, isNull);
      expect(store.token, renewed);
      expect(
        (container.read(licenseControllerProvider).value! as Licensed).status,
        LicenseStatus.active,
      );
    });
  });
}
