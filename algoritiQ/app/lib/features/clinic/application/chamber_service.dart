// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../../../core/clock.dart';
import '../../../core/id_generator.dart';
import '../../access/application/user_management_service.dart'
    show UserManagementForbidden;
import '../../access/domain/account.dart';
import '../../access/domain/account_repository.dart';
import '../../licensing/domain/license_core.dart';
import '../domain/chamber.dart';
import '../domain/clinic_repository.dart';

/// The clinic has no doctor license, or no doctor is set up yet, so there is
/// nothing to manage.
final class ChambersUnavailable implements Exception {
  const ChambersUnavailable();
}

/// What the license allows and how much of it is used.
final class LicenseSummary {
  const LicenseSummary({
    required this.type,
    required this.maxDoctors,
    required this.maxChambers,
    required this.chambersUsed,
    required this.issuedAt,
    required this.expiresAt,
    required this.status,
  });

  final LicenseType type;
  final int maxDoctors;
  final int maxChambers;
  final int chambersUsed;
  final DateTime issuedAt;

  /// Null for a perpetual license.
  final DateTime? expiresAt;
  final LicenseStatus status;
}

enum ChamberProblem {
  nameMissing,
  locationMissing,
  phoneMissing,
  phoneInvalid,
  tooLong,

  /// The license allows no more chambers.
  limitReached,
  notFound,

  /// A doctor needs at least one chamber to see patients.
  lastChamber,
}

sealed class ChamberResult {
  const ChamberResult();
}

final class ChamberSaved extends ChamberResult {
  const ChamberSaved(this.chamber);

  final Chamber chamber;
}

final class ChamberRefused extends ChamberResult {
  const ChamberRefused(this.problem);

  final ChamberProblem problem;
}

/// The chambers of a doctor license, kept by an admin from the website, up to
/// the number the license allows.
class ChamberService {
  ChamberService({
    required this._clinic,
    required this._accounts,
    required this._clock,
    required this._newId,
    required this._licensePayload,
  });

  final ClinicRepository _clinic;
  final AccountRepository _accounts;
  final Clock _clock;
  final IdGenerator _newId;
  final Future<LicensePayload?> Function() _licensePayload;

  static const maxNameLength = 120;
  static const maxFieldLength = 200;
  static const maxPhoneLength = 32;
  static final _phonePattern = RegExp(r'^[0-9+()\-. ]+$');

  Future<({LicensePayload license, String doctorId})> _covered(
    Account admin,
  ) async {
    if (admin.role != Role.admin) throw const UserManagementForbidden();
    final license = await _licensePayload();
    if (license == null || license.type != LicenseType.doctor) {
      throw const ChambersUnavailable();
    }
    final doctors = await _clinic.watchDoctors().first;
    if (doctors.isEmpty) throw const ChambersUnavailable();
    return (license: license, doctorId: doctors.first.id);
  }

  Future<LicenseSummary> summary(Account admin) async {
    final (:license, doctorId: _) = await _covered(admin);
    return LicenseSummary(
      type: license.type,
      maxDoctors: license.maxDoctors,
      maxChambers: license.maxChambers,
      chambersUsed: await _clinic.chamberCount(),
      issuedAt: license.issuedAt,
      expiresAt: license.expiresAt,
      status: license.statusAt(_clock()),
    );
  }

  Future<List<Chamber>> list(Account admin) async {
    await _covered(admin);
    return _clinic.watchChambers().first;
  }

  ChamberProblem? _check(String name, String location, String phone) {
    if (name.isEmpty) return ChamberProblem.nameMissing;
    if (location.isEmpty) return ChamberProblem.locationMissing;
    if (phone.isEmpty) return ChamberProblem.phoneMissing;
    if (name.length > maxNameLength || location.length > maxFieldLength) {
      return ChamberProblem.tooLong;
    }
    if (phone.length > maxPhoneLength || !_phonePattern.hasMatch(phone)) {
      return ChamberProblem.phoneInvalid;
    }
    return null;
  }

  Future<ChamberResult> create(
    Account admin, {
    required String name,
    required String location,
    required String phone,
  }) async {
    final (:license, :doctorId) = await _covered(admin);
    final cleanName = name.trim();
    final cleanLocation = location.trim();
    final cleanPhone = phone.trim();
    final problem = _check(cleanName, cleanLocation, cleanPhone);
    if (problem != null) return ChamberRefused(problem);

    final chamber = Chamber(
      id: _newId(),
      doctorId: doctorId,
      name: cleanName,
      location: cleanLocation,
      phone: cleanPhone,
    );
    // Counted and written in one transaction, so two requests cannot both
    // take the last place.
    final added = await _clinic.addChamber(chamber, limit: license.maxChambers);
    if (!added) return const ChamberRefused(ChamberProblem.limitReached);
    await _accounts.audit(
      at: _clock().toUtc(),
      action: 'chamber.created',
      actorId: admin.id,
      detail: chamber.id,
    );
    return ChamberSaved(chamber);
  }

  Future<ChamberResult> update(
    Account admin,
    String chamberId, {
    required String name,
    required String location,
    required String phone,
  }) async {
    await _covered(admin);
    final current = (await _clinic.watchChambers().first)
        .where((c) => c.id == chamberId)
        .firstOrNull;
    if (current == null) return const ChamberRefused(ChamberProblem.notFound);
    final cleanName = name.trim();
    final cleanLocation = location.trim();
    final cleanPhone = phone.trim();
    final problem = _check(cleanName, cleanLocation, cleanPhone);
    if (problem != null) return ChamberRefused(problem);

    final chamber = Chamber(
      id: current.id,
      doctorId: current.doctorId,
      name: cleanName,
      location: cleanLocation,
      phone: cleanPhone,
    );
    await _clinic.updateChamber(chamber);
    await _accounts.audit(
      at: _clock().toUtc(),
      action: 'chamber.updated',
      actorId: admin.id,
      detail: chamber.id,
    );
    return ChamberSaved(chamber);
  }

  /// Null when deleted, otherwise why not. Receptionists assigned to the
  /// chamber lose that assignment.
  Future<ChamberProblem?> delete(Account admin, String chamberId) async {
    await _covered(admin);
    final chambers = await _clinic.watchChambers().first;
    if (!chambers.any((c) => c.id == chamberId)) {
      return ChamberProblem.notFound;
    }
    if (chambers.length <= 1) return ChamberProblem.lastChamber;
    await _clinic.deleteChamber(chamberId);
    await _accounts.removeScopeEverywhere(
      scopeId: chamberId,
      actorId: admin.id,
      at: _clock().toUtc(),
    );
    await _accounts.audit(
      at: _clock().toUtc(),
      action: 'chamber.deleted',
      actorId: admin.id,
      detail: chamberId,
    );
    return null;
  }
}
