// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/l10n/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/memory_locale_store.dart';

void main() {
  ProviderContainer containerWith(MemoryLocaleStore store) {
    final container = ProviderContainer(
      overrides: [localeStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    container.listen(localeControllerProvider, (_, _) {});
    return container;
  }

  test('should follow the device language until the user picks one', () {
    final container = containerWith(MemoryLocaleStore());

    expect(container.read(localeControllerProvider), isNull);
  });

  test('should save the chosen language', () async {
    final store = MemoryLocaleStore();
    final container = containerWith(store);

    await container
        .read(localeControllerProvider.notifier)
        .select(const Locale('bn'));

    expect(container.read(localeControllerProvider), const Locale('bn'));
    expect(store.code, 'bn');
  });

  test('should restore the saved language after a restart', () async {
    final container = containerWith(MemoryLocaleStore('bn'));

    await Future<void>.delayed(Duration.zero);

    expect(container.read(localeControllerProvider), const Locale('bn'));
  });

  test('should ignore a saved language the app does not support', () async {
    final container = containerWith(MemoryLocaleStore('xx'));

    await Future<void>.delayed(Duration.zero);

    expect(container.read(localeControllerProvider), isNull);
  });
}
