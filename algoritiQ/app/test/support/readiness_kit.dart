// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:algoritiq_app/features/readiness/domain/readiness_store.dart';
import 'package:algoritiq_app/platform/keep_alive_gateway.dart';

/// A tablet whose Android settings the test controls. Records what was asked.
class FakeKeepAliveGateway implements KeepAliveGateway {
  FakeKeepAliveGateway({
    this.batteryOptimizationIgnored = true,
    this.notificationsGranted = true,
    this.serviceRunning = true,
    this.autoStartRequired = true,
    this.autoStartGranted = true,
    this.manufacturer = 'honor',
  });

  bool batteryOptimizationIgnored;
  bool notificationsGranted;
  bool serviceRunning;
  bool autoStartRequired;
  bool autoStartGranted;
  String manufacturer;

  final calls = <String>[];

  /// Runs when [startService] is called (a test can make the service come up).
  void Function()? onStart;

  final _networkChanges = StreamController<void>.broadcast();

  @override
  Stream<void> get networkChanges => _networkChanges.stream;

  /// Simulates Android reporting a Wi-Fi or IP change.
  void notifyNetworkChanged() => _networkChanges.add(null);

  @override
  Future<KeepAliveStatus> status() async => KeepAliveStatus(
    manufacturer: manufacturer,
    notificationsGranted: notificationsGranted,
    notificationsNeedPermission: true,
    batteryOptimizationIgnored: batteryOptimizationIgnored,
    serviceRunning: serviceRunning,
    autoStartRequired: autoStartRequired,
    autoStartGranted: autoStartGranted,
  );

  @override
  Future<List<String>> localAddresses() async => const ['192.168.0.20'];

  @override
  Future<List<String>> localAddressesV6() async => const ['fe80::1'];

  @override
  Future<void> startService() async {
    calls.add('startService');
    onStart?.call();
  }

  @override
  Future<bool> requestNotifications() async {
    calls.add('requestNotifications');
    return notificationsGranted;
  }

  @override
  Future<void> requestIgnoreBatteryOptimizations() async =>
      calls.add('requestIgnoreBatteryOptimizations');

  @override
  Future<void> openNotificationSettings() async =>
      calls.add('openNotificationSettings');

  @override
  Future<void> openAutoStartSettings() async =>
      calls.add('openAutoStartSettings');

  @override
  Future<void> openAppSettings() async => calls.add('openAppSettings');
}

class MemoryReadinessStore implements ReadinessStore {
  MemoryReadinessStore({
    this.acknowledged = false,
    this.asked = false,
    this.bluetoothDialogAsked = false,
  });

  bool acknowledged;
  bool asked;
  bool bluetoothDialogAsked;

  @override
  Future<bool> isAcknowledged() async => acknowledged;

  @override
  Future<void> setAcknowledged() async => acknowledged = true;

  @override
  Future<bool> notificationsAsked() async => asked;

  @override
  Future<void> setNotificationsAsked() async => asked = true;

  @override
  Future<bool> bluetoothAsked() async => bluetoothDialogAsked;

  @override
  Future<void> setBluetoothAsked() async => bluetoothDialogAsked = true;
}
