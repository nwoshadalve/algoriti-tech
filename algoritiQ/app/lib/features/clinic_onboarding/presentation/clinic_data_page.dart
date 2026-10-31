// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/toast/toast_controller.dart';
import '../../../core/widgets/card_page.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/clinic_onboarding_controller.dart';

/// Restore a downloaded backup zip or continue with first-time clinic setup.
class ClinicDataPage extends ConsumerStatefulWidget {
  const ClinicDataPage({super.key});

  @override
  ConsumerState<ClinicDataPage> createState() => _ClinicDataPageState();
}

class _ClinicDataPageState extends ConsumerState<ClinicDataPage> {
  var _restoreBusy = false;

  Future<void> _restore() async {
    if (_restoreBusy) return;
    setState(() => _restoreBusy = true);
    await ref
        .read(clinicOnboardingControllerProvider.notifier)
        .restoreFromBackupZip();
    if (mounted) setState(() => _restoreBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen(clinicOnboardingControllerProvider, (previous, next) {
      if (next.hasError && mounted) {
        ref
            .read(toastControllerProvider.notifier)
            .error(l10n.clinicDataRestoreFailed);
      }
    });
    final theme = Theme.of(context);
    final startBusy = ref.watch(clinicOnboardingControllerProvider).isLoading;

    return CardPage(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.clinicDataTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.clinicDataIntro,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              LoadingButton(
                label: l10n.clinicDataStartNew,
                isLoading: startBusy && !_restoreBusy,
                onPressed: _restoreBusy
                    ? null
                    : () => ref
                          .read(clinicOnboardingControllerProvider.notifier)
                          .startNew(),
              ),
              const SizedBox(height: Spacing.sm),
              OutlinedButton(
                onPressed: startBusy || _restoreBusy ? null : _restore,
                child: _restoreBusy
                    ? Text(l10n.clinicDataRestoreBusy)
                    : Text(l10n.clinicDataRestore),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.clinicDataRestoreHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
