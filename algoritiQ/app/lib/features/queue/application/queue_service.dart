// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';

import '../../../core/clock.dart';
import '../../../core/id_generator.dart';
import '../../access/domain/account.dart';
import '../../access/domain/account_repository.dart';
import '../data/drift_queue_repository.dart';
import '../domain/queue_models.dart';
import '../domain/queue_validation.dart';

enum QueueServiceProblem {
  forbidden,
  chamberNotFound,
  typeNotFound,
  validation,
  openSession,
  noOpenSession,
  reasonRequired,
  inheritClinicDefaults,
}

final class QueueServiceRefused implements Exception {
  const QueueServiceRefused(this.problem, {this.validation, this.code});

  final QueueServiceProblem problem;
  final Map<QueueTypeProblem, void>? validation;
  final String? code;
}

/// Admin queue configuration and session controls ([queue-configuration.md]).
class QueueService {
  QueueService({
    required DriftQueueRepository repository,
    required AccountRepository accounts,
    required Clock clock,
    required IdGenerator newId,
  }) : _repo = repository,
       _accounts = accounts,
       _clock = clock,
       _newId = newId;

  final DriftQueueRepository _repo;
  final AccountRepository _accounts;
  final Clock _clock;
  final IdGenerator _newId;

  Future<void> _requireAdmin(Account account) async {
    if (account.role != Role.admin) {
      throw const QueueServiceRefused(QueueServiceProblem.forbidden);
    }
  }

  Future<void> _audit(
    Account? actor,
    String action,
    Map<String, Object?> metadata,
  ) async {
    await _accounts.audit(
      at: _clock(),
      action: action,
      actorId: actor?.id,
      detail: jsonEncode(metadata),
    );
  }

  Future<({QueuePolicy policy, List<QueueTypeConfig> types})>
  loadClinicDefaults(Account admin) async {
    await _requireAdmin(admin);
    await _repo.ensureClinicDefaultsSeeded();
    final policy = await _repo.loadClinicPolicy();
    final types = await _repo.loadTypesForOwner(clinicOwnerKey);
    return (policy: policy, types: types);
  }

  Future<QueuePolicy> updateClinicPolicy(
    Account admin,
    QueuePolicy policy,
  ) async {
    await _requireAdmin(admin);
    final before = await _repo.loadClinicPolicy();
    await _repo.saveClinicPolicy(policy);
    await _audit(admin, 'queue.policy.updated', {
      'scope': 'clinic',
      'before': {
        'timeZone': before.timeZone,
        'dayBoundary': before.dayBoundary,
        'autoStart': before.autoStart,
      },
      'after': {
        'timeZone': policy.timeZone,
        'dayBoundary': policy.dayBoundary,
        'autoStart': policy.autoStart,
      },
      'outcome': 'success',
      'category': 'configuration',
      'sourceClient': 'web',
    });
    return policy;
  }

  Future<ChamberQueueSettings> updateChamberDayBoundary(
    Account admin,
    String chamberId,
    String dayBoundary,
  ) async {
    await _requireAdmin(admin);
    final settings = await _repo.loadChamberSettings(chamberId);
    final updated = ChamberQueueSettings(
      useClinicDefaults: settings.useClinicDefaults,
      dayBoundaryOverride: dayBoundary,
      autoStartOverride: settings.autoStartOverride,
    );
    await _repo.saveChamberSettings(chamberId, updated);
    await _audit(admin, 'queue.policy.updated', {
      'scope': 'chamber',
      'chamberId': chamberId,
      'after': {'dayBoundary': dayBoundary},
      'outcome': 'success',
      'category': 'configuration',
      'sourceClient': 'web',
    });
    return updated;
  }

  Future<List<QueueTypeConfig>> replaceClinicTypes(
    Account admin,
    List<QueueTypeConfig> types,
  ) async {
    await _requireAdmin(admin);
    return _replaceTypesForOwner(
      admin,
      ownerKey: clinicOwnerKey,
      types: types,
      hasOpenSession: await _repo.hasOpenSessionForOwner(clinicOwnerKey),
      auditScope: 'clinic',
    );
  }

  Future<ChamberQueueSettings> customizeChamberQueue(
    Account admin,
    String chamberId,
  ) async {
    await _requireAdmin(admin);
    await _requireChamber(chamberId);
    await _copyClinicTypesIntoChamberOverride(admin, chamberId);
    return _repo.loadChamberSettings(chamberId);
  }

  Future<ChamberQueueSettings> clearChamberQueueOverride(
    Account admin,
    String chamberId,
  ) async {
    await _requireAdmin(admin);
    await _requireChamber(chamberId);
    if (await _repo.openSessionForChamber(chamberId) != null) {
      throw const QueueServiceRefused(QueueServiceProblem.openSession);
    }
    final settings = await _repo.loadChamberSettings(chamberId);
    final existing = await _repo.loadTypesForOwner(chamberId);
    for (final type in existing) {
      await _repo.deleteType(chamberId, type.id);
    }
    final reset = ChamberQueueSettings(
      useClinicDefaults: true,
      dayBoundaryOverride: settings.dayBoundaryOverride,
      autoStartOverride: settings.autoStartOverride,
    );
    await _repo.saveChamberSettings(chamberId, reset);
    await _audit(admin, 'queue.chamber.inherit_restored', {
      'chamberId': chamberId,
      'outcome': 'success',
      'category': 'configuration',
    });
    return reset;
  }

  Future<({ChamberQueueSettings settings, List<QueueTypeConfig> types})>
  replaceChamberTypes(
    Account admin,
    String chamberId,
    List<QueueTypeConfig> types,
  ) async {
    await _requireAdmin(admin);
    await _requireChamber(chamberId);
    var settings = await _repo.loadChamberSettings(chamberId);
    if (settings.useClinicDefaults) {
      await _copyClinicTypesIntoChamberOverride(admin, chamberId);
      settings = await _repo.loadChamberSettings(chamberId);
    }
    final saved = await _replaceTypesForOwner(
      admin,
      ownerKey: chamberId,
      types: types,
      hasOpenSession: await _repo.openSessionForChamber(chamberId) != null,
      auditScope: 'chamber',
      chamberId: chamberId,
    );
    return (settings: settings, types: saved);
  }

  Future<void> _requireChamber(String chamberId) async {
    if (!await _repo.chamberExists(chamberId)) {
      throw const QueueServiceRefused(QueueServiceProblem.chamberNotFound);
    }
  }

  Future<void> _copyClinicTypesIntoChamberOverride(
    Account admin,
    String chamberId,
  ) async {
    final settings = await _repo.loadChamberSettings(chamberId);
    final clinicTypes = await _repo.loadTypesForOwner(clinicOwnerKey);
    for (final type in clinicTypes) {
      await _repo.upsertType(ownerKey: chamberId, type: type);
    }
    await _repo.saveChamberSettings(
      chamberId,
      ChamberQueueSettings(
        useClinicDefaults: false,
        dayBoundaryOverride: settings.dayBoundaryOverride,
        autoStartOverride: settings.autoStartOverride,
      ),
    );
    await _audit(admin, 'queue.chamber.customized', {
      'chamberId': chamberId,
      'outcome': 'success',
      'category': 'configuration',
    });
  }

  Future<List<QueueTypeConfig>> _replaceTypesForOwner(
    Account admin, {
    required String ownerKey,
    required List<QueueTypeConfig> types,
    required bool hasOpenSession,
    required String auditScope,
    String? chamberId,
  }) async {
    final existing = await _repo.loadTypesForOwner(ownerKey);
    final existingById = {for (final row in existing) row.id: row};

    for (final type in types) {
      final previous = existingById[type.id];
      final problems = validateQueueType(
        englishName: type.englishName,
        bengaliName: type.bengaliName,
        startNumber: type.startNumber,
        endNumber: type.endNumber,
        siblings: types.where((t) => t.id != type.id).toList(),
        editingId: type.id,
        hasOpenSession: hasOpenSession,
        sessionBlocksChange: _sessionBlocksTypeChange(previous, type),
      );
      if (problems.isNotEmpty) {
        throw QueueServiceRefused(
          QueueServiceProblem.validation,
          validation: problems,
        );
      }
    }
    for (final old in existing) {
      if (!types.any((t) => t.id == old.id)) {
        if (hasOpenSession) {
          throw const QueueServiceRefused(QueueServiceProblem.openSession);
        }
        await _repo.deleteType(ownerKey, old.id);
        await _audit(admin, 'queue.type.disabled', {
          'queueTypeId': old.id,
          if (chamberId != null) 'chamberId': chamberId,
          'scope': auditScope,
          'outcome': 'success',
          'category': 'configuration',
        });
      }
    }
    for (final type in types) {
      await _repo.upsertType(ownerKey: ownerKey, type: type);
      await _audit(admin, 'queue.type.updated', {
        'queueTypeId': type.id,
        if (chamberId != null) 'chamberId': chamberId,
        'scope': auditScope,
        'after': {
          'englishName': type.englishName,
          'bengaliName': type.bengaliName,
          'startNumber': type.startNumber,
          'endNumber': type.endNumber,
          'displayOrder': type.displayOrder,
          'enabled': type.enabled,
        },
        'outcome': 'success',
        'category': 'configuration',
      });
    }
    return types;
  }

  bool _sessionBlocksTypeChange(
    QueueTypeConfig? previous,
    QueueTypeConfig next,
  ) {
    if (previous == null) return true;
    if (previous.startNumber != next.startNumber ||
        previous.endNumber != next.endNumber) {
      return true;
    }
    if (previous.enabled != next.enabled) return true;
    return false;
  }

  Future<
    ({
      ChamberQueueSettings settings,
      QueuePolicy effectivePolicy,
      List<QueueTypeConfig> types,
      QueueSessionView? session,
    })
  >
  loadChamberConfiguration(Account admin, String chamberId) async {
    await _requireAdmin(admin);
    final settings = await _repo.loadChamberSettings(chamberId);
    final clinicPolicy = await _repo.loadClinicPolicy();
    final owner = await _repo.effectiveOwnerKey(chamberId);
    final types = await _repo.loadTypesForOwner(owner);
    final effective = QueuePolicy(
      timeZone: clinicPolicy.timeZone,
      dayBoundary: settings.dayBoundaryOverride ?? clinicPolicy.dayBoundary,
      autoStart: settings.autoStartOverride ?? clinicPolicy.autoStart,
    );
    final session = await _sessionView(chamberId, types);
    return (
      settings: settings,
      effectivePolicy: effective,
      types: types,
      session: session,
    );
  }

  Future<QueueSessionView?> startSession(
    Account admin,
    String chamberId,
  ) async {
    await _requireAdmin(admin);
    if (await _repo.openSessionForChamber(chamberId) != null) {
      throw const QueueServiceRefused(QueueServiceProblem.openSession);
    }
    final owner = await _repo.effectiveOwnerKey(chamberId);
    final types = await _repo.loadTypesForOwner(owner);
    final settings = await _repo.loadChamberSettings(chamberId);
    final clinicPolicy = await _repo.loadClinicPolicy();
    final now = _clock();
    final id = _newId();
    final businessDate = now.toIso8601String().substring(0, 10);
    final snapshot = {
      'policy': {
        'timeZone': clinicPolicy.timeZone,
        'dayBoundary': settings.dayBoundaryOverride ?? clinicPolicy.dayBoundary,
        'autoStart': settings.autoStartOverride ?? clinicPolicy.autoStart,
      },
      'types': [
        for (final t in types)
          {
            'id': t.id,
            'englishName': t.englishName,
            'bengaliName': t.bengaliName,
            'startNumber': t.startNumber,
            'endNumber': t.endNumber,
            'displayOrder': t.displayOrder,
            'enabled': t.enabled,
          },
      ],
    };
    await _repo.insertSession(
      id: id,
      chamberId: chamberId,
      businessDate: businessDate,
      status: QueueSessionStatus.open.apiValue,
      openedAt: now,
      openedByAccountId: admin.id,
      snapshot: snapshot,
      types: types,
    );
    await _audit(admin, 'queue.session.started', {
      'chamberId': chamberId,
      'sessionId': id,
      'businessDate': businessDate,
      'outcome': 'success',
      'category': 'session',
    });
    return _sessionView(chamberId, types);
  }

  Future<QueueSessionView?> closeSession(
    Account admin,
    String chamberId,
  ) async {
    await _requireAdmin(admin);
    final open = await _repo.openSessionForChamber(chamberId);
    if (open == null) {
      throw const QueueServiceRefused(QueueServiceProblem.noOpenSession);
    }
    await _repo.closeSession(
      sessionId: open.id,
      closedAt: _clock(),
      closedByAccountId: admin.id,
    );
    await _audit(admin, 'queue.session.closed', {
      'chamberId': chamberId,
      'sessionId': open.id,
      'outcome': 'success',
      'category': 'session',
    });
    return null;
  }

  Future<void> forceCloseSession(
    Account admin,
    String chamberId,
    String reason,
  ) async {
    await _requireAdmin(admin);
    if (reason.trim().isEmpty) {
      throw const QueueServiceRefused(QueueServiceProblem.reasonRequired);
    }
    final open = await _repo.openSessionForChamber(chamberId);
    if (open == null) {
      throw const QueueServiceRefused(QueueServiceProblem.noOpenSession);
    }
    await _repo.closeSession(
      sessionId: open.id,
      closedAt: _clock(),
      closedByAccountId: admin.id,
      reason: reason.trim(),
    );
    await _audit(admin, 'queue.session.force_closed', {
      'chamberId': chamberId,
      'sessionId': open.id,
      'reason': reason.trim(),
      'cancelledTokenCount': 0,
      'outcome': 'success',
      'category': 'session',
    });
  }

  Future<QueueSessionView?> _sessionView(
    String chamberId,
    List<QueueTypeConfig> types,
  ) async {
    final open = await _repo.openSessionForChamber(chamberId);
    if (open == null) return null;
    final counters = await _repo.countersForSession(open.id);
    final byId = {for (final c in counters) c.queueTypeId: c};
    final usage = <QueueTypeUsage>[];
    for (final type in types) {
      final counter = byId[type.id];
      usage.add(
        QueueTypeUsage(
          queueTypeId: type.id,
          englishName: type.englishName,
          bengaliName: type.bengaliName,
          startNumber: type.startNumber,
          endNumber: type.endNumber,
          issuedCount: counter?.issuedCount ?? 0,
          nextNumber: counter?.nextNumber ?? type.startNumber,
          enabled: type.enabled,
        ),
      );
    }
    return QueueSessionView(
      id: open.id,
      chamberId: open.chamberId,
      businessDate: open.businessDate,
      status: QueueSessionStatus.parse(open.status) ?? QueueSessionStatus.open,
      openedAt: DateTime.fromMillisecondsSinceEpoch(open.openedAt, isUtc: true),
      openedByAccountId: open.openedByAccountId,
      closedAt: open.closedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(open.closedAt!, isUtc: true),
      closedByAccountId: open.closedByAccountId,
      closeReason: open.closeReason,
      usage: usage,
    );
  }
}
