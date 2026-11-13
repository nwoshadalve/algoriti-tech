// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:drift/drift.dart' show Variable, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  test(
    'should keep existing doctors and chambers when upgrading from v1',
    () async {
      // The v1 schema, created by hand: a database from before doctor details.
      final database = AppDatabase(
        NativeDatabase.memory(
          setup: (raw) {
            raw
              ..execute(
                'CREATE TABLE doctors (id TEXT NOT NULL, name TEXT NOT NULL, '
                'specialty TEXT NULL, PRIMARY KEY (id))',
              )
              ..execute(
                'CREATE TABLE chambers (id TEXT NOT NULL, name TEXT NOT NULL, '
                'location TEXT NULL, created_at INTEGER NOT NULL, '
                'PRIMARY KEY (id))',
              )
              ..execute(
                'CREATE TABLE app_settings (key TEXT NOT NULL, '
                'value TEXT NOT NULL, PRIMARY KEY (key))',
              )
              ..execute(
                "INSERT INTO doctors (id, name, specialty) "
                "VALUES ('d1', 'Saved doctor', 'Medicine')",
              )
              ..execute(
                "INSERT INTO chambers (id, name, location, created_at) "
                "VALUES ('c1', 'Saved chamber', 'Dhaka', 1)",
              )
              ..execute(
                "INSERT INTO app_settings (key, value) "
                "VALUES ('setup.stage', 'chambers')",
              )
              ..execute('PRAGMA user_version = 1');
          },
        ),
      );
      addTearDown(database.close);

      final doctor = await database.select(database.doctors).getSingle();

      expect(doctor.name, 'Saved doctor');
      expect(doctor.specialty, 'Medicine');
      expect(doctor.degrees, '[]');
      expect(doctor.designation, isNull);
      expect(doctor.photoPath, isNull);
      // The chamber found its way under the one doctor on record.
      final chamber = await database.select(database.chambers).getSingle();
      expect(chamber.name, 'Saved chamber');
      expect(chamber.doctorId, 'd1');
      expect(chamber.phone, isNull);
      final setting = await database.select(database.appSettings).getSingle();
      expect(setting.value, 'chambers');
    },
  );

  test('should keep an admin saved before profile details existed (v5)', () async {
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw
            ..execute(
              'CREATE TABLE users (id TEXT NOT NULL, username TEXT NOT NULL '
              'UNIQUE, display_name TEXT NOT NULL, email TEXT NOT NULL '
              "DEFAULT '', role TEXT NOT NULL, password_hash TEXT NOT NULL, "
              "status TEXT NOT NULL DEFAULT 'active', created_at INTEGER NOT "
              'NULL, PRIMARY KEY (id))',
            )
            ..execute(
              "INSERT INTO users (id, username, display_name, email, role, "
              "password_hash, created_at) VALUES ('u1', 'owner', 'The Owner', "
              "'o@c.test', 'admin', 'hash', 1)",
            )
            ..execute('PRAGMA user_version = 5');
        },
      ),
    );
    addTearDown(database.close);

    final user = await database.select(database.users).getSingle();

    expect(user.displayName, 'The Owner');
    expect(user.email, 'o@c.test');
    expect(user.firstName, '');
    expect(user.lastName, '');
    expect(user.phone, '');
    expect(user.photo, isNull);
    expect(user.photoVersion, 0);
  });

  test('should upgrade from v14 when patients already exist', () async {
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw
            ..execute(
              'CREATE TABLE doctors (id TEXT NOT NULL, name TEXT NOT NULL, '
              'specialty TEXT NULL, degrees TEXT NOT NULL DEFAULT \'[]\', '
              'designation TEXT NULL, workplace TEXT NULL, '
              'registration_number TEXT NULL, photo_path TEXT NULL, '
              'PRIMARY KEY (id))',
            )
            ..execute(
              'CREATE TABLE chambers (id TEXT NOT NULL, doctor_id TEXT NOT NULL, '
              'name TEXT NOT NULL, location TEXT NULL, phone TEXT NULL, '
              'created_at INTEGER NOT NULL, PRIMARY KEY (id))',
            )
            ..execute(
              'CREATE TABLE patients (id TEXT NOT NULL, patient_number INTEGER NOT NULL '
              'UNIQUE, bengali_name TEXT NOT NULL, english_name TEXT NULL, '
              'phone_normalized TEXT NOT NULL, gender TEXT NULL, '
              'date_of_birth_ms INTEGER NULL, birth_year INTEGER NULL, '
              'approximate_age_years INTEGER NULL, '
              'approximate_age_recorded_at INTEGER NULL, locality TEXT NULL, '
              'legacy_file_number TEXT NULL, admin_note TEXT NULL, '
              'has_paper_file INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL, '
              'PRIMARY KEY (id))',
            )
            ..execute("INSERT INTO doctors (id, name) VALUES ('d1', 'Doctor')")
            ..execute(
              "INSERT INTO chambers (id, doctor_id, name, created_at) "
              "VALUES ('c1', 'd1', 'Chamber', 1)",
            )
            ..execute(
              "INSERT INTO patients (id, patient_number, bengali_name, "
              "phone_normalized, created_at) VALUES "
              "('p1', 1, 'One', '01700000001', 1), "
              "('p2', 2, 'Two', '01700000002', 2)",
            )
            ..execute('PRAGMA user_version = 14');
        },
      ),
    );
    addTearDown(database.close);

    final patients = await database.select(database.patients).get();
    expect(patients, hasLength(2));
    expect(patients.map((p) => p.clinicPatientId).toSet(), {
      'P-000001',
      'P-000002',
    });

    final chamber = await database.select(database.chambers).getSingle();
    expect(chamber.patientIdPrefix, isNotEmpty);
    expect(chamber.patientIdNextSequence, 1);
  });

  group('one patient name (v17)', () {
    // A v16 database: patients with the Bengali and English names, tokens
    // without the announced column. Only the columns this step touches.
    AppDatabase v16() => AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw
            ..execute(
              'CREATE TABLE patients (id TEXT NOT NULL, bengali_name TEXT NOT '
              'NULL, english_name TEXT NULL, phone_normalized TEXT NOT NULL, '
              'PRIMARY KEY (id))',
            )
            ..execute(
              'CREATE TABLE queue_tokens (id TEXT NOT NULL, status TEXT NOT '
              'NULL, first_called_at INTEGER NULL, PRIMARY KEY (id))',
            )
            ..execute(
              "INSERT INTO patients (id, bengali_name, english_name, "
              "phone_normalized) VALUES "
              "('p1', 'করিম', 'Karim', '017'), "
              "('p2', '  ', 'Rahim', '018'), "
              "('p3', 'সালমা', NULL, '019')",
            )
            ..execute(
              "INSERT INTO queue_tokens (id, status, first_called_at) VALUES "
              "('t1', 'CALLED', 100), ('t2', 'WAITING', NULL)",
            )
            ..execute('PRAGMA user_version = 16');
        },
      ),
    );

    test(
      'should fill the name from the Bengali name, else the English',
      () async {
        final database = v16();
        addTearDown(database.close);

        final rows = await database
            .customSelect('SELECT id, name FROM patients ORDER BY id')
            .get();

        expect(
          {for (final r in rows) r.read<String>('id'): r.read<String>('name')},
          {'p1': 'করিম', 'p2': 'Rahim', 'p3': 'সালমা'},
        );
      },
    );

    test(
      'should keep the old Bengali and English names as they were',
      () async {
        final database = v16();
        addTearDown(database.close);

        final rows = await database
            .customSelect(
              'SELECT bengali_name, english_name FROM patients WHERE id = ?',
              variables: [Variable.withString('p1')],
            )
            .get();

        expect(rows.single.read<String>('bengali_name'), 'করিম');
        expect(rows.single.read<String>('english_name'), 'Karim');
      },
    );

    test('should count tokens called before as announced', () async {
      final database = v16();
      addTearDown(database.close);

      final rows = await database
          .customSelect('SELECT id, announced_at FROM queue_tokens ORDER BY id')
          .get();

      expect(rows[0].read<int?>('announced_at'), 100);
      expect(rows[1].read<int?>('announced_at'), isNull);
    });
  });

  test('should keep every earlier token paid with its fee (v18)', () async {
    // A v17 tokens table: fees but no free column. Only what this step touches.
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw
            ..execute(
              'CREATE TABLE queue_tokens (id TEXT NOT NULL, status TEXT NOT '
              'NULL, fee_bdt INTEGER NULL, PRIMARY KEY (id))',
            )
            ..execute(
              "INSERT INTO queue_tokens (id, status, fee_bdt) VALUES "
              "('t1', 'ENTERED', 500), ('t2', 'WAITING', NULL)",
            )
            ..execute('PRAGMA user_version = 17');
        },
      ),
    );
    addTearDown(database.close);

    final rows = await database
        .customSelect(
          'SELECT id, fee_bdt, is_free FROM queue_tokens ORDER BY id',
        )
        .get();

    expect([for (final r in rows) r.read<int?>('fee_bdt')], [500, null]);
    expect([for (final r in rows) r.read<bool>('is_free')], [false, false]);
  });
}
