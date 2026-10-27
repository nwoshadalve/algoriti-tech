import 'package:algoritiq_app/app/bootstrap.dart';
import 'package:algoritiq_app/core/l10n/locale_controller.dart';
import 'package:algoritiq_app/features/clinic/application/clinic_providers.dart';
import 'package:algoritiq_app/features/licensing/application/license_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../support/licensing_kit.dart';
import '../support/memory_locale_store.dart';

void main() {
  late LicensingKit kit;

  setUpAll(() async => kit = await LicensingKit.create());

  ProviderContainer containerWith(List<Override> overrides) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  // regression: the launch screen was followed by a blank screen while the
  // license and setup state loaded after the first frame.
  test('should have the license and setup progress ready before the first '
      'frame on a licensed doctor device', () async {
    final store = MemoryLicenseStore(await kit.issue());
    final container = containerWith(kit.overrides(store: store));

    await preloadStartupState(container);

    expect(container.read(licenseControllerProvider).hasValue, isTrue);
    expect(container.read(setupStageProvider).hasValue, isTrue);
    expect(container.read(doctorsProvider).hasValue, isTrue);
    expect(container.read(chambersProvider).hasValue, isTrue);
  });

  test('should have the license ready on an unlicensed device', () async {
    final container = containerWith(kit.overrides());

    await preloadStartupState(container);

    expect(container.read(licenseControllerProvider).hasValue, isTrue);
  });

  test('should apply the saved language before the first frame', () async {
    final container = containerWith(
      kit.overrides(localeStore: MemoryLocaleStore('bn')),
    );

    await preloadStartupState(container);

    expect(container.read(localeControllerProvider), const Locale('bn'));
  });

  test('should still start when the device id cannot be read', () async {
    final container = containerWith(kit.overrides(deviceIdUnavailable: true));

    await preloadStartupState(container);

    expect(container.read(licenseControllerProvider).hasError, isTrue);
  });
}
