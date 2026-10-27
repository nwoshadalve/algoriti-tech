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
@DriftDatabase(
  tables: [Doctors, Chambers, AppSettings, Users, AuthSessions, AuditEntries],
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
  int get schemaVersion => 5;

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
      if (from < 5) {
        await m.addColumn(users, users.email);
      }
    },
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.open();
  ref.onDispose(database.close);
  return database;
});
