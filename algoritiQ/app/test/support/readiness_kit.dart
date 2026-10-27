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
  Future<void> startService() async => calls.add('startService');

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
  MemoryReadinessStore({this.acknowledged = false, this.asked = false});

  bool acknowledged;
  bool asked;

  @override
  Future<bool> isAcknowledged() async => acknowledged;

  @override
  Future<void> setAcknowledged() async => acknowledged = true;

  @override
  Future<bool> notificationsAsked() async => asked;

  @override
  Future<void> setNotificationsAsked() async => asked = true;
}
