// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../access/application/access_providers.dart';
import '../../access/application/tablet_session.dart';
import '../../access/application/user_management_service.dart';
import '../../access/domain/account.dart';
import '../../clinic/application/clinic_providers.dart';
import '../../licensing/application/license_controller.dart';
import 'receptionist_scope_service.dart';

/// Resolves which chamber/doctor context a receptionist may work in after sign-in.
final receptionistScopeServiceProvider = Provider<ReceptionistScopeService>(
  (ref) => ReceptionistScopeService(
    accounts: ref.watch(accountRepositoryProvider),
    clinic: ref.watch(clinicRepositoryProvider),
    licensePayload: () => readLicensePayload(ref),
  ),
);

/// Loading / ready / blocked states for receptionist work-scope selection.
sealed class ReceptionistWorkState {
  const ReceptionistWorkState();
}

final class ReceptionistWorkLoading extends ReceptionistWorkState {
  const ReceptionistWorkLoading();
}

final class ReceptionistWorkUnassigned extends ReceptionistWorkState {
  const ReceptionistWorkUnassigned();
}

final class ReceptionistWorkChoose extends ReceptionistWorkState {
  const ReceptionistWorkChoose({
    required this.options,
    required this.assignmentTarget,
  });

  final List<WorkScopeOption> options;
  final AssignmentTarget assignmentTarget;
}

final class ReceptionistWorkReady extends ReceptionistWorkState {
  const ReceptionistWorkReady(this.selected);

  final WorkScopeOption selected;
}

final receptionistWorkProvider =
    NotifierProvider<ReceptionistWorkController, ReceptionistWorkState?>(
      ReceptionistWorkController.new,
    );

class ReceptionistWorkController extends Notifier<ReceptionistWorkState?> {
  AssignmentTarget? _assignmentTarget;
  List<WorkScopeOption>? _options;
  List<String>? _scopeIds;
  var _syncGeneration = 0;

  @override
  ReceptionistWorkState? build() => null;

  Future<void> syncSession(TabletSignIn? session) async {
    final generation = ++_syncGeneration;
    if (session == null || session.account.role != Role.receptionist) {
      _assignmentTarget = null;
      _options = null;
      _scopeIds = null;
      if (!ref.mounted) return;
      state = null;
      return;
    }
    if (!ref.mounted) return;
    state = const ReceptionistWorkLoading();
    final loaded = await ref
        .read(receptionistScopeServiceProvider)
        .load(session.account);
    if (!ref.mounted || generation != _syncGeneration) return;
    _assignmentTarget = loaded.assignmentTarget;
    _options = loaded.options;
    _scopeIds = loaded.scopeIds;
    if (loaded.options.isEmpty) {
      state = const ReceptionistWorkUnassigned();
      return;
    }
    state = switch (loaded.scopeIds.length) {
      1 =>
        loaded.options.length == 1
            ? ReceptionistWorkReady(loaded.options.single)
            : ReceptionistWorkChoose(
                options: loaded.options,
                assignmentTarget: loaded.assignmentTarget,
              ),
      _ => ReceptionistWorkChoose(
        options: loaded.options,
        assignmentTarget: loaded.assignmentTarget,
      ),
    };
  }

  void select(WorkScopeOption option) {
    state = ReceptionistWorkReady(option);
  }

  void reopenChoice() {
    final options = _options;
    final target = _assignmentTarget;
    if (options == null || target == null || (_scopeIds?.length ?? 0) <= 1) {
      return;
    }
    state = ReceptionistWorkChoose(options: options, assignmentTarget: target);
  }

  bool get canChangeWorkScope => (_scopeIds?.length ?? 0) > 1;
}
