// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:typed_data';

import 'package:algoritiq_app/features/connectivity/domain/printer.dart';
import 'package:algoritiq_app/features/connectivity/domain/printer_store.dart';
import 'package:algoritiq_app/platform/printer_gateway.dart';

const rongta = PrinterDevice(name: 'RPP02C', address: 'AA:BB:CC:00:11:22');

/// A printer gateway the test drives by hand.
class FakePrinterGateway implements PrinterGateway {
  BluetoothAccess accessNow = BluetoothAccess.ready;
  List<PrinterDevice> bonded = [];
  List<PrinterDevice> nearby = [];
  PairOutcome pairResult = PairOutcome.paired;
  PrintOutcome printResult = PrintOutcome.printed;
  final printed = <Uint8List>[];

  /// Outcomes handed out one per connect call; the last repeats.
  List<ConnectOutcome> connectResults = [ConnectOutcome.connected];
  int connectCalls = 0;
  int disconnectCalls = 0;
  int scans = 0;
  final eventSink = StreamController<PrinterEvent>.broadcast();

  @override
  Stream<PrinterEvent> get events => eventSink.stream;

  @override
  Future<BluetoothAccess> access() async => accessNow;

  @override
  Future<BluetoothAccess> requestAccess() async => accessNow;

  @override
  Future<void> requestEnable() async {}

  @override
  Future<List<PrinterDevice>> paired() async => bonded;

  @override
  Future<void> startScan() async {
    scans++;
    for (final device in nearby) {
      eventSink.add(PrinterFound(device));
    }
    eventSink.add(const PrinterScanEnded());
  }

  @override
  Future<void> stopScan() async {}

  @override
  Future<PairOutcome> pair(String address) async {
    if (pairResult == PairOutcome.paired) {
      bonded = [...bonded, ...nearby.where((d) => d.address == address)];
    }
    return pairResult;
  }

  @override
  Future<ConnectOutcome> connect(String address) async {
    final index = connectCalls < connectResults.length
        ? connectCalls
        : connectResults.length - 1;
    connectCalls++;
    return connectResults[index];
  }

  @override
  Future<void> disconnect() async => disconnectCalls++;

  @override
  Future<PrintOutcome> print(Uint8List job) async {
    if (printResult == PrintOutcome.printed) printed.add(job);
    return printResult;
  }
}

class MemoryPrinterStore implements PrinterStore {
  MemoryPrinterStore([this.device]);

  PrinterDevice? device;

  @override
  Future<PrinterDevice?> read() async => device;

  @override
  Future<void> write(PrinterDevice value) async => device = value;

  @override
  Future<void> clear() async => device = null;
}
