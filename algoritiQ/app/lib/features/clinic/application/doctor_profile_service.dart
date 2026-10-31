// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../../access/application/user_management_service.dart'
    show UserManagementForbidden;
import '../../access/domain/access_policy.dart';
import '../../access/domain/account.dart';
import '../../licensing/domain/license_core.dart';
import '../domain/clinic_repository.dart';
import '../domain/doctor.dart';
import '../domain/doctor_photo_files.dart';

/// The clinic is not licensed for a single doctor, so there is no doctor page.
final class DoctorProfileUnavailable implements Exception {
  const DoctorProfileUnavailable();
}

/// What an admin can change about the doctor.
final class DoctorDetails {
  const DoctorDetails({
    required this.name,
    this.degrees = const [],
    this.designation,
    this.workplace,
    this.registrationNumber,
    this.specialty,
  });

  final String name;
  final List<String> degrees;
  final String? designation;
  final String? workplace;
  final String? registrationNumber;
  final String? specialty;
}

enum DoctorProblem { nameMissing, tooLong, tooManyDegrees }

sealed class DoctorSaveResult {
  const DoctorSaveResult();
}

final class DoctorSaved extends DoctorSaveResult {
  const DoctorSaved(this.doctor);

  final Doctor doctor;
}

final class DoctorRefused extends DoctorSaveResult {
  const DoctorRefused(this.problem);

  final DoctorProblem problem;
}

enum DoctorPhotoProblem { unsupported, tooLarge }

/// The doctor of a doctor license (exactly one), edited by an admin from the
/// website: details and photo.
class DoctorProfileService {
  DoctorProfileService({
    required this._clinic,
    required this._photos,
    required this._licensePayload,
  });

  final ClinicRepository _clinic;
  final DoctorPhotoFiles _photos;
  final Future<LicensePayload?> Function() _licensePayload;

  static const maxNameLength = 120;
  static const maxFieldLength = 200;
  static const maxDegrees = 12;
  static const maxDegreeLength = 60;

  /// What the clinic is licensed for; null when no valid license is stored.
  Future<LicenseType?> licenseType() async => (await _licensePayload())?.type;

  Future<Doctor> _theDoctor(Account admin) async {
    if (admin.role != Role.admin) throw const UserManagementForbidden();
    if (await licenseType() != LicenseType.doctor) {
      throw const DoctorProfileUnavailable();
    }
    final doctors = await _clinic.watchDoctors().first;
    if (doctors.isEmpty) throw const DoctorProfileUnavailable();
    return doctors.first;
  }

  Future<Doctor> load(Account admin) => _theDoctor(admin);

  /// 0 when the doctor has no photo.
  Future<int> photoVersion(Doctor doctor) async {
    final path = doctor.photoPath;
    return path == null ? 0 : await _photos.versionOf(path);
  }

  Future<DoctorSaveResult> update(Account admin, DoctorDetails details) async {
    final current = await _theDoctor(admin);
    final name = details.name.trim();
    if (name.isEmpty) return const DoctorRefused(DoctorProblem.nameMissing);
    final degrees = [
      for (final degree in details.degrees)
        if (degree.trim().isNotEmpty) degree.trim(),
    ];
    if (degrees.length > maxDegrees) {
      return const DoctorRefused(DoctorProblem.tooManyDegrees);
    }
    String? clean(String? value) {
      final text = value?.trim();
      return text == null || text.isEmpty ? null : text;
    }

    final designation = clean(details.designation);
    final workplace = clean(details.workplace);
    final registration = clean(details.registrationNumber);
    final specialty = clean(details.specialty);
    if (name.length > maxNameLength ||
        degrees.any((d) => d.length > maxDegreeLength) ||
        [
          designation,
          workplace,
          registration,
          specialty,
        ].any((v) => v != null && v.length > maxFieldLength)) {
      return const DoctorRefused(DoctorProblem.tooLong);
    }
    final doctor = Doctor(
      id: current.id,
      name: name,
      degrees: degrees,
      designation: designation,
      workplace: workplace,
      registrationNumber: registration,
      specialty: specialty,
      photoPath: current.photoPath,
    );
    await _clinic.updateDoctor(doctor);
    return DoctorSaved(doctor);
  }

  Future<List<int>?> photo(Account admin) async {
    final path = (await _theDoctor(admin)).photoPath;
    return path == null ? null : _photos.read(path);
  }

  /// Null when saved, otherwise why the picture was refused.
  Future<DoctorPhotoProblem?> setPhoto(Account admin, List<int> bytes) async {
    final current = await _theDoctor(admin);
    if (bytes.length > AccessPolicy.maxPhotoBytes) {
      return DoctorPhotoProblem.tooLarge;
    }
    if (AccessPolicy.imageType(bytes) == null) {
      return DoctorPhotoProblem.unsupported;
    }
    final path = await _photos.save(bytes);
    await _clinic.updateDoctor(_withPhoto(current, path));
    final old = current.photoPath;
    if (old != null) await _photos.remove(old);
    return null;
  }

  Future<void> removePhoto(Account admin) async {
    final current = await _theDoctor(admin);
    final old = current.photoPath;
    if (old == null) return;
    await _clinic.updateDoctor(_withPhoto(current, null));
    await _photos.remove(old);
  }

  Doctor _withPhoto(Doctor d, String? path) => Doctor(
    id: d.id,
    name: d.name,
    degrees: d.degrees,
    designation: d.designation,
    workplace: d.workplace,
    registrationNumber: d.registrationNumber,
    specialty: d.specialty,
    photoPath: path,
  );
}
