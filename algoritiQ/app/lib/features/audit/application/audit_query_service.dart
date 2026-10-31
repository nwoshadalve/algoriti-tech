// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

/// Paginated, filterable audit log for the admin web UI ([audit-log.md]).
class AuditQueryService {
  AuditQueryService(this._db);

  final AppDatabase _db;

  static const pageSize = 25;

  Future<AuditLogPage> list(AuditLogQuery query) async {
    final entries = _db.auditEntries;
    final users = _db.users;

    var select = _db.select(entries);
    if (query.fromMs != null) {
      select = select..where((e) => e.at.isBiggerOrEqualValue(query.fromMs!));
    }
    if (query.toMs != null) {
      select = select..where((e) => e.at.isSmallerOrEqualValue(query.toMs!));
    }
    if (query.actionPrefix != null && query.actionPrefix!.isNotEmpty) {
      final prefix = query.actionPrefix!.replaceAll('%', '');
      select = select..where((e) => e.action.like('$prefix%'));
    }

    final allMatching =
        await (select..orderBy([(e) => OrderingTerm.desc(e.seq)])).get();
    final filtered = [
      for (final row in allMatching)
        if (query.outcome == null || _outcomeOf(row) == query.outcome) row,
    ];
    final total = filtered.length;
    final slice = filtered.skip(query.offset).take(pageSize).toList();

    final actorIds = slice.map((e) => e.actorId).whereType<String>().toSet();
    final actorRows = actorIds.isEmpty
        ? <UserRow>[]
        : await (_db.select(
            users,
          )..where((u) => u.id.isIn(actorIds.toList()))).get();
    final actors = {for (final u in actorRows) u.id: u};

    final items = [
      for (final row in slice)
        AuditLogEntryView(
          id: row.seq,
          occurredAt: DateTime.fromMillisecondsSinceEpoch(row.at, isUtc: true),
          action: row.action,
          category: _categoryOf(row),
          outcome: _outcomeOf(row),
          actorDisplayName: _actorName(row, actors),
          actorRole: actors[row.actorId]?.role,
          detail: row.detail,
          safeMetadata: _metadataOf(row),
        ),
    ];

    final next = query.offset + slice.length;
    return AuditLogPage(
      entries: items,
      total: total,
      nextOffset: next < total ? next : null,
    );
  }

  String _categoryOf(AuditEntryRow row) {
    final meta = _metadataOf(row);
    return meta['category'] as String? ?? _guessCategory(row.action);
  }

  String _outcomeOf(AuditEntryRow row) {
    final meta = _metadataOf(row);
    return meta['outcome'] as String? ?? 'success';
  }

  Map<String, Object?> _metadataOf(AuditEntryRow row) {
    final raw = row.detail;
    if (raw == null || raw.isEmpty || !raw.startsWith('{')) return {};
    try {
      return Map<String, Object?>.from(jsonDecode(raw) as Map);
    } on Object {
      return {};
    }
  }

  String? _actorName(AuditEntryRow row, Map<String, UserRow> actors) {
    final id = row.actorId;
    if (id == null) return null;
    final user = actors[id];
    if (user == null) return id;
    if (user.firstName.isNotEmpty) return user.firstName;
    return user.displayName;
  }

  String _guessCategory(String action) {
    if (action.startsWith('queue.')) return 'configuration';
    if (action.startsWith('auth.')) return 'authentication';
    return 'other';
  }
}

final class AuditLogQuery {
  const AuditLogQuery({
    this.offset = 0,
    this.fromMs,
    this.toMs,
    this.actionPrefix,
    this.outcome,
  });

  final int offset;
  final int? fromMs;
  final int? toMs;
  final String? actionPrefix;
  final String? outcome;
}

final class AuditLogEntryView {
  const AuditLogEntryView({
    required this.id,
    required this.occurredAt,
    required this.action,
    required this.category,
    required this.outcome,
    required this.actorDisplayName,
    required this.actorRole,
    required this.detail,
    required this.safeMetadata,
  });

  final int id;
  final DateTime occurredAt;
  final String action;
  final String category;
  final String outcome;
  final String? actorDisplayName;
  final String? actorRole;
  final String? detail;
  final Map<String, Object?> safeMetadata;
}

final class AuditLogPage {
  const AuditLogPage({
    required this.entries,
    required this.total,
    required this.nextOffset,
  });

  final List<AuditLogEntryView> entries;
  final int total;
  final int? nextOffset;
}

final auditQueryServiceProvider = Provider<AuditQueryService>(
  (ref) => AuditQueryService(ref.watch(appDatabaseProvider)),
);
