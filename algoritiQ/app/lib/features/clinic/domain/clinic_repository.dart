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

  /// Adds [chamber] to its doctor unless that doctor already has [limit]
  /// chambers. Checked and written in one transaction. Returns false when the
  /// limit was reached.
  Future<bool> addChamber(Chamber chamber, {required int limit});

  Future<void> updateChamber(Chamber chamber);

  Future<void> setStage(SetupStage stage);
}
