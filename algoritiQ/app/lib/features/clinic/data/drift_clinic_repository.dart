// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../domain/chamber.dart';
import '../domain/clinic_repository.dart';
import '../domain/doctor.dart';
import '../domain/setup_stage.dart';

final class DriftClinicRepository implements ClinicRepository {
  DriftClinicRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  static const _stageKey = 'setup.stage';

  @override
  Stream<SetupStage> watchStage() {
    final query = _db.select(_db.appSettings)
      ..where((s) => s.key.equals(_stageKey));
    return query.watchSingleOrNull().map(_stageOf);
  }

  SetupStage _stageOf(SettingRow? row) =>
      SetupStage.values.asNameMap()[row?.value] ?? SetupStage.profile;

  @override
  Stream<List<Doctor>> watchDoctors() {
    final query = _db.select(_db.doctors)
      ..orderBy([(d) => OrderingTerm.asc(d.name)]);
    return query.watch().map(
      (rows) => [for (final row in rows) _doctorOf(row)],
    );
  }

  Doctor _doctorOf(DoctorRow row) => Doctor(
    id: row.id,
    name: row.name,
    degrees: _decodeDegrees(row.degrees),
    designation: row.designation,
    workplace: row.workplace,
    registrationNumber: row.registrationNumber,
    specialty: row.specialty,
    photoPath: row.photoPath,
  );

  List<String> _decodeDegrees(String json) {
    final decoded = jsonDecode(json);
    return decoded is List ? decoded.whereType<String>().toList() : const [];
  }

  @override
  Stream<List<Chamber>> watchChambers() {
    final query = _db.select(_db.chambers)
      ..orderBy([
        (c) => OrderingTerm.asc(c.createdAt),
        (c) => OrderingTerm.asc(c.id),
      ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          Chamber(
            id: row.id,
            doctorId: row.doctorId,
            name: row.name,
            location: row.location,
            phone: row.phone,
          ),
      ],
    );
  }

  @override
  Future<int> chamberCount() async {
    final count = _db.chambers.id.count();
    final query = _db.selectOnly(_db.chambers)..addColumns([count]);
    return (await query.map((row) => row.read(count)).getSingle()) ?? 0;
  }

  Future<int> _chamberCountOf(String doctorId) async {
    final count = _db.chambers.id.count();
    final query = _db.selectOnly(_db.chambers)
      ..addColumns([count])
      ..where(_db.chambers.doctorId.equals(doctorId));
    return (await query.map((row) => row.read(count)).getSingle()) ?? 0;
  }

  @override
  Future<void> saveProfile(Doctor doctor) => _db.transaction(() async {
    await _db
        .into(_db.doctors)
        .insertOnConflictUpdate(
          DoctorsCompanion.insert(
            id: doctor.id,
            name: doctor.name,
            specialty: Value(doctor.specialty),
            degrees: Value(jsonEncode(doctor.degrees)),
            designation: Value(doctor.designation),
            workplace: Value(doctor.workplace),
            registrationNumber: Value(doctor.registrationNumber),
            photoPath: Value(doctor.photoPath),
          ),
        );
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(_stageKey))).getSingleOrNull();
    if (_stageOf(row) == SetupStage.profile) {
      await setStage(SetupStage.chambers);
    }
  });

  @override
  Future<void> updateDoctor(Doctor doctor) async {
    await (_db.update(_db.doctors)..where((d) => d.id.equals(doctor.id))).write(
      DoctorsCompanion(
        name: Value(doctor.name),
        specialty: Value(doctor.specialty),
        degrees: Value(jsonEncode(doctor.degrees)),
        designation: Value(doctor.designation),
        workplace: Value(doctor.workplace),
        registrationNumber: Value(doctor.registrationNumber),
        photoPath: Value(doctor.photoPath),
      ),
    );
  }

  @override
  Future<bool> addChamber(Chamber chamber, {required int limit}) =>
      _db.transaction(() async {
        if (await _chamberCountOf(chamber.doctorId) >= limit) return false;
        await _db
            .into(_db.chambers)
            .insert(
              ChambersCompanion.insert(
                id: chamber.id,
                doctorId: chamber.doctorId,
                name: chamber.name,
                location: Value(chamber.location),
                phone: Value(chamber.phone),
                createdAt: _clock().toUtc().millisecondsSinceEpoch,
              ),
            );
        return true;
      });

  @override
  Future<void> updateChamber(Chamber chamber) async {
    await (_db.update(
      _db.chambers,
    )..where((c) => c.id.equals(chamber.id))).write(
      ChambersCompanion(
        name: Value(chamber.name),
        location: Value(chamber.location),
        phone: Value(chamber.phone),
      ),
    );
  }

  @override
  Future<void> deleteChamber(String chamberId) async {
    await (_db.delete(_db.chambers)..where((c) => c.id.equals(chamberId))).go();
  }

  @override
  Future<void> setStage(SetupStage stage) async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: _stageKey, value: stage.name),
        );
  }
}
