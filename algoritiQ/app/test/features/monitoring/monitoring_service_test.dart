// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/monitoring/application/monitoring_service.dart';
import 'package:algoritiq_app/features/monitoring/domain/health_snapshot.dart';
import 'package:algoritiq_app/features/connectivity/application/printer_controller.dart';
import 'package:algoritiq_app/features/connectivity/domain/printer.dart';
import 'package:algoritiq_app/platform/system_health_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/readiness_kit.dart';
import '../../support/system_health_fake.dart';

void main() {
  late FakeSystemHealth health;
  late FakeKeepAliveGateway keepAlive;
  final now = DateTime.utc(2026, 10, 29, 12);
  final apiStarted = now.subtract(const Duration(minutes: 30));

  MonitoringService build() => MonitoringService(
    health: health,
    keepAlive: keepAlive,
    clock: () => now,
    retryDelay: Duration.zero,
  );

  Future<HealthSnapshot> snapshot(
    MonitoringService monitoring, {
    int clients = 2,
  }) => monitoring.snapshot(apiStartedAt: apiStarted, liveClients: clients);

  ServiceHealth part(HealthSnapshot s, ServiceId id) =>
      s.services.firstWhere((x) => x.id == id);

  setUp(() {
    health = FakeSystemHealth();
    keepAlive = FakeKeepAliveGateway();
  });

  group('resources', () {
    test(
      'should report CPU, memory and storage as ok when they have room',
      () async {
        final s = await snapshot(build());

        expect(s.cpu.status, HealthStatus.ok);
        expect(s.ram.percent, 50);
        expect(s.ram.status, HealthStatus.ok);
        expect(s.storage.percent, 50);
        expect(s.storage.status, HealthStatus.ok);
        expect(s.bluetooth.status, HealthStatus.ok);
        expect(s.deviceUptime, const Duration(hours: 5));
      },
    );

    test('should warn about a busy CPU and nearly full storage', () async {
      health
        ..cpuPercent = 90
        ..storageAvailable = 10000;

      final s = await snapshot(build());

      expect(s.cpu.reason, HealthReason.cpuHigh);
      expect(s.storage.status, HealthStatus.warning);
      expect(s.storage.reason, HealthReason.storageLow);
    });

    test('should fail storage that is almost full', () async {
      health.storageAvailable = 2000;

      expect((await snapshot(build())).storage.status, HealthStatus.failed);
    });

    test('should say why Bluetooth is off or not there', () async {
      health.bluetooth = BluetoothState.off;
      final off = await snapshot(build());
      health.bluetooth = BluetoothState.missing;
      final missing = await snapshot(build());

      expect(off.bluetooth.status, HealthStatus.failed);
      expect(off.bluetooth.reason, HealthReason.bluetoothOff);
      expect(missing.bluetooth.status, HealthStatus.unavailable);
      expect(missing.bluetooth.reason, HealthReason.bluetoothMissing);
    });

    test('should say the reading failed when the tablet gives none', () async {
      health.fails = true;

      final s = await snapshot(build());

      expect(s.cpu.reason, HealthReason.readingFailed);
      expect(s.ram.status, HealthStatus.failed);
    });
  });

  group('services', () {
    test(
      'should show the API and the live channel with their uptime',
      () async {
        final s = await snapshot(build(), clients: 3);

        expect(part(s, ServiceId.api).status, HealthStatus.ok);
        expect(part(s, ServiceId.api).uptime, const Duration(minutes: 30));
        expect(part(s, ServiceId.websocket).clients, 3);
      },
    );

    test(
      'should show the Android service as running with its uptime',
      () async {
        final android = part(await snapshot(build()), ServiceId.androidService);

        expect(android.status, HealthStatus.ok);
        expect(android.uptime, const Duration(hours: 4));
      },
    );

    test('should fail the Android service when it is stopped', () async {
      keepAlive.serviceRunning = false;

      final android = part(await snapshot(build()), ServiceId.androidService);

      expect(android.status, HealthStatus.failed);
      expect(android.reason, HealthReason.serviceStopped);
      expect(android.retryable, isTrue);
    });

    test(
      'should warn when Android may pause the app to save battery',
      () async {
        keepAlive.batteryOptimizationIgnored = false;

        final android = part(await snapshot(build()), ServiceId.androidService);

        expect(android.status, HealthStatus.warning);
        expect(android.reason, HealthReason.batteryRestricted);
      },
    );

    test(
      'should show the printer and the TV app as unavailable with a reason',
      () async {
        final s = await snapshot(build());

        expect(part(s, ServiceId.printer).status, HealthStatus.unavailable);
        expect(part(s, ServiceId.printer).reason, HealthReason.printerNotSetUp);
        expect(part(s, ServiceId.tv).status, HealthStatus.unavailable);
        expect(part(s, ServiceId.tv).reason, HealthReason.tvNotConnected);
      },
    );

    test('should warn while the printer is connecting', () async {
      final device = PrinterDevice(name: 'POS', address: '00:11:22:33:44:55');
      final monitoring = MonitoringService(
        health: health,
        keepAlive: keepAlive,
        clock: () => now,
        printerState: () => PrinterState(
          loaded: true,
          link: PrinterLink.connecting,
          saved: device,
        ),
      );

      final printer = part(await snapshot(monitoring), ServiceId.printer);

      expect(printer.status, HealthStatus.warning);
      expect(printer.reason, HealthReason.printerConnecting);
    });

    test('should fail when the printer is disconnected', () async {
      final device = PrinterDevice(name: 'POS', address: '00:11:22:33:44:55');
      final monitoring = MonitoringService(
        health: health,
        keepAlive: keepAlive,
        clock: () => now,
        printerState: () => PrinterState(
          loaded: true,
          link: PrinterLink.disconnected,
          saved: device,
        ),
      );

      final printer = part(await snapshot(monitoring), ServiceId.printer);

      expect(printer.status, HealthStatus.failed);
      expect(printer.reason, HealthReason.printerDisconnected);
    });
  });

  group('retry', () {
    test(
      'should show the attempt while the TV app is tried again, then give up',
      () async {
        final monitoring = build();
        final running = monitoring.retry(ServiceId.tv);

        final tv = part(await snapshot(monitoring), ServiceId.tv);
        expect(tv.status, HealthStatus.retrying);
        expect(tv.retry!.attempt, 1);
        expect(tv.retry!.max, 3);

        await running;
        final after = part(await snapshot(monitoring), ServiceId.tv);
        expect(after.status, HealthStatus.unavailable);
        expect(after.retry, isNull);
      },
    );

    test('should start the Android service again and recover', () async {
      keepAlive
        ..serviceRunning = false
        ..onStart = () => keepAlive.serviceRunning = true;
      final monitoring = build();

      await monitoring.retry(ServiceId.androidService);

      final android = part(
        await snapshot(monitoring),
        ServiceId.androidService,
      );
      expect(android.status, HealthStatus.ok);
      expect(keepAlive.calls, ['startService']);
    });

    test(
      'should try three times when the service does not come back',
      () async {
        keepAlive.serviceRunning = false;

        await build().retry(ServiceId.androidService);

        expect(keepAlive.calls, [
          'startService',
          'startService',
          'startService',
        ]);
      },
    );

    test('should not retry the API or the live channel', () async {
      final monitoring = build();

      expect(monitoring.canRetry(ServiceId.api), isFalse);
      expect(monitoring.canRetry(ServiceId.websocket), isFalse);
      await monitoring.retry(ServiceId.api);
      expect(keepAlive.calls, isEmpty);
    });

    test('should ignore a second retry while one is running', () async {
      keepAlive.serviceRunning = false;
      final monitoring = build();

      final first = monitoring.retry(ServiceId.androidService);
      await monitoring.retry(ServiceId.androidService);
      await first;

      expect(keepAlive.calls.length, 3);
    });
  });
}
