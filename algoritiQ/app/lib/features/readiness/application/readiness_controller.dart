// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../platform/keep_alive_gateway.dart';
import '../../../platform/system_health_gateway.dart';
import '../data/prefs_readiness_store.dart';
import '../domain/readiness_item.dart';
import '../domain/readiness_store.dart';

final readinessStoreProvider = Provider<ReadinessStore>(
  (ref) => const PrefsReadinessStore(),
);

/// The checklist and whether the user already went past the guide.
final class ReadinessReport {
  const ReadinessReport({
    required this.items,
    required this.status,
    required this.acknowledged,
  });

  final List<ReadinessItem> items;
  final KeepAliveStatus status;
  final bool acknowledged;

  /// Every required item is done.
  bool get requiredDone =>
      items.where((item) => item.isRequired).every((item) => item.isDone);

  bool get allDone => items.every((item) => item.isDone);
}

final readinessControllerProvider =
    AsyncNotifierProvider<ReadinessController, ReadinessReport>(
      ReadinessController.new,
    );

/// Reads what Android allows and helps the user fix it. Every fix opens a
/// system dialog or settings page; the checklist is re-read when the user
/// comes back to the app (see `ReadinessGate`).
class ReadinessController extends AsyncNotifier<ReadinessReport> {
  KeepAliveGateway get _gateway => ref.read(keepAliveGatewayProvider);
  SystemHealthGateway get _health => ref.read(systemHealthGatewayProvider);
  ReadinessStore get _store => ref.read(readinessStoreProvider);

  @override
  Future<ReadinessReport> build() async => _read();

  Future<ReadinessReport> _read() async {
    final status = await _gateway.status();
    final health = await _health.read();
    return ReadinessReport(
      status: status,
      items: evaluateReadiness(status, health.bluetooth),
      acknowledged: await _store.isAcknowledged(),
    );
  }

  Future<void> refresh() async {
    final report = await _read();
    if (ref.mounted) state = AsyncData(report);
  }

  /// Opens the system "run in the background" question.
  Future<void> allowBackground() async {
    await _gateway.requestIgnoreBatteryOptimizations();
  }

  /// Asks for notifications; after a refusal the settings page is the only way.
  Future<void> allowNotifications() async {
    if (await _store.notificationsAsked()) {
      await _gateway.openNotificationSettings();
      return;
    }
    await _store.setNotificationsAsked();
    await _gateway.requestNotifications();
    await refresh();
  }

  Future<void> openAutoStartSettings() => _gateway.openAutoStartSettings();

  /// Asks for Bluetooth access; after a refusal the settings page is the only way.
  Future<void> allowBluetooth() async {
    if (await _store.bluetoothAsked()) {
      await _gateway.openAppSettings();
      return;
    }
    await _store.setBluetoothAsked();
    await _health.requestBluetoothConnect();
    await refresh();
  }

  /// The user finished every required step; start the background service and
  /// local HTTPS API (via [ServerHost] below this gate), then hide the guide.
  Future<void> acknowledge() async {
    final report = await _read();
    if (!report.requiredDone) return;
    await _store.setAcknowledged();
    try {
      await _gateway.startService();
    } on Exception {
      // Still continue: [ServerHost] retries the in-process API; boot may
      // start the service later.
    }
    await refresh();
  }
}
