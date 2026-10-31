// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/readiness/application/readiness_controller.dart';
import 'package:algoritiq_app/platform/keep_alive_gateway.dart';
import 'package:algoritiq_app/platform/system_health_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/readiness_kit.dart';
import '../../support/system_health_fake.dart';

void main() {
  late FakeKeepAliveGateway gateway;
  late FakeSystemHealth health;
  late MemoryReadinessStore store;

  ProviderContainer open() {
    final container = ProviderContainer(
      overrides: [
        keepAliveGatewayProvider.overrideWithValue(gateway),
        systemHealthGatewayProvider.overrideWithValue(health),
        readinessStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    gateway = FakeKeepAliveGateway(batteryOptimizationIgnored: false);
    health = FakeSystemHealth();
    store = MemoryReadinessStore();
  });

  Future<ReadinessController> start(ProviderContainer container) async {
    await container.read(readinessControllerProvider.future);
    return container.read(readinessControllerProvider.notifier);
  }

  test(
    'should not start the background service until the guide is finished',
    () async {
      await start(open());

      expect(gateway.calls, isNot(contains('startService')));
    },
  );

  test('should report required items not done until allowed', () async {
    final container = open();
    await start(container);

    expect(
      container.read(readinessControllerProvider).value!.requiredDone,
      isFalse,
    );
  });

  test('should open the system question for background running', () async {
    final controller = await start(open());

    await controller.allowBackground();

    expect(gateway.calls, contains('requestIgnoreBatteryOptimizations'));
  });

  test('should see the change after the user comes back', () async {
    final container = open();
    final controller = await start(container);

    gateway
      ..batteryOptimizationIgnored = true
      ..autoStartGranted = true;
    await controller.refresh();

    expect(
      container.read(readinessControllerProvider).value!.requiredDone,
      isTrue,
    );
  });

  test('should show the notification dialog the first time', () async {
    gateway.notificationsGranted = false;
    final controller = await start(open());

    await controller.allowNotifications();

    expect(gateway.calls, contains('requestNotifications'));
    expect(gateway.calls, isNot(contains('openNotificationSettings')));
  });

  test('should open settings when the dialog was already refused', () async {
    gateway.notificationsGranted = false;
    store.asked = true;
    final controller = await start(open());

    await controller.allowNotifications();

    expect(gateway.calls, contains('openNotificationSettings'));
    expect(gateway.calls, isNot(contains('requestNotifications')));
  });

  test('should show the Bluetooth dialog the first time', () async {
    health.bluetooth = BluetoothState.denied;
    final controller = await start(open());

    await controller.allowBluetooth();

    expect(health.calls, contains('requestBluetoothConnect'));
    expect(gateway.calls, isNot(contains('openAppSettings')));
  });

  test('should open settings when Bluetooth was already refused', () async {
    health.bluetooth = BluetoothState.denied;
    store.bluetoothDialogAsked = true;
    final controller = await start(open());

    await controller.allowBluetooth();

    expect(gateway.calls, contains('openAppSettings'));
    expect(health.calls, isNot(contains('requestBluetoothConnect')));
  });

  test('should remember that the guide was seen', () async {
    final container = open();
    final controller = await start(container);
    gateway
      ..batteryOptimizationIgnored = true
      ..notificationsGranted = true
      ..autoStartGranted = true;
    await controller.refresh();

    await controller.acknowledge();

    expect(gateway.calls, contains('startService'));
    expect(
      container.read(readinessControllerProvider).value!.acknowledged,
      isTrue,
    );
  });

  test('should not acknowledge while required items are open', () async {
    final container = open();
    final controller = await start(container);

    await controller.acknowledge();

    expect(
      container.read(readinessControllerProvider).value!.acknowledged,
      isFalse,
    );
  });

  test(
    'should still show the checklist when the service cannot start',
    () async {
      final container = ProviderContainer(
        overrides: [
          keepAliveGatewayProvider.overrideWithValue(_RefusingGateway()),
          systemHealthGatewayProvider.overrideWithValue(FakeSystemHealth()),
          readinessStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);

      final report = await container.read(readinessControllerProvider.future);

      expect(report.items, isNotEmpty);
    },
  );
}

class _RefusingGateway extends FakeKeepAliveGateway {
  @override
  Future<void> startService() async => throw Exception('refused');
}
