// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'chamber.dart';
import 'doctor.dart';
import 'setup_stage.dart';

/// Storage for the clinic's doctors, chambers and setup progress.
abstract interface class ClinicRepository {
  Stream<SetupStage> watchStage();

  Stream<List<Doctor>> watchDoctors();

  /// Chambers in the order they were added.
  Stream<List<Chamber>> watchChambers();

  Future<int> chamberCount();

  /// Saves [doctor] and moves setup on from the profile step, together.
  Future<void> saveProfile(Doctor doctor);

  /// Changes the details of an existing doctor. Unlike [saveProfile] it never
  /// moves setup on, so it is safe after setup is finished.
  Future<void> updateDoctor(Doctor doctor);

  /// Adds [chamber] to its doctor unless that doctor already has [limit]
  /// chambers. Checked and written in one transaction. Returns false when the
  /// limit was reached.
  Future<bool> addChamber(Chamber chamber, {required int limit});

  Future<void> updateChamber(Chamber chamber);

  /// Removes the chamber.
  Future<void> deleteChamber(String chamberId);

  Future<void> setStage(SetupStage stage);
}
