// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
/// How a part of the system is doing.
enum HealthStatus { ok, warning, failed, unavailable, retrying }

/// Why something is not fine. Codes only: the web app words them for the
/// person ([code] is what the API sends).
enum HealthReason {
  serviceStopped('service_stopped'),
  batteryRestricted('battery_restricted'),
  printerNotSetUp('printer_not_set_up'),
  tvNotConnected('tv_not_connected'),
  bluetoothOff('bluetooth_off'),
  bluetoothMissing('bluetooth_missing'),
  bluetoothDenied('bluetooth_denied'),
  cpuHigh('cpu_high'),
  ramHigh('ram_high'),
  storageLow('storage_low'),
  readingFailed('reading_failed');

  const HealthReason(this.code);

  final String code;
}

/// The parts the admin can ask the tablet to try again.
enum ServiceId {
  api('api'),
  websocket('websocket'),
  androidService('androidService'),
  printer('printer'),
  tv('tv');

  const ServiceId(this.code);

  final String code;

  static ServiceId? fromCode(String code) {
    for (final id in values) {
      if (id.code == code) return id;
    }
    return null;
  }
}

/// A retry in progress: attempt [attempt] of [max].
final class RetryProgress {
  const RetryProgress(this.attempt, this.max);

  final int attempt;
  final int max;
}

final class ServiceHealth {
  const ServiceHealth({
    required this.id,
    required this.status,
    this.reason,
    this.uptime,
    this.retry,
    this.retryable = false,
    this.clients,
  });

  final ServiceId id;
  final HealthStatus status;
  final HealthReason? reason;
  final Duration? uptime;
  final RetryProgress? retry;

  /// The admin may ask for another try.
  final bool retryable;

  /// Connected clients (the live channel only).
  final int? clients;
}

/// CPU, memory, storage or Bluetooth.
final class ResourceHealth {
  const ResourceHealth({
    required this.status,
    this.reason,
    this.percent,
    this.usedBytes,
    this.totalBytes,
    this.detail,
  });

  final HealthStatus status;
  final HealthReason? reason;

  /// 0-100 for CPU, memory and storage.
  final double? percent;
  final int? usedBytes;
  final int? totalBytes;

  /// `on` / `off` / ... for Bluetooth; the core count for the CPU.
  final String? detail;
}

final class HealthSnapshot {
  const HealthSnapshot({
    required this.generatedAt,
    required this.deviceUptime,
    required this.cpu,
    required this.ram,
    required this.storage,
    required this.bluetooth,
    required this.services,
  });

  final DateTime generatedAt;
  final Duration deviceUptime;
  final ResourceHealth cpu;
  final ResourceHealth ram;
  final ResourceHealth storage;
  final ResourceHealth bluetooth;
  final List<ServiceHealth> services;
}
