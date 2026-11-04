// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// The tablet's SQLite database: the single source of truth ([Data & offline]
/// principles). Foreign keys and WAL are on.
///
/// Schema history:
/// - v1: doctors (name, specialty), chambers, app settings.
/// - v2: doctor details for the TV (degrees, designation, workplace,
///   registration number, photo).
/// - v3: every chamber belongs to a doctor (`doctor_id`, foreign key); chamber
///   phone number.
/// - v4: accounts (`users`), sign-in sessions and the audit trail.
/// - v5: account email on `users`.
/// - v6: profile fields and photo on `users`.
/// - v7: receptionist scope assignments.
/// - v8: PIN devices.
/// - v9: queue configuration, sessions and counters.
/// - v10: patients, queue tokens, print attempts, idempotent commands.
/// - v11: repair missing v10 tables when `user_version` was 10 without them.
/// - v12: repair queue tables / `enabled` column on older queue schemas.
/// - v13: composite primary key on queue types (`id`, `owner_key`).
/// - v14: one-time data cleanup on upgrade (removed orphan per-chamber type rows). Per-chamber queue overrides remain the product model; see `docs/features/queue-configuration.md` §4.
/// - v15: chamber patient ID prefix + sequence; canonical `clinic_patient_id` on patients.
/// - v16: paired TVs (`tv_devices`).
@DriftDatabase(
  tables: [
    Doctors,
    Chambers,
    AppSettings,
    Users,
    UserScopeAssignments,
    AuthSessions,
    AuditEntries,
    PinDevices,
    QueueTypes,
    QueueSessions,
    SessionQueueCounters,
    Patients,
    IdempotentCommands,
    QueueTokens,
    TokenPrintAttempts,
    TvDevices,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open()
    : super(
        driftDatabase(
          name: 'algoritiq',
          native: DriftNativeOptions(
            setup: (db) => db.execute('PRAGMA journal_mode = WAL'),
          ),
        ),
      );

  @override
  int get schemaVersion => 16;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(doctors, doctors.degrees);
        await m.addColumn(doctors, doctors.designation);
        await m.addColumn(doctors, doctors.workplace);
        await m.addColumn(doctors, doctors.registrationNumber);
        await m.addColumn(doctors, doctors.photoPath);
      }
      if (from < 3) {
        // Chambers saved before this belong to the (single) doctor on record.
        await m.alterTable(
          TableMigration(
            chambers,
            newColumns: [chambers.doctorId, chambers.phone],
            columnTransformer: {
              chambers.doctorId: const CustomExpression<String>(
                '(SELECT id FROM doctors LIMIT 1)',
              ),
            },
          ),
        );
      }
      if (from < 4) {
        await m.createTable(users);
        await m.createTable(authSessions);
        await m.createTable(auditEntries);
      }
      // A database older than v4 just got the users table in its current
      // shape above, so the columns added later are already there.
      if (from >= 4 && from < 5) {
        await m.addColumn(users, users.email);
      }
      if (from >= 4 && from < 6) {
        await m.addColumn(users, users.firstName);
        await m.addColumn(users, users.lastName);
        await m.addColumn(users, users.phone);
        await m.addColumn(users, users.photo);
        await m.addColumn(users, users.photoVersion);
      }
      if (from < 7) {
        await m.createTable(userScopeAssignments);
      }
      if (from < 8) {
        await m.createTable(pinDevices);
      }
      if (from < 9) {
        await m.createTable(queueTypes);
        await m.createTable(queueSessions);
        await m.createTable(sessionQueueCounters);
      }
      if (from < 10) {
        await m.createTable(patients);
        await m.createTable(idempotentCommands);
        await m.createTable(queueTokens);
        await m.createTable(tokenPrintAttempts);
      }
      if (from < 11) {
        await _ensureQueueBoardTables(m);
      }
      if (from < 12) {
        await _repairQueueSchema(m);
      }
      if (from < 13) {
        await _migrateQueueTypesCompositePrimaryKey(m);
      }
      if (from < 14) {
        await _revertChamberQueueCustomization(m);
      }
      if (from < 15) {
        await _migrateChamberPatientIdPrefixes(m);
      }
      if (from < 16) {
        await m.createTable(tvDevices);
      }
    },
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );

  /// Idempotent create for tablets where version reached 10 without board tables.
  Future<void> _ensureQueueBoardTables(Migrator m) async {
    for (final create in [
      () => m.createTable(patients),
      () => m.createTable(idempotentCommands),
      () => m.createTable(queueTokens),
      () => m.createTable(tokenPrintAttempts),
    ]) {
      try {
        await create();
      } on Object {
        // Table already present — normal path after v10 migration.
      }
    }
  }

  /// Ensures queue config tables and columns exist on real devices that skipped steps.
  Future<void> _repairQueueSchema(Migrator m) async {
    for (final create in [
      () => m.createTable(queueTypes),
      () => m.createTable(queueSessions),
      () => m.createTable(sessionQueueCounters),
    ]) {
      try {
        await create();
      } on Object {
        // Already created.
      }
    }
    try {
      await m.database.customStatement(
        'ALTER TABLE queue_types ADD COLUMN enabled INTEGER NOT NULL DEFAULT 1',
      );
    } on Object {
      // Column already present.
    }
  }

  /// Same logical type id (e.g. `regular`) may exist per owner (clinic vs chamber).
  Future<void> _migrateQueueTypesCompositePrimaryKey(Migrator m) async {
    final db = m.database;
    try {
      await db.customStatement('''
CREATE TABLE queue_types_pk (
  id TEXT NOT NULL,
  owner_key TEXT NOT NULL,
  english_name TEXT NOT NULL,
  bengali_name TEXT NOT NULL,
  start_number INTEGER NOT NULL,
  end_number INTEGER NOT NULL,
  display_order INTEGER NOT NULL,
  enabled INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0, 1)),
  PRIMARY KEY (id, owner_key)
)''');
      await db.customStatement('''
INSERT INTO queue_types_pk (
  id, owner_key, english_name, bengali_name,
  start_number, end_number, display_order, enabled
)
SELECT
  id, owner_key, english_name, bengali_name,
  start_number, end_number, display_order, enabled
FROM queue_types''');
      await db.customStatement('DROP TABLE queue_types');
      await db.customStatement(
        'ALTER TABLE queue_types_pk RENAME TO queue_types',
      );
    } on Object {
      // Fresh DB or already migrated — Drift createAll uses composite PK.
    }
  }

  /// Removes invalid per-chamber queue rows from an intermediate schema; does not change the chamber-wise product model.
  Future<void> _revertChamberQueueCustomization(Migrator m) async {
    final db = m.database;
    final hasSettings = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'app_settings'",
        )
        .get();
    if (hasSettings.isEmpty) return;

    final hasQueueTypes = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'queue_types'",
        )
        .get();
    if (hasQueueTypes.isNotEmpty) {
      await db.customStatement(
        "DELETE FROM queue_types WHERE owner_key != 'clinic'",
      );
    }
    final rows = await db
        .customSelect(
          "SELECT key, value FROM app_settings WHERE key LIKE 'queue.chamber.%'",
        )
        .get();
    for (final row in rows) {
      final key = row.read<String>('key');
      final raw = row.read<String>('value');
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) continue;
        if (decoded['useClinicDefaults'] != false) continue;
        await db.customStatement(
          'UPDATE app_settings SET value = ? WHERE key = ?',
          [
            jsonEncode({'useClinicDefaults': true}),
            key,
          ],
        );
      } on Object {
        // Leave malformed settings untouched.
      }
    }
  }

  /// Backfills chamber prefixes and canonical patient ids (see chamber-patient-id.md).
  Future<void> _migrateChamberPatientIdPrefixes(Migrator m) async {
    final db = m.database;
    final hasChambers = await _tableExists(db, 'chambers');
    final hasPatients = await _tableExists(db, 'patients');

    if (hasChambers) {
      // Custom ALTER avoids Drift's NOT NULL default on [clinicPatientId]: a constant
      // default would duplicate across rows and break the UNIQUE constraint.
      await _addColumnIfMissing(
        db,
        'chambers',
        'patient_id_prefix',
        "TEXT NOT NULL DEFAULT ''",
      );
      await _addColumnIfMissing(
        db,
        'chambers',
        'patient_id_next_sequence',
        'INTEGER NOT NULL DEFAULT 1',
      );
    }

    if (hasPatients) {
      await _addColumnIfMissing(db, 'patients', 'clinic_patient_id', 'TEXT');
      await _addColumnIfMissing(
        db,
        'patients',
        'patient_id_prefix',
        "TEXT NOT NULL DEFAULT ''",
      );
      await _addColumnIfMissing(
        db,
        'patients',
        'patient_id_sequence',
        'INTEGER NOT NULL DEFAULT 0',
      );
    }

    if (hasChambers) {
      final usedPrefixes = <String>{};
      final chamberRows = await db
          .customSelect('SELECT id FROM chambers')
          .get();
      final rng = Random.secure();
      for (final row in chamberRows) {
        final id = row.read<String>('id');
        var prefix = '';
        for (var attempt = 0; attempt < 500; attempt++) {
          final candidate = (100 + rng.nextInt(900)).toString();
          if (usedPrefixes.add(candidate)) {
            prefix = candidate;
            break;
          }
        }
        if (prefix.isEmpty) {
          prefix = (900 + chamberRows.indexOf(row)).toString();
          usedPrefixes.add(prefix);
        }
        await db.customStatement(
          'UPDATE chambers SET patient_id_prefix = ?, patient_id_next_sequence = 1 WHERE id = ?',
          [prefix, id],
        );
      }
    }

    if (hasPatients) {
      await db.customStatement('''
UPDATE patients
SET
  clinic_patient_id = 'P-' || printf('%06d', patient_number),
  patient_id_prefix = '',
  patient_id_sequence = patient_number
WHERE clinic_patient_id IS NULL OR clinic_patient_id = ''
''');

      await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS patients_clinic_patient_id_unique
ON patients (clinic_patient_id)
''');
    }
  }

  Future<bool> _tableExists(GeneratedDatabase db, String table) async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
          variables: [Variable.withString(table)],
        )
        .get();
    return rows.isNotEmpty;
  }

  Future<void> _addColumnIfMissing(
    GeneratedDatabase db,
    String table,
    String column,
    String definition,
  ) async {
    try {
      await db.customStatement(
        'ALTER TABLE $table ADD COLUMN $column $definition',
      );
    } on Object {
      // Column already present (retry after a partial migration).
    }
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.open();
  ref.onDispose(database.close);
  return database;
});
