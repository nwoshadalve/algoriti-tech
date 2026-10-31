// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import '../../../core/clock.dart';
import '../../../platform/keep_alive_gateway.dart';
import '../../../platform/system_health_gateway.dart';
import '../../connectivity/application/printer_controller.dart';
import '../../connectivity/application/test_token_service.dart';
import '../../connectivity/domain/printer.dart';
import '../domain/health_snapshot.dart';

/// What the admin monitoring page shows: the tablet's CPU, memory, storage and
/// Bluetooth, and the state, uptime and failure reason of each service. A part
/// that fails can be tried again; progress is kept here so every browser sees
/// the same retry.
///
/// The printer uses [PrinterController]; the TV app is not built yet.
class MonitoringService {
  MonitoringService({
    required SystemHealthGateway health,
    required KeepAliveGateway keepAlive,
    required Clock clock,
    PrinterState Function()? printerState,
    Future<bool> Function()? retryPrinter,
    Future<TestTokenOutcome> Function()? testPrinter,
    this.retryDelay = const Duration(seconds: 2),
    this.maxAttempts = 3,
  }) : _health = health,
       _keepAlive = keepAlive,
       _clock = clock,
       _printerState = printerState,
       _retryPrinter = retryPrinter,
       _testPrinter = testPrinter;

  final SystemHealthGateway _health;
  final KeepAliveGateway _keepAlive;
  final Clock _clock;
  final PrinterState Function()? _printerState;
  final Future<bool> Function()? _retryPrinter;
  final Future<TestTokenOutcome> Function()? _testPrinter;

  /// Wait between two tries.
  final Duration retryDelay;
  final int maxAttempts;

  static const _warnPercent = 85.0;
  static const _criticalPercent = 95.0;

  static const _retryable = {
    ServiceId.androidService,
    ServiceId.printer,
    ServiceId.tv,
  };

  static const _unreadable = ResourceHealth(
    status: HealthStatus.failed,
    reason: HealthReason.readingFailed,
  );

  final _retries = <ServiceId, RetryProgress>{};

  bool canRetry(ServiceId id) => _retryable.contains(id);

  bool isRetrying(ServiceId id) => _retries.containsKey(id);

  Future<HealthSnapshot> snapshot({
    required DateTime apiStartedAt,
    required int liveClients,
  }) async {
    final now = _clock().toUtc();
    final apiUptime = now.difference(apiStartedAt.toUtc());
    final system = await _readSystem();
    final keepAlive = await _readKeepAlive();
    return HealthSnapshot(
      generatedAt: now,
      deviceUptime: system?.deviceUptime ?? Duration.zero,
      cpu: _cpu(system),
      ram: _ram(system),
      storage: _storage(system),
      bluetooth: _bluetooth(system),
      services: [
        ServiceHealth(
          id: ServiceId.api,
          status: HealthStatus.ok,
          uptime: apiUptime,
        ),
        ServiceHealth(
          id: ServiceId.websocket,
          status: HealthStatus.ok,
          uptime: apiUptime,
          clients: liveClients,
        ),
        _androidService(system, keepAlive),
        _printerService(),
        _unavailable(ServiceId.tv, HealthReason.tvNotConnected),
      ],
    );
  }

  /// Asks Android to turn Bluetooth on; the person confirms on the tablet.
  Future<BluetoothEnableOutcome> enableBluetooth() =>
      _health.requestEnableBluetooth();

  /// Sends a sample token slip to the paired printer (admin monitoring).
  Future<TestTokenOutcome?> testPrinter() async {
    final run = _testPrinter;
    if (run == null) return null;
    return run();
  }

  Future<SystemHealth?> _readSystem() async {
    try {
      return await _health.read();
    } on Object {
      return null;
    }
  }

  Future<KeepAliveStatus?> _readKeepAlive() async {
    try {
      return await _keepAlive.status();
    } on Object {
      return null;
    }
  }

  ServiceHealth _androidService(SystemHealth? system, KeepAliveStatus? state) {
    final retry = _retries[ServiceId.androidService];
    if (retry != null) return _retrying(ServiceId.androidService, retry);
    if (state == null || !state.serviceRunning) {
      return ServiceHealth(
        id: ServiceId.androidService,
        status: HealthStatus.failed,
        reason: state == null
            ? HealthReason.readingFailed
            : HealthReason.serviceStopped,
        retryable: true,
      );
    }
    final restricted = !state.batteryOptimizationIgnored;
    return ServiceHealth(
      id: ServiceId.androidService,
      status: restricted ? HealthStatus.warning : HealthStatus.ok,
      reason: restricted ? HealthReason.batteryRestricted : null,
      uptime: system?.androidServiceUptime,
      retryable: true,
    );
  }

  ServiceHealth _printerService() {
    final retry = _retries[ServiceId.printer];
    if (retry != null) return _retrying(ServiceId.printer, retry);

    final read = _printerState;
    if (read == null) {
      return _unavailable(ServiceId.printer, HealthReason.printerNotSetUp);
    }
    final printer = read();
    if (!printer.loaded) {
      return const ServiceHealth(
        id: ServiceId.printer,
        status: HealthStatus.unavailable,
        reason: HealthReason.printerNotSetUp,
        retryable: false,
      );
    }
    if (printer.saved == null) {
      return const ServiceHealth(
        id: ServiceId.printer,
        status: HealthStatus.unavailable,
        reason: HealthReason.printerNotSetUp,
        retryable: false,
      );
    }
    switch (printer.link) {
      case PrinterLink.connected:
        return const ServiceHealth(
          id: ServiceId.printer,
          status: HealthStatus.ok,
          retryable: true,
        );
      case PrinterLink.connecting:
        return const ServiceHealth(
          id: ServiceId.printer,
          status: HealthStatus.warning,
          reason: HealthReason.printerConnecting,
          retryable: false,
        );
      case PrinterLink.disconnected:
        return const ServiceHealth(
          id: ServiceId.printer,
          status: HealthStatus.failed,
          reason: HealthReason.printerDisconnected,
          retryable: true,
        );
      case PrinterLink.notPaired:
        return const ServiceHealth(
          id: ServiceId.printer,
          status: HealthStatus.unavailable,
          reason: HealthReason.printerNotSetUp,
          retryable: false,
        );
      case PrinterLink.blocked:
        final reason = switch (printer.access) {
          BluetoothAccess.off => HealthReason.bluetoothOff,
          BluetoothAccess.denied => HealthReason.bluetoothDenied,
          BluetoothAccess.missing => HealthReason.bluetoothMissing,
          BluetoothAccess.ready => HealthReason.printerDisconnected,
        };
        return ServiceHealth(
          id: ServiceId.printer,
          status: reason == HealthReason.bluetoothMissing
              ? HealthStatus.unavailable
              : HealthStatus.failed,
          reason: reason,
          retryable: reason != HealthReason.bluetoothMissing,
        );
    }
  }

  ServiceHealth _unavailable(ServiceId id, HealthReason reason) {
    final retry = _retries[id];
    if (retry != null) return _retrying(id, retry);
    return ServiceHealth(
      id: id,
      status: HealthStatus.unavailable,
      reason: reason,
      retryable: true,
    );
  }

  ServiceHealth _retrying(ServiceId id, RetryProgress progress) =>
      ServiceHealth(
        id: id,
        status: HealthStatus.retrying,
        retry: progress,
        retryable: true,
      );

  ResourceHealth _cpu(SystemHealth? system) {
    if (system == null) return _unreadable;
    final busy = system.cpuPercent >= _warnPercent;
    return ResourceHealth(
      status: busy ? HealthStatus.warning : HealthStatus.ok,
      reason: busy ? HealthReason.cpuHigh : null,
      percent: system.cpuPercent,
      detail: '${system.cpuCores}',
    );
  }

  ResourceHealth _ram(SystemHealth? system) {
    if (system == null) return _unreadable;
    final total = system.ramTotalBytes;
    final used = total - system.ramAvailableBytes;
    final percent = total == 0 ? 0.0 : used * 100 / total;
    final high = system.ramLow || percent >= _criticalPercent;
    return ResourceHealth(
      status: high ? HealthStatus.warning : HealthStatus.ok,
      reason: high ? HealthReason.ramHigh : null,
      percent: percent,
      usedBytes: used,
      totalBytes: total,
    );
  }

  ResourceHealth _storage(SystemHealth? system) {
    if (system == null) return _unreadable;
    final total = system.storageTotalBytes;
    final used = total - system.storageAvailableBytes;
    final percent = total == 0 ? 0.0 : used * 100 / total;
    final status = percent >= _criticalPercent
        ? HealthStatus.failed
        : percent >= _warnPercent
        ? HealthStatus.warning
        : HealthStatus.ok;
    return ResourceHealth(
      status: status,
      reason: status == HealthStatus.ok ? null : HealthReason.storageLow,
      percent: percent,
      usedBytes: used,
      totalBytes: total,
    );
  }

  ResourceHealth _bluetooth(SystemHealth? system) {
    if (system == null) return _unreadable;
    return switch (system.bluetooth) {
      BluetoothState.on => const ResourceHealth(
        status: HealthStatus.ok,
        detail: 'on',
      ),
      BluetoothState.off => const ResourceHealth(
        status: HealthStatus.failed,
        reason: HealthReason.bluetoothOff,
        detail: 'off',
      ),
      BluetoothState.missing => const ResourceHealth(
        status: HealthStatus.unavailable,
        reason: HealthReason.bluetoothMissing,
      ),
      BluetoothState.denied => const ResourceHealth(
        status: HealthStatus.unavailable,
        reason: HealthReason.bluetoothDenied,
      ),
    };
  }

  /// Tries [id] again, up to [maxAttempts] times with [retryDelay] between,
  /// showing the attempt in [snapshot] meanwhile. Completes when it is over;
  /// the answer is in the next snapshot. Does nothing if [id] cannot be
  /// retried or a retry is already running.
  Future<void> retry(ServiceId id) async {
    if (!canRetry(id) || isRetrying(id)) return;
    try {
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        _retries[id] = RetryProgress(attempt, maxAttempts);
        if (await _probe(id)) return;
        if (attempt < maxAttempts) await Future<void>.delayed(retryDelay);
      }
    } finally {
      _retries.remove(id);
    }
  }

  /// One real try. The TV app has nothing to connect to yet.
  Future<bool> _probe(ServiceId id) async {
    if (id == ServiceId.printer) {
      final retry = _retryPrinter;
      if (retry == null) return false;
      try {
        return await retry();
      } on Object {
        return false;
      }
    }
    if (id != ServiceId.androidService) return false;
    try {
      await _keepAlive.startService();
      return (await _keepAlive.status()).serviceRunning;
    } on Object {
      return false;
    }
  }
}
