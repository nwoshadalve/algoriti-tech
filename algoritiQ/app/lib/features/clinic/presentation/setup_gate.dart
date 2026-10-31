// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/retry_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../licensing/application/license_controller.dart';
import '../../licensing/domain/license_payload.dart';
import '../../licensing/domain/license_state.dart';
import '../application/clinic_providers.dart';
import '../domain/setup_stage.dart';
import 'chambers_page.dart';
import 'profile_page.dart';
import 'ready_page.dart';

/// Shows [child] once first-time setup is done; until then the setup steps.
///
/// Only doctor licenses (one doctor, several chambers) have setup so far;
/// chamber licenses go straight to [child].
class SetupGate extends ConsumerWidget {
  const SetupGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final license = ref.watch(licenseControllerProvider).value;
    if (license is! Licensed || license.payload.type != LicenseType.doctor) {
      return child;
    }

    final stage = ref.watch(setupStageProvider);
    final doctors = ref.watch(doctorsProvider);
    final chambers = ref.watch(chambersProvider);
    if (stage.hasError || doctors.hasError || chambers.hasError) {
      return RetryView(
        message: AppLocalizations.of(context).setupLoadFailed,
        onRetry: () {
          ref.invalidate(setupStageProvider);
          ref.invalidate(doctorsProvider);
          ref.invalidate(chambersProvider);
        },
      );
    }
    final data = (stage.value, doctors.value, chambers.value);
    return switch (data) {
      (final stage?, final doctors?, final chambers?) => switch (stage) {
        SetupStage.profile => const ProfilePage(),
        // Chambers hang under the doctor; without one, back to the profile.
        SetupStage.chambers when doctors.isEmpty => const ProfilePage(),
        SetupStage.chambers => ChambersPage(
          doctorId: doctors.first.id,
          chambers: chambers,
        ),
        SetupStage.ready => ReadyPage(
          doctor: doctors.isEmpty ? null : doctors.first,
          chambers: chambers,
        ),
        SetupStage.done => child,
      },
      // Checked in a blink: an empty themed screen, no loader after the launch
      // screen.
      _ => const Scaffold(),
    };
  }
}
