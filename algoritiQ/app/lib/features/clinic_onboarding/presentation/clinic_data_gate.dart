// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/retry_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/access_providers.dart';
import '../../clinic/application/clinic_providers.dart';
import '../../clinic/domain/setup_stage.dart';
import '../application/clinic_onboarding_controller.dart';
import 'clinic_data_page.dart';

/// After permissions, asks whether to restore a saved backup or start a new clinic.
class ClinicDataGate extends ConsumerWidget {
  const ClinicDataGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chosen = ref.watch(clinicOnboardingChosenProvider);
    final stage = ref.watch(setupStageProvider);
    final doctors = ref.watch(doctorsProvider);
    final admins = ref.watch(adminCountProvider);

    if (chosen.hasError ||
        stage.hasError ||
        doctors.hasError ||
        admins.hasError) {
      return RetryView(
        message: AppLocalizations.of(context).setupLoadFailed,
        onRetry: () {
          ref.invalidate(clinicOnboardingChosenProvider);
          ref.invalidate(setupStageProvider);
          ref.invalidate(doctorsProvider);
          ref.invalidate(adminCountProvider);
        },
      );
    }

    if (chosen.isLoading ||
        !stage.hasValue ||
        !doctors.hasValue ||
        !admins.hasValue) {
      return const Scaffold();
    }

    final show =
        !chosen.requireValue &&
        stage.requireValue == SetupStage.profile &&
        admins.requireValue == 0 &&
        doctors.requireValue.isEmpty;

    return show ? const ClinicDataPage() : child;
  }
}
