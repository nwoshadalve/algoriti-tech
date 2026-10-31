// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../../access/application/user_management_service.dart';
import '../../access/domain/account.dart';
import '../../access/domain/account_repository.dart';
import '../../clinic/domain/chamber.dart';
import '../../clinic/domain/clinic_repository.dart';
import '../../clinic/domain/doctor.dart';
import '../../licensing/domain/license_core.dart';

/// One chamber or doctor a receptionist may work with today.
final class WorkScopeOption {
  const WorkScopeOption({required this.id, required this.name, this.detail});

  final String id;
  final String name;
  final String? detail;
}

final class ReceptionistScopeLoad {
  const ReceptionistScopeLoad({
    required this.assignmentTarget,
    required this.scopeIds,
    required this.options,
  });

  final AssignmentTarget assignmentTarget;
  final List<String> scopeIds;
  final List<WorkScopeOption> options;
}

/// Chambers or doctors assigned to a receptionist, resolved to names.
final class ReceptionistScopeService {
  ReceptionistScopeService({
    required AccountRepository accounts,
    required ClinicRepository clinic,
    required Future<LicensePayload?> Function() licensePayload,
  }) : _accounts = accounts,
       _clinic = clinic,
       _licensePayload = licensePayload;

  final AccountRepository _accounts;
  final ClinicRepository _clinic;
  final Future<LicensePayload?> Function() _licensePayload;

  Future<ReceptionistScopeLoad> load(Account account) async {
    final scopeIds = await _accounts.getUserScopes(account.id);
    final payload = await _licensePayload();
    final target = payload?.type == LicenseType.chamber
        ? AssignmentTarget.doctor
        : AssignmentTarget.chamber;
    final options = await _resolve(scopeIds, target);
    return ReceptionistScopeLoad(
      assignmentTarget: target,
      scopeIds: scopeIds,
      options: options,
    );
  }

  Future<List<WorkScopeOption>> _resolve(
    List<String> scopeIds,
    AssignmentTarget target,
  ) async {
    switch (target) {
      case AssignmentTarget.chamber:
        final chambers = await _clinic.watchChambers().first;
        final byId = {for (final c in chambers) c.id: c};
        return [
          for (final id in scopeIds)
            if (byId[id] case final Chamber c)
              WorkScopeOption(
                id: c.id,
                name: c.name,
                detail: _chamberDetail(c),
              ),
        ];
      case AssignmentTarget.doctor:
        final doctors = await _clinic.watchDoctors().first;
        final byId = {for (final d in doctors) d.id: d};
        return [
          for (final id in scopeIds)
            if (byId[id] case final Doctor d)
              WorkScopeOption(
                id: d.id,
                name: d.name,
                detail: d.workplace?.trim().isNotEmpty == true
                    ? d.workplace
                    : d.designation,
              ),
        ];
    }
  }

  static String? _chamberDetail(Chamber chamber) {
    final location = chamber.location?.trim();
    if (location != null && location.isNotEmpty) return location;
    final phone = chamber.phone?.trim();
    if (phone != null && phone.isNotEmpty) return phone;
    return null;
  }
}
