// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:algoritiq_app/features/clinic/application/clinic_actions.dart';
import 'package:algoritiq_app/features/clinic/data/drift_clinic_repository.dart';
import 'package:algoritiq_app/features/clinic/domain/clinic_repository.dart';
import 'package:algoritiq_app/features/clinic/domain/doctor_draft.dart';
import 'package:algoritiq_app/features/clinic/domain/setup_outcome.dart';
import 'package:algoritiq_app/features/clinic/domain/setup_stage.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _StorageException implements Exception {}

/// Every call fails, as a full disk or a locked database would.
class _FailingRepository implements ClinicRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw _StorageException();
}

/// A complete profile: name, designation, specialty and a degree are required.
DoctorDraft draftFor(String name) => DoctorDraft(
  name: name,
  designation: 'Assistant Professor',
  specialty: 'Orthopaedics',
  degrees: const ['MBBS'],
);

void main() {
  late AppDatabase database;
  late DriftClinicRepository repository;
  late ClinicActions actions;
  var nextId = 0;

  ClinicActions build({int maxChambers = 2}) => ClinicActions(
    repository: repository,
    newId: () => 'id${nextId++}',
    maxChambers: maxChambers,
  );

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    nextId = 0;
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftClinicRepository(database, DateTime.now);
    actions = build();
  });

  tearDown(() => database.close());

  group('profile', () {
    test('should save a trimmed name and move to chambers', () async {
      final outcome = await actions.saveProfile(
        const DoctorDraft(
          name: '  Dr. Rahim ',
          designation: ' Prof ',
          specialty: ' Bones ',
          degrees: ['MBBS'],
        ),
      );

      expect(outcome, SetupOutcome.saved);
      final doctor = (await repository.watchDoctors().first).single;
      expect(doctor.name, 'Dr. Rahim');
      expect(doctor.specialty, 'Bones');
      expect(await repository.watchStage().first, SetupStage.chambers);
    });

    test('should keep degrees in order and drop blank ones', () async {
      await actions.saveProfile(
        const DoctorDraft(
          name: 'Dr. A',
          degrees: ['MBBS (DMC)', '  ', ' BCS (Health) ', 'MS'],
          designation: ' Assistant Professor ',
          specialty: 'Bones',
          workplace: 'Hospital',
          registrationNumber: ' A-1 ',
          photoPath: '/photos/a.jpg',
        ),
      );

      final doctor = (await repository.watchDoctors().first).single;
      expect(doctor.degrees, ['MBBS (DMC)', 'BCS (Health)', 'MS']);
      expect(doctor.designation, 'Assistant Professor');
      expect(doctor.workplace, 'Hospital');
      expect(doctor.registrationNumber, 'A-1');
      expect(doctor.photoPath, '/photos/a.jpg');
    });

    // regression: name, designation, specialty and one degree are mandatory.
    for (final (label, draft) in [
      (
        'name',
        const DoctorDraft(
          name: '  ',
          designation: 'D',
          specialty: 'S',
          degrees: ['M'],
        ),
      ),
      (
        'designation',
        const DoctorDraft(
          name: 'N',
          designation: ' ',
          specialty: 'S',
          degrees: ['M'],
        ),
      ),
      (
        'specialty',
        const DoctorDraft(
          name: 'N',
          designation: 'D',
          specialty: '',
          degrees: ['M'],
        ),
      ),
      (
        'degree',
        const DoctorDraft(name: 'N', designation: 'D', specialty: 'S'),
      ),
      (
        'degree (only blanks)',
        const DoctorDraft(
          name: 'N',
          designation: 'D',
          specialty: 'S',
          degrees: [' ', ''],
        ),
      ),
    ]) {
      test('should reject a profile with no $label', () async {
        final outcome = await actions.saveProfile(draft);

        expect(outcome, SetupOutcome.fieldsMissing);
        expect(await repository.watchDoctors().first, isEmpty);
      });
    }

    test(
      'should still save without a hospital, registration or photo',
      () async {
        final outcome = await actions.saveProfile(draftFor('Dr. Minimal'));

        expect(outcome, SetupOutcome.saved);
        final doctor = (await repository.watchDoctors().first).single;
        expect(doctor.workplace, isNull);
        expect(doctor.registrationNumber, isNull);
        expect(doctor.photoPath, isNull);
      },
    );

    test('should keep one doctor when the profile is saved again', () async {
      await actions.saveProfile(draftFor('Dr. Rahim'));
      final first = (await repository.watchDoctors().first).single;

      await actions.saveProfile(draftFor('Dr. Rahim U'), existingId: first.id);

      final doctors = await repository.watchDoctors().first;
      expect(doctors, hasLength(1));
      expect(doctors.single.name, 'Dr. Rahim U');
    });
  });

  group('chambers', () {
    late String doctorId;

    setUp(() async {
      await actions.saveProfile(draftFor('Dr. A'));
      doctorId = (await repository.watchDoctors().first).single.id;
    });

    Future<SetupOutcome> add(
      String name, {
      String location = 'Dhaka',
      String phone = '01700000000',
    }) => actions.addChamber(
      doctorId: doctorId,
      name: name,
      location: location,
      phone: phone,
    );

    test('should add a chamber with its address and phone', () async {
      final outcome = await add(
        'First chamber',
        location: ' Some address ',
        phone: ' 01711111111 ',
      );

      expect(outcome, SetupOutcome.saved);
      final saved = (await repository.watchChambers().first).single;
      expect(saved.name, 'First chamber');
      expect(saved.location, 'Some address');
      expect(saved.phone, '01711111111');
      expect(saved.doctorId, doctorId);
    });

    // regression: name, address and phone are all mandatory.
    for (final (label, name, location, phone) in [
      ('name', ' ', 'Dhaka', '017'),
      ('address', 'A', ' ', '017'),
      ('phone', 'A', 'Dhaka', ' '),
    ]) {
      test('should reject a chamber with a blank $label', () async {
        expect(
          await add(name, location: location, phone: phone),
          SetupOutcome.fieldsMissing,
        );
        expect(await repository.chamberCount(), 0);
      });
    }

    test('should refuse a chamber beyond the license limit', () async {
      await add('A');
      await add('B');

      final outcome = await add('C');

      expect(outcome, SetupOutcome.limitReached);
      expect(await repository.chamberCount(), 2);
    });

    test('should allow editing a chamber when the license is full', () async {
      await add('A');
      await add('B');
      final first = (await repository.watchChambers().first).first;

      final outcome = await actions.updateChamber(
        first,
        name: 'A2',
        location: 'New address',
        phone: '01722222222',
      );

      expect(outcome, SetupOutcome.saved);
      final updated = (await repository.watchChambers().first).first;
      expect(updated.name, 'A2');
      expect(updated.location, 'New address');
      expect(updated.phone, '01722222222');
    });

    test('should not save an edit that blanks a required field', () async {
      await add('A');
      final first = (await repository.watchChambers().first).single;

      final outcome = await actions.updateChamber(
        first,
        name: 'A',
        location: 'Dhaka',
        phone: '',
      );

      expect(outcome, SetupOutcome.fieldsMissing);
      expect(
        (await repository.watchChambers().first).single.phone,
        '01700000000',
      );
    });

    test('should not continue without a chamber', () async {
      expect(await actions.confirmChambers(), SetupOutcome.noChambers);
      expect(await repository.watchStage().first, SetupStage.chambers);
    });

    test('should continue to ready once a chamber exists', () async {
      await add('A');

      expect(await actions.confirmChambers(), SetupOutcome.saved);
      expect(await repository.watchStage().first, SetupStage.ready);
    });
  });

  group('going back', () {
    test(
      'should return from chambers to the profile, keeping the data',
      () async {
        await actions.saveProfile(draftFor('Dr. A'));
        final doctorId = (await repository.watchDoctors().first).single.id;
        await actions.addChamber(
          doctorId: doctorId,
          name: 'A',
          location: 'Dhaka',
          phone: '017',
        );

        expect(await actions.backToProfile(), SetupOutcome.saved);

        expect(await repository.watchStage().first, SetupStage.profile);
        expect(await repository.watchDoctors().first, hasLength(1));
        expect(await repository.chamberCount(), 1);
      },
    );

    test('should return from ready to chambers', () async {
      await repository.setStage(SetupStage.ready);

      expect(await actions.backToChambers(), SetupOutcome.saved);

      expect(await repository.watchStage().first, SetupStage.chambers);
    });

    test('should edit the profile again without a second doctor', () async {
      await actions.saveProfile(draftFor('Dr. A'));
      final first = (await repository.watchDoctors().first).single;
      await actions.backToProfile();

      await actions.saveProfile(
        draftFor('Dr. A Updated'),
        existingId: first.id,
      );

      final doctors = await repository.watchDoctors().first;
      expect(doctors.single.id, first.id);
      expect(doctors.single.name, 'Dr. A Updated');
      expect(await repository.watchStage().first, SetupStage.chambers);
    });
  });

  test('should finish setup', () async {
    expect(await actions.finish(), SetupOutcome.saved);
    expect(await repository.watchStage().first, SetupStage.done);
  });

  test('should report a storage failure instead of throwing', () async {
    final failing = ClinicActions(
      repository: _FailingRepository(),
      newId: () => 'x',
      maxChambers: 2,
    );

    expect(await failing.saveProfile(draftFor('Dr. A')), SetupOutcome.failed);
    expect(
      await failing.addChamber(
        doctorId: 'd',
        name: 'A',
        location: 'Dhaka',
        phone: '017',
      ),
      SetupOutcome.failed,
    );
    expect(await failing.confirmChambers(), SetupOutcome.failed);
    expect(await failing.finish(), SetupOutcome.failed);
  });
}
