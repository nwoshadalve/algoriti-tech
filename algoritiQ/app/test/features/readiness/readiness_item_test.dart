// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/readiness/domain/readiness_item.dart';
import 'package:algoritiq_app/platform/system_health_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/readiness_kit.dart';

void main() {
  Future<Map<ReadinessKind, ReadinessItem>> checklist(
    FakeKeepAliveGateway gateway, {
    BluetoothState bluetooth = BluetoothState.on,
  }) async {
    final items = evaluateReadiness(await gateway.status(), bluetooth);
    return {for (final item in items) item.kind: item};
  }

  test('should call everything done on a well set up tablet', () async {
    final items = await checklist(FakeKeepAliveGateway());

    expect(items.values.every((item) => item.isDone), isTrue);
  });

  test('should require every checklist item before continuing', () async {
    final items = await checklist(FakeKeepAliveGateway());

    expect(items, hasLength(4));
    expect(items.values.where((i) => i.isRequired).length, 4);
  });

  test('should flag battery optimisation as needed', () async {
    final items = await checklist(
      FakeKeepAliveGateway(batteryOptimizationIgnored: false),
    );

    expect(items[ReadinessKind.background]!.state, ReadinessState.needed);
  });

  test('should flag disabled notifications', () async {
    final items = await checklist(
      FakeKeepAliveGateway(notificationsGranted: false),
    );

    expect(items[ReadinessKind.notifications]!.state, ReadinessState.needed);
  });

  test('should flag missing Bluetooth permission', () async {
    final items = await checklist(
      FakeKeepAliveGateway(),
      bluetooth: BluetoothState.denied,
    );

    expect(items[ReadinessKind.bluetooth]!.state, ReadinessState.needed);
  });

  test('should skip Bluetooth on tablets without hardware', () async {
    final items = await checklist(
      FakeKeepAliveGateway(),
      bluetooth: BluetoothState.missing,
    );

    expect(items[ReadinessKind.bluetooth]!.state, ReadinessState.done);
    expect(items[ReadinessKind.bluetooth]!.isRequired, isFalse);
  });

  test('should flag auto-start when the tablet reports it is off', () async {
    final items = await checklist(
      FakeKeepAliveGateway(autoStartGranted: false),
    );

    expect(items[ReadinessKind.autoStart]!.state, ReadinessState.needed);
  });

  test('should skip auto-start on makers that do not need it', () async {
    final items = await checklist(
      FakeKeepAliveGateway(autoStartRequired: false, autoStartGranted: false),
    );

    expect(items[ReadinessKind.autoStart]!.state, ReadinessState.done);
  });
}
