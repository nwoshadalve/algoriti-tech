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
  const WorkScopeOption({
    required this.id,
    required this.name,
    this.detail,
    this.deskChamberId,
  });

  final String id;
  final String name;
  final String? detail;

  /// Chamber id for queue-desk HTTP calls when [id] is a doctor assignment.
  final String? deskChamberId;
}

final class ReceptionistScopeLoad {
  const ReceptionistScopeLoad({
    required this.assignmentTarget,
    required this.scopeIds,
    required this.options,
    this.activeOptions = const [],
  });

  final AssignmentTarget assignmentTarget;
  final List<String> scopeIds;
  final List<WorkScopeOption> options;

  /// The [options] whose chamber has a session open right now.
  final List<WorkScopeOption> activeOptions;
}

/// Chambers or doctors assigned to a receptionist, resolved to names.
final class ReceptionistScopeService {
  ReceptionistScopeService({
    required AccountRepository accounts,
    required ClinicRepository clinic,
    required Future<LicensePayload?> Function() licensePayload,
    Future<bool> Function(String chamberId)? hasOpenSession,
  }) : _accounts = accounts,
       _clinic = clinic,
       _licensePayload = licensePayload,
       _hasOpenSession = hasOpenSession;

  final AccountRepository _accounts;
  final ClinicRepository _clinic;
  final Future<LicensePayload?> Function() _licensePayload;
  final Future<bool> Function(String chamberId)? _hasOpenSession;

  Future<ReceptionistScopeLoad> load(Account account) async {
    final scopeIds = await _accounts.getUserScopes(account.id);
    final payload = await _licensePayload();
    final target = payload?.type == LicenseType.chamber
        ? AssignmentTarget.doctor
        : AssignmentTarget.chamber;
    final options = await _resolve(scopeIds, target);
    final check = _hasOpenSession;
    final active = <WorkScopeOption>[];
    if (check != null && options.length > 1) {
      for (final option in options) {
        final chamberId = option.deskChamberId;
        if (chamberId != null && await check(chamberId)) active.add(option);
      }
    }
    return ReceptionistScopeLoad(
      assignmentTarget: target,
      scopeIds: scopeIds,
      options: options,
      activeOptions: active,
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
                deskChamberId: c.id,
              ),
        ];
      case AssignmentTarget.doctor:
        final doctors = await _clinic.watchDoctors().first;
        final chambers = await _clinic.watchChambers().first;
        final byId = {for (final d in doctors) d.id: d};
        final chamberByDoctor = <String, String>{};
        for (final chamber in chambers) {
          chamberByDoctor.putIfAbsent(chamber.doctorId, () => chamber.id);
        }
        return [
          for (final id in scopeIds)
            if (byId[id] case final Doctor d)
              WorkScopeOption(
                id: d.id,
                name: d.name,
                detail: d.workplace?.trim().isNotEmpty == true
                    ? d.workplace
                    : d.designation,
                deskChamberId: chamberByDoctor[d.id],
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
