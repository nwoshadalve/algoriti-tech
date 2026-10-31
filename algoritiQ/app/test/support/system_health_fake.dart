// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/platform/system_health_gateway.dart';

/// A tablet whose readings the test controls.
class FakeSystemHealth implements SystemHealthGateway {
  double cpuPercent = 10;
  int ramAvailable = 4000;
  int storageAvailable = 50000;
  BluetoothState bluetooth = BluetoothState.on;
  bool fails = false;

  @override
  Future<SystemHealth> read() async {
    if (fails) throw StateError('no reading');
    return SystemHealth(
      cpuPercent: cpuPercent,
      cpuCores: 8,
      ramTotalBytes: 8000,
      ramAvailableBytes: ramAvailable,
      ramLow: false,
      storageTotalBytes: 100000,
      storageAvailableBytes: storageAvailable,
      bluetooth: bluetooth,
      deviceUptime: const Duration(hours: 5),
      androidServiceUptime: const Duration(hours: 4),
    );
  }

  final calls = <String>[];

  /// Runs when [requestBluetoothConnect] is called.
  bool grantBluetoothConnect = true;

  @override
  Future<bool> requestBluetoothConnect() async {
    calls.add('requestBluetoothConnect');
    if (grantBluetoothConnect) {
      bluetooth = BluetoothState.on;
    }
    return grantBluetoothConnect;
  }

  @override
  Future<BluetoothEnableOutcome> requestEnableBluetooth() async {
    if (bluetooth == BluetoothState.missing) {
      return BluetoothEnableOutcome.missing;
    }
    if (bluetooth == BluetoothState.denied) {
      return BluetoothEnableOutcome.denied;
    }
    if (bluetooth == BluetoothState.on) {
      return BluetoothEnableOutcome.alreadyOn;
    }
    bluetooth = BluetoothState.on;
    return BluetoothEnableOutcome.dialogShown;
  }
}
