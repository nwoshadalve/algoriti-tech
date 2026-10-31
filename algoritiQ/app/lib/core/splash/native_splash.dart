// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Android launch screen (animated logo). It stays up until the app
/// reports that the first real screen is on its way, so there is no blank
/// screen in between. See `SplashChannel.kt` and `MainActivity.kt`.
abstract interface class NativeSplash {
  /// Tells the platform the first real screen is drawn; the launch screen
  /// can go. Safe to call more than once, and a no-op off Android.
  Future<void> release();
}

final class ChannelNativeSplash implements NativeSplash {
  const ChannelNativeSplash();

  static const _channel = MethodChannel('tech.algoriti.algoritiq/splash');

  @override
  Future<void> release() async {
    try {
      await _channel.invokeMethod<void>('release');
    } on MissingPluginException {
      // Not running on Android (tests, desktop): there is no launch screen.
    }
  }
}

final nativeSplashProvider = Provider<NativeSplash>(
  (ref) => const ChannelNativeSplash(),
);
