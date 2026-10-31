// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
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
}
