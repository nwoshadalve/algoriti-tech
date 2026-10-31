// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

import 'package:algoritiq_app/features/connectivity/application/printer_controller.dart';
import 'package:algoritiq_app/features/connectivity/domain/printer.dart';
import 'package:algoritiq_app/platform/printer_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/printer_fake.dart';

void main() {
  late FakePrinterGateway gateway;
  late MemoryPrinterStore store;

  ProviderContainer build() {
    final container = ProviderContainer(
      overrides: [
        printerGatewayProvider.overrideWithValue(gateway),
        printerStoreProvider.overrideWithValue(store),
        printerRetryDelaysProvider.overrideWithValue(const [
          Duration(milliseconds: 10),
          Duration(milliseconds: 20),
        ]),
      ],
    );
    addTearDown(container.dispose);
    container.listen(printerControllerProvider, (_, _) {});
    return container;
  }

  PrinterState stateOf(ProviderContainer c) =>
      c.read(printerControllerProvider);

  PrinterController controller(ProviderContainer c) =>
      c.read(printerControllerProvider.notifier);

  Future<void> until(
    ProviderContainer c,
    bool Function(PrinterState) test,
  ) async {
    for (var i = 0; i < 400; i++) {
      if (test(stateOf(c))) return;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    fail('Condition not reached; link is ${stateOf(c).link}');
  }

  setUp(() {
    gateway = FakePrinterGateway();
    store = MemoryPrinterStore();
  });

  test('should ask to set a printer up when none was ever paired', () async {
    final c = build();

    await until(c, (s) => s.loaded);

    expect(stateOf(c).link, PrinterLink.notPaired);
    expect(gateway.connectCalls, 0);
  });

  test('should connect by itself to the saved printer on start', () async {
    store.device = rongta;
    final c = build();

    await until(c, (s) => s.link == PrinterLink.connected);

    expect(stateOf(c).saved, rongta);
  });

  test('should keep retrying until the printer is switched on', () async {
    store.device = rongta;
    gateway.connectResults = [
      ConnectOutcome.failed,
      ConnectOutcome.failed,
      ConnectOutcome.connected,
    ];
    final c = build();

    await until(c, (s) => s.link == PrinterLink.connected);

    expect(gateway.connectCalls, 3);
    expect(stateOf(c).attempt, 0);
    expect(stateOf(c).nextTryAt, isNull);
  });

  test('should announce the next try while it waits', () async {
    store.device = rongta;
    gateway.connectResults = [ConnectOutcome.failed];
    final c = build();

    await until(c, (s) => s.nextTryAt != null);

    expect(stateOf(c).link, PrinterLink.disconnected);
    expect(stateOf(c).attempt, greaterThanOrEqualTo(1));
  });

  test('should reconnect by itself after the link drops', () async {
    store.device = rongta;
    final c = build();
    await until(c, (s) => s.link == PrinterLink.connected);

    gateway.eventSink.add(const PrinterLinkChanged(connected: false));
    await until(c, (s) => s.link != PrinterLink.connected);
    await until(c, (s) => s.link == PrinterLink.connected);

    expect(gateway.connectCalls, 2);
  });

  test(
    'should not try while Bluetooth is off, and try when it is on',
    () async {
      store.device = rongta;
      gateway.accessNow = BluetoothAccess.off;
      final c = build();

      await until(c, (s) => s.loaded);
      expect(stateOf(c).link, PrinterLink.blocked);
      expect(gateway.connectCalls, 0);

      gateway.eventSink.add(
        const BluetoothAccessChanged(BluetoothAccess.ready),
      );
      await until(c, (s) => s.link == PrinterLink.connected);
    },
  );

  test('should pair, remember and connect a new printer', () async {
    gateway.nearby = [rongta];
    final c = build();
    await until(c, (s) => s.loaded);

    await controller(c).scan();
    await until(c, (s) => s.found.contains(rongta));
    final outcome = await controller(c).choose(rongta);

    expect(outcome, ChooseOutcome.connected);
    expect(store.device, rongta);
    expect(stateOf(c).link, PrinterLink.connected);
  });

  test('should not pair again with a printer that is already paired', () async {
    gateway.bonded = [rongta];
    gateway.pairResult = PairOutcome.failed;
    final c = build();
    await until(c, (s) => s.loaded);

    final outcome = await controller(c).choose(rongta);

    expect(outcome, ChooseOutcome.connected);
  });

  test('should not remember a printer whose pairing was rejected', () async {
    gateway.nearby = [rongta];
    gateway.pairResult = PairOutcome.rejected;
    final c = build();
    await until(c, (s) => s.loaded);

    final outcome = await controller(c).choose(rongta);

    expect(outcome, ChooseOutcome.rejected);
    expect(store.device, isNull);
    expect(stateOf(c).link, PrinterLink.notPaired);
    expect(stateOf(c).working, isFalse);
  });

  test('should go back to reconnecting when a print finds no link', () async {
    store.device = rongta;
    final c = build();
    await until(c, (s) => s.link == PrinterLink.connected);

    gateway.printResult = PrintOutcome.notConnected;
    final outcome = await controller(c).print(Uint8List.fromList([1]));

    expect(outcome, PrintOutcome.notConnected);
    await until(c, (s) => s.link == PrinterLink.connected);
  });

  test('should hand the print job to the printer untouched', () async {
    store.device = rongta;
    final c = build();
    await until(c, (s) => s.link == PrinterLink.connected);

    final outcome = await controller(c).print(Uint8List.fromList([7, 8, 9]));

    expect(outcome, PrintOutcome.printed);
    expect(gateway.printed.single, [7, 8, 9]);
    expect(stateOf(c).working, isFalse);
  });
}
