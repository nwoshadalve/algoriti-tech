import '../../../core/id_generator.dart';
import '../domain/chamber.dart';
import '../domain/clinic_repository.dart';
import '../domain/doctor.dart';
import '../domain/doctor_draft.dart';
import '../domain/setup_outcome.dart';
import '../domain/setup_stage.dart';

/// What the user can do during first-time setup. Validates input, enforces
/// the license's chamber limit and turns storage errors into a retryable
/// [SetupOutcome.failed] (the screen shows it; nothing is lost).
class ClinicActions {
  ClinicActions({
    required this._repository,
    required this._newId,
    required this.maxChambers,
  });

  final ClinicRepository _repository;
  final IdGenerator _newId;

  /// From the license.
  final int maxChambers;

  /// Saves the doctor's profile. [existingId] is set when editing.
  ///
  /// Name, designation, specialty and at least one degree are required
  /// ([SetupOutcome.fieldsMissing] otherwise). Hospital, registration number
  /// and photo are optional.
  Future<SetupOutcome> saveProfile(
    DoctorDraft draft, {
    String? existingId,
  }) async {
    final name = _clean(draft.name);
    final designation = _clean(draft.designation);
    final specialty = _clean(draft.specialty);
    final degrees = [for (final degree in draft.degrees) ?_clean(degree)];
    if (name == null ||
        designation == null ||
        specialty == null ||
        degrees.isEmpty) {
      return SetupOutcome.fieldsMissing;
    }
    return _guard(
      () => _repository.saveProfile(
        Doctor(
          id: existingId ?? _newId(),
          name: name,
          degrees: degrees,
          designation: designation,
          workplace: _clean(draft.workplace),
          registrationNumber: _clean(draft.registrationNumber),
          specialty: specialty,
          photoPath: draft.photoPath,
        ),
      ),
    );
  }

  /// Adds a chamber under the doctor [doctorId]. Name, address and phone are
  /// all required ([SetupOutcome.fieldsMissing] when one is blank).
  Future<SetupOutcome> addChamber({
    required String doctorId,
    required String name,
    required String location,
    required String phone,
  }) async {
    final cleanName = _clean(name);
    final cleanLocation = _clean(location);
    final cleanPhone = _clean(phone);
    if (cleanName == null || cleanLocation == null || cleanPhone == null) {
      return SetupOutcome.fieldsMissing;
    }
    try {
      final added = await _repository.addChamber(
        Chamber(
          id: _newId(),
          doctorId: doctorId,
          name: cleanName,
          location: cleanLocation,
          phone: cleanPhone,
        ),
        limit: maxChambers,
      );
      return added ? SetupOutcome.saved : SetupOutcome.limitReached;
    } on Exception {
      return SetupOutcome.failed;
    }
  }

  /// Edits [chamber]'s name, address and phone (all required); it stays with
  /// its doctor.
  Future<SetupOutcome> updateChamber(
    Chamber chamber, {
    required String name,
    required String location,
    required String phone,
  }) async {
    final cleanName = _clean(name);
    final cleanLocation = _clean(location);
    final cleanPhone = _clean(phone);
    if (cleanName == null || cleanLocation == null || cleanPhone == null) {
      return SetupOutcome.fieldsMissing;
    }
    return _guard(
      () => _repository.updateChamber(
        Chamber(
          id: chamber.id,
          doctorId: chamber.doctorId,
          name: cleanName,
          location: cleanLocation,
          phone: cleanPhone,
        ),
      ),
    );
  }

  /// Goes back to the profile step to change something. Nothing is lost.
  Future<SetupOutcome> backToProfile() =>
      _guard(() => _repository.setStage(SetupStage.profile));

  /// Goes back to the chambers step to change something. Nothing is lost.
  Future<SetupOutcome> backToChambers() =>
      _guard(() => _repository.setStage(SetupStage.chambers));

  /// Moves on from the chambers step. Needs at least one chamber.
  Future<SetupOutcome> confirmChambers() async {
    try {
      if (await _repository.chamberCount() == 0) return SetupOutcome.noChambers;
      await _repository.setStage(SetupStage.ready);
      return SetupOutcome.saved;
    } on Exception {
      return SetupOutcome.failed;
    }
  }

  /// Finishes setup; the app opens straight to home from now on.
  Future<SetupOutcome> finish() =>
      _guard(() => _repository.setStage(SetupStage.done));

  // Boundary: any storage error becomes a value the screen can show.
  Future<SetupOutcome> _guard(Future<void> Function() write) async {
    try {
      await write();
      return SetupOutcome.saved;
    } on Exception {
      return SetupOutcome.failed;
    }
  }

  String? _clean(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
