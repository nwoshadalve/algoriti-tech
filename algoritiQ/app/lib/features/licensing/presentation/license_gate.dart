// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/retry_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/license_controller.dart';
import '../domain/license_state.dart';
import 'activation_page.dart';

/// Shows [child] only on a licensed device; otherwise the activation screen.
class LicenseGate extends ConsumerWidget {
  const LicenseGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final license = ref.watch(licenseControllerProvider);
    return license.when(
      // Checked in a blink: an empty themed screen, no loader after the
      // launch screen.
      loading: () => const Scaffold(),
      error: (_, _) => RetryView(
        message: AppLocalizations.of(context).deviceUnavailable,
        onRetry: () => ref.invalidate(licenseControllerProvider),
      ),
      data: (state) => switch (state) {
        Licensed() => child,
        Unlicensed() => ActivationPage(state: state),
      },
    );
  }
}
