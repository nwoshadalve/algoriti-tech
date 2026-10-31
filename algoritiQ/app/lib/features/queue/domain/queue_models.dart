// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

/// Clinic-wide queue policy from [queue-configuration.md].
final class QueuePolicy {
  const QueuePolicy({
    required this.timeZone,
    required this.dayBoundary,
    required this.autoStart,
  });

  final String timeZone;
  final String dayBoundary;
  final bool autoStart;

  static const defaults = QueuePolicy(
    timeZone: 'Asia/Dhaka',
    dayBoundary: '03:00',
    autoStart: true,
  );
}

/// One queue type row (Regular, Report, Dressing, or custom).
final class QueueTypeConfig {
  const QueueTypeConfig({
    required this.id,
    required this.englishName,
    required this.bengaliName,
    required this.startNumber,
    required this.endNumber,
    required this.displayOrder,
    required this.enabled,
  });

  final String id;
  final String englishName;
  final String bengaliName;
  final int startNumber;
  final int endNumber;
  final int displayOrder;
  final bool enabled;

  int get capacity => endNumber - startNumber + 1;
}

/// Optional per-chamber override of clinic defaults.
final class ChamberQueueSettings {
  const ChamberQueueSettings({
    required this.useClinicDefaults,
    this.dayBoundaryOverride,
    this.autoStartOverride,
  });

  final bool useClinicDefaults;
  final String? dayBoundaryOverride;
  final bool? autoStartOverride;

  static const inherit = ChamberQueueSettings(useClinicDefaults: true);
}

enum QueueSessionStatus {
  notStarted('NOT_STARTED'),
  open('OPEN'),
  closing('CLOSING'),
  closed('CLOSED'),
  rolloverDue('ROLLOVER_DUE');

  const QueueSessionStatus(this.apiValue);
  final String apiValue;

  static QueueSessionStatus? parse(String raw) {
    for (final value in values) {
      if (value.apiValue == raw) return value;
    }
    return null;
  }
}

final class QueueSessionView {
  const QueueSessionView({
    required this.id,
    required this.chamberId,
    required this.businessDate,
    required this.status,
    required this.openedAt,
    this.openedByAccountId,
    this.closedAt,
    this.closedByAccountId,
    this.closeReason,
    required this.usage,
  });

  final String id;
  final String chamberId;
  final String businessDate;
  final QueueSessionStatus status;
  final DateTime openedAt;
  final String? openedByAccountId;
  final DateTime? closedAt;
  final String? closedByAccountId;
  final String? closeReason;
  final List<QueueTypeUsage> usage;
}

final class QueueTypeUsage {
  const QueueTypeUsage({
    required this.queueTypeId,
    required this.englishName,
    required this.bengaliName,
    required this.startNumber,
    required this.endNumber,
    required this.issuedCount,
    required this.nextNumber,
    required this.enabled,
  });

  final String queueTypeId;
  final String englishName;
  final String bengaliName;
  final int startNumber;
  final int endNumber;
  final int issuedCount;
  final int nextNumber;
  final bool enabled;

  int get capacity => endNumber - startNumber + 1;

  double get usedFraction => capacity == 0 ? 0 : issuedCount / capacity;
}
