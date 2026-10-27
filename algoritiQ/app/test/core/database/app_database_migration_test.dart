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
}
