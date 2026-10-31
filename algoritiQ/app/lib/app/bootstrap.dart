// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart'
    show ProviderListenable, Refreshable;

import '../api/server_controller.dart';
import '../core/l10n/locale_controller.dart';
import '../core/splash/native_splash.dart';
import '../features/access/application/access_providers.dart';
import '../features/clinic/application/clinic_providers.dart';
import '../features/connectivity/application/printer_controller.dart';
import '../features/licensing/application/license_controller.dart';
import '../features/licensing/domain/license_payload.dart';
import '../features/licensing/domain/license_state.dart';
import 'app.dart';

/// Starts the app.
///
/// Everything the first screen depends on (saved language, license, setup
/// progress) is loaded before the first frame, so the launch screen is
/// followed directly by the real screen, never by a blank one.
///
/// The same code runs when the tablet has just restarted and nobody has
/// opened the app: the background service starts this engine with no screen.
/// Then only the local API is started, and the screen is built later, when
/// the app is opened. The printer connection is kept the same way.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await preloadStartupState(container);

  // An activated tablet serves its API from now on, screen or no screen. The
  // printer link is kept the same way: the controller reconnects by itself
  // whenever the printer is on, even with the app closed or just after a restart.
  if (container.read(licenseControllerProvider).value is Licensed) {
    container.listen(serverControllerProvider, (_, _) {});
    container.listen(printerControllerProvider, (_, _) {});
  }

  await waitForScreen(PlatformDispatcher.instance);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AlgoritiqApp(),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => container.read(nativeSplashProvider).release(),
  );
}

/// Completes once [dispatcher] has a screen to draw on (immediately when the
/// app was opened normally; later when the engine started without one).
Future<void> waitForScreen(PlatformDispatcher dispatcher) {
  if (dispatcher.implicitView != null) return Future.value();
  final shown = Completer<void>();
  final previous = dispatcher.onMetricsChanged;
  dispatcher.onMetricsChanged = () {
    previous?.call();
    if (dispatcher.implicitView != null && !shown.isCompleted) {
      dispatcher.onMetricsChanged = previous;
      shown.complete();
    }
  };
  return shown.future;
}

/// Loads, ahead of the first frame, what the first screen shows.
///
/// A failed load is not handled here: the screen that needs it shows its own
/// retry view.
Future<void> preloadStartupState(ProviderContainer container) async {
  await container.read(localeControllerProvider.notifier).restored;
  await _load(
    container,
    licenseControllerProvider,
    licenseControllerProvider.future,
  );

  final license = container.read(licenseControllerProvider).value;
  if (license is Licensed) {
    await _load(container, adminCountProvider, adminCountProvider.future);
  }
  if (license is Licensed && license.payload.type == LicenseType.doctor) {
    await Future.wait([
      _load(container, setupStageProvider, setupStageProvider.future),
      _load(container, doctorsProvider, doctorsProvider.future),
      _load(container, chambersProvider, chambersProvider.future),
    ]);
  }
}

/// Waits for the first value of [provider] and ignores a failure (see
/// [preloadStartupState]).
///
/// The listener is kept for the life of the container: without one, Riverpod
/// pauses a stream provider and it would never produce its first value.
Future<void> _load<T>(
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider,
  Refreshable<Future<T>> firstValue,
) {
  container.listen(provider, (_, _) {});
  return container.read(firstValue).then<void>((_) {}, onError: (Object _) {});
}
