// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bluetooth as Android reports it.
enum BluetoothState { on, off, missing, denied }

/// What happened when an admin asked to turn Bluetooth on from the web.
enum BluetoothEnableOutcome {
  alreadyOn('already_on'),
  dialogShown('dialog_shown'),
  settingsOpened('settings_opened'),
  needAppOpen('need_app_open'),
  missing('missing'),
  denied('denied');

  const BluetoothEnableOutcome(this.code);
  final String code;

  static BluetoothEnableOutcome parse(String code) {
    for (final value in BluetoothEnableOutcome.values) {
      if (value.code == code) return value;
    }
    throw StateError('Unknown Bluetooth enable outcome: $code');
  }
}

/// A reading of the tablet itself (`SystemHealthChannel.kt`).
final class SystemHealth {
  const SystemHealth({
    required this.cpuPercent,
    required this.cpuCores,
    required this.ramTotalBytes,
    required this.ramAvailableBytes,
    required this.ramLow,
    required this.storageTotalBytes,
    required this.storageAvailableBytes,
    required this.bluetooth,
    required this.deviceUptime,
    this.androidServiceUptime,
  });

  /// This app's share of the processor, 0-100 (apps cannot read the total).
  final double cpuPercent;
  final int cpuCores;
  final int ramTotalBytes;
  final int ramAvailableBytes;

  /// Android says memory is running low.
  final bool ramLow;
  final int storageTotalBytes;
  final int storageAvailableBytes;
  final BluetoothState bluetooth;
  final Duration deviceUptime;

  /// How long the background service has run; null while it is stopped.
  final Duration? androidServiceUptime;
}

abstract interface class SystemHealthGateway {
  Future<SystemHealth> read();

  /// Opens Android's dialog or Bluetooth settings on the tablet; never silent.
  Future<BluetoothEnableOutcome> requestEnableBluetooth();

  /// Android 12+ runtime permission; older versions succeed without a dialog.
  Future<bool> requestBluetoothConnect();
}

final class ChannelSystemHealthGateway implements SystemHealthGateway {
  const ChannelSystemHealthGateway();

  static const _channel = MethodChannel('tech.algoriti.algoritiq/systemhealth');

  @override
  Future<SystemHealth> read() async {
    final map = await _channel.invokeMapMethod<String, Object?>('snapshot');
    if (map == null) throw StateError('No system health reading.');
    int whole(String key) => (map[key] as num?)?.toInt() ?? 0;
    final serviceMs = map['androidServiceUptimeMs'] as num?;
    return SystemHealth(
      cpuPercent: (map['cpuPercent'] as num?)?.toDouble() ?? 0,
      cpuCores: whole('cpuCores'),
      ramTotalBytes: whole('ramTotalBytes'),
      ramAvailableBytes: whole('ramAvailableBytes'),
      ramLow: map['ramLow'] == true,
      storageTotalBytes: whole('storageTotalBytes'),
      storageAvailableBytes: whole('storageAvailableBytes'),
      bluetooth:
          BluetoothState.values.asNameMap()[map['bluetooth']] ??
          BluetoothState.missing,
      deviceUptime: Duration(milliseconds: whole('deviceUptimeMs')),
      androidServiceUptime: serviceMs == null
          ? null
          : Duration(milliseconds: serviceMs.toInt()),
    );
  }

  @override
  Future<BluetoothEnableOutcome> requestEnableBluetooth() async {
    final map = await _channel.invokeMapMethod<String, Object?>(
      'requestBluetoothEnable',
    );
    final outcome = map?['outcome'];
    if (outcome is! String) {
      throw StateError('No Bluetooth enable outcome.');
    }
    return BluetoothEnableOutcome.parse(outcome);
  }

  @override
  Future<bool> requestBluetoothConnect() async {
    final map = await _channel.invokeMapMethod<String, Object?>(
      'requestBluetoothConnect',
    );
    return map?['granted'] == true;
  }
}

final systemHealthGatewayProvider = Provider<SystemHealthGateway>(
  (ref) => const ChannelSystemHealthGateway(),
);
