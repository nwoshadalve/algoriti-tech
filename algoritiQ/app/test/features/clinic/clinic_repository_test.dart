import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/clinic/domain/chamber.dart';
import 'package:algoritiq_app/features/clinic/domain/doctor.dart';
import 'package:algoritiq_app/features/clinic/domain/setup_stage.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftClinicRepository repository;
  var tick = 0;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    database = AppDatabase(NativeDatabase.memory());
    // Each write gets a later time, so insertion order is the display order.
    repository = DriftClinicRepository(
      database,
      () => DateTime.utc(2026, 10, 27).add(Duration(seconds: tick++)),
    );
  });

  tearDown(() => database.close());

  const doctor = Doctor(id: 'd1', name: 'Dr. Rahim', specialty: 'Medicine');

  Chamber chamber(String id, {String doctorId = 'd1'}) =>
      Chamber(id: id, doctorId: doctorId, name: 'Chamber $id');

  group('setup stage', () {
    test('should start at the profile step', () async {
      expect(await repository.watchStage().first, SetupStage.profile);
    });

    test('should move to chambers when the profile is saved', () async {
      await repository.saveProfile(doctor);

      expect(await repository.watchStage().first, SetupStage.chambers);
      final saved = (await repository.watchDoctors().first).single;
      expect(saved.name, 'Dr. Rahim');
      expect(saved.specialty, 'Medicine');
    });

    test('should not move the stage back when the profile is edited', () async {
      await repository.saveProfile(doctor);
      await repository.setStage(SetupStage.ready);

      await repository.saveProfile(
        const Doctor(id: 'd1', name: 'Dr. Rahim Uddin'),
      );

      expect(await repository.watchStage().first, SetupStage.ready);
      expect((await repository.watchDoctors().first).single.specialty, isNull);
    });

    test('should remember the stage after reopening', () async {
      await repository.setStage(SetupStage.done);

      expect(await repository.watchStage().first, SetupStage.done);
    });
  });

  group('chambers', () {
    // Chambers hang under a doctor, so there must be one first.
    setUp(() => repository.saveProfile(doctor));

    test('should add chambers up to the limit and refuse more', () async {
      expect(await repository.addChamber(chamber('a'), limit: 2), isTrue);
      expect(await repository.addChamber(chamber('b'), limit: 2), isTrue);

      expect(await repository.addChamber(chamber('c'), limit: 2), isFalse);
      expect(await repository.chamberCount(), 2);
    });

    test('should list chambers in the order they were added', () async {
      await repository.addChamber(chamber('z'), limit: 3);
      await repository.addChamber(chamber('a'), limit: 3);

      final names = (await repository.watchChambers().first).map((c) => c.id);
      expect(names, ['z', 'a']);
    });

    test('should update a chamber without changing its position', () async {
      await repository.addChamber(chamber('a'), limit: 3);
      await repository.addChamber(chamber('b'), limit: 3);

      await repository.updateChamber(
        const Chamber(
          id: 'a',
          doctorId: 'd1',
          name: 'Renamed',
          location: 'Uttara',
          phone: '01700000000',
        ),
      );

      final chambers = await repository.watchChambers().first;
      expect(chambers.first.name, 'Renamed');
      expect(chambers.first.location, 'Uttara');
      expect(chambers.first.phone, '01700000000');
      expect(chambers.first.doctorId, 'd1');
      expect(chambers.last.id, 'b');
    });

    test('should keep each chamber under its doctor', () async {
      await repository.saveProfile(const Doctor(id: 'd2', name: 'Dr. Two'));

      await repository.addChamber(chamber('a'), limit: 1);
      await repository.addChamber(chamber('b', doctorId: 'd2'), limit: 1);

      final chambers = await repository.watchChambers().first;
      expect(
        {for (final c in chambers) c.id: c.doctorId},
        {'a': 'd1', 'b': 'd2'},
      );
    });

    test('should apply the limit per doctor', () async {
      await repository.saveProfile(const Doctor(id: 'd2', name: 'Dr. Two'));
      await repository.addChamber(chamber('a'), limit: 1);

      final other = await repository.addChamber(
        chamber('b', doctorId: 'd2'),
        limit: 1,
      );

      expect(other, isTrue);
    });

    test('should refuse a chamber for a doctor that does not exist', () async {
      expect(
        () => repository.addChamber(chamber('x', doctorId: 'nobody'), limit: 2),
        throwsA(isA<Exception>()),
      );
    });
  });
}
