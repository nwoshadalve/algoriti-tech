// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What Android currently allows for keeping the local API alive.
final class KeepAliveStatus {
  const KeepAliveStatus({
    required this.manufacturer,
    required this.notificationsGranted,
    required this.notificationsNeedPermission,
    required this.batteryOptimizationIgnored,
    required this.serviceRunning,
    required this.autoStartRequired,
    required this.autoStartGranted,
  });

  /// Lower-case maker name (`honor`, `samsung`, ...).
  final String manufacturer;

  /// Notifications are allowed for the app.
  final bool notificationsGranted;

  /// Android 13+ asks the user; older versions allow by default.
  final bool notificationsNeedPermission;

  /// Android may not pause the app to save battery.
  final bool batteryOptimizationIgnored;

  /// The background service is running.
  final bool serviceRunning;

  /// This maker has a separate "auto-start" / app-launch screen.
  final bool autoStartRequired;

  /// Auto-start (or equivalent background launch) is allowed for this app.
  final bool autoStartGranted;
}

/// Typed wrapper over `KeepAliveChannel.kt`. Requests open a system dialog or
/// settings page; nothing is changed silently.
abstract interface class KeepAliveGateway {
  Future<KeepAliveStatus> status();

  /// Fires when the tablet's Wi-Fi or IP may have changed (link up, down, or
  /// new addresses). Used to refresh the local network name immediately.
  Stream<void> get networkChanges;

  /// The tablet's IPv4 addresses on its networks (Wi-Fi first).
  Future<List<String>> localAddresses();

  /// The tablet's IPv6 link-local addresses on its networks (Wi-Fi first),
  /// without the interface suffix.
  Future<List<String>> localAddressesV6();

  Future<void> startService();

  /// Shows the system permission dialog. Returns whether it was granted.
  Future<bool> requestNotifications();

  Future<void> requestIgnoreBatteryOptimizations();

  Future<void> openNotificationSettings();

  /// The maker's auto-start page when known, else the app's settings page.
  Future<void> openAutoStartSettings();

  Future<void> openAppSettings();
}

final class ChannelKeepAliveGateway implements KeepAliveGateway {
  const ChannelKeepAliveGateway();

  static const _channel = MethodChannel('tech.algoriti.algoritiq/keepalive');
  static const _events = EventChannel(
    'tech.algoriti.algoritiq/keepalive/events',
  );

  @override
  Stream<void> get networkChanges =>
      _events.receiveBroadcastStream().map((_) {});

  @override
  Future<KeepAliveStatus> status() async {
    final map = await _channel.invokeMapMethod<String, Object?>('status');
    bool flag(String key) => map?[key] == true;
    return KeepAliveStatus(
      manufacturer: (map?['manufacturer'] as String?) ?? '',
      notificationsGranted: flag('notificationsGranted'),
      notificationsNeedPermission: flag('notificationsNeedPermission'),
      batteryOptimizationIgnored: flag('batteryOptimizationIgnored'),
      serviceRunning: flag('serviceRunning'),
      autoStartRequired: flag('autoStartRequired'),
      autoStartGranted: flag('autoStartGranted'),
    );
  }

  @override
  Future<List<String>> localAddresses() async =>
      (await _channel.invokeListMethod<String>('localAddresses')) ?? const [];

  @override
  Future<List<String>> localAddressesV6() async =>
      (await _channel.invokeListMethod<String>('localAddressesV6')) ?? const [];

  @override
  Future<void> startService() => _channel.invokeMethod<void>('startService');

  @override
  Future<bool> requestNotifications() async =>
      (await _channel.invokeMethod<bool>('requestNotifications')) ?? false;

  @override
  Future<void> requestIgnoreBatteryOptimizations() =>
      _channel.invokeMethod<void>('requestIgnoreBatteryOptimizations');

  @override
  Future<void> openNotificationSettings() =>
      _channel.invokeMethod<void>('openNotificationSettings');

  @override
  Future<void> openAutoStartSettings() =>
      _channel.invokeMethod<void>('openAutoStartSettings');

  @override
  Future<void> openAppSettings() =>
      _channel.invokeMethod<void>('openAppSettings');
}

final keepAliveGatewayProvider = Provider<KeepAliveGateway>(
  (ref) => const ChannelKeepAliveGateway(),
);
