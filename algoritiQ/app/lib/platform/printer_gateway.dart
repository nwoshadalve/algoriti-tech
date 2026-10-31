// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/connectivity/domain/printer.dart';

/// Typed wrapper over `PrinterChannel.kt`: Bluetooth Classic SPP, raw ESC/POS.
/// Pairing and permission requests open Android's own dialogs; nothing is
/// done silently.
abstract interface class PrinterGateway {
  Future<BluetoothAccess> access();

  /// Shows the Bluetooth permission dialog (Android 12+). Returns the new state.
  Future<BluetoothAccess> requestAccess();

  /// Opens Android's "turn Bluetooth on" dialog.
  Future<void> requestEnable();

  /// Printers already paired with the tablet (any Bluetooth device whose class
  /// says printer, else every paired device so a mis-classed model still shows).
  Future<List<PrinterDevice>> paired();

  /// Starts a scan; devices arrive on [events] until [PrinterScanEnded].
  Future<void> startScan();

  Future<void> stopScan();

  /// Asks Android to pair (it shows its own PIN dialog when needed).
  Future<PairOutcome> pair(String address);

  Future<ConnectOutcome> connect(String address);

  Future<void> disconnect();

  /// Sends a finished print job (ESC/POS bytes) and says how it went.
  Future<PrintOutcome> print(Uint8List job);

  Stream<PrinterEvent> get events;
}

final class ChannelPrinterGateway implements PrinterGateway {
  ChannelPrinterGateway();

  static const _channel = MethodChannel('tech.algoriti.algoritiq/printer');
  static const _events = EventChannel('tech.algoriti.algoritiq/printer/events');

  late final Stream<PrinterEvent> _stream = _events
      .receiveBroadcastStream()
      .map(_parseEvent)
      .where((e) => e != null)
      .cast<PrinterEvent>()
      .asBroadcastStream();

  @override
  Stream<PrinterEvent> get events => _stream;

  static BluetoothAccess _access(Object? code) => switch (code) {
    'ready' => BluetoothAccess.ready,
    'off' => BluetoothAccess.off,
    'denied' => BluetoothAccess.denied,
    _ => BluetoothAccess.missing,
  };

  static PrinterDevice? _device(Object? raw) {
    if (raw is! Map) return null;
    final address = raw['address'];
    if (address is! String) return null;
    final name = raw['name'];
    return PrinterDevice(
      name: name is String && name.isNotEmpty ? name : address,
      address: address,
    );
  }

  static PrinterEvent? _parseEvent(Object? raw) {
    if (raw is! Map) return null;
    switch (raw['type']) {
      case 'link':
        return PrinterLinkChanged(connected: raw['connected'] == true);
      case 'access':
        return BluetoothAccessChanged(_access(raw['access']));
      case 'found':
        final device = _device(raw);
        return device == null ? null : PrinterFound(device);
      case 'scanEnded':
        return const PrinterScanEnded();
    }
    return null;
  }

  Future<String?> _string(String method, [Object? args]) =>
      _channel.invokeMethod<String>(method, args);

  @override
  Future<BluetoothAccess> access() async => _access(await _string('access'));

  @override
  Future<BluetoothAccess> requestAccess() async =>
      _access(await _string('requestAccess'));

  @override
  Future<void> requestEnable() => _channel.invokeMethod<void>('requestEnable');

  @override
  Future<List<PrinterDevice>> paired() async {
    final raw = await _channel.invokeListMethod<Object?>('paired') ?? const [];
    return [for (final item in raw) ?_device(item)];
  }

  @override
  Future<void> startScan() => _channel.invokeMethod<void>('startScan');

  @override
  Future<void> stopScan() => _channel.invokeMethod<void>('stopScan');

  @override
  Future<PairOutcome> pair(String address) async =>
      switch (await _string('pair', {'address': address})) {
        'paired' => PairOutcome.paired,
        'rejected' => PairOutcome.rejected,
        _ => PairOutcome.failed,
      };

  @override
  Future<ConnectOutcome> connect(String address) async =>
      switch (await _string('connect', {'address': address})) {
        'connected' => ConnectOutcome.connected,
        'off' => ConnectOutcome.bluetoothOff,
        'denied' => ConnectOutcome.denied,
        _ => ConnectOutcome.failed,
      };

  @override
  Future<void> disconnect() => _channel.invokeMethod<void>('disconnect');

  @override
  Future<PrintOutcome> print(Uint8List job) async =>
      switch (await _string('print', {'bytes': job})) {
        'printed' => PrintOutcome.printed,
        'not_connected' => PrintOutcome.notConnected,
        _ => PrintOutcome.failed,
      };
}

final printerGatewayProvider = Provider<PrinterGateway>(
  (ref) => ChannelPrinterGateway(),
);
