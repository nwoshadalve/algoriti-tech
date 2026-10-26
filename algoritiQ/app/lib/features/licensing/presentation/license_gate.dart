import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_loader.dart';
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
      loading: () => const _Checking(),
      error: (_, _) => _DeviceError(
        onRetry: () => ref.invalidate(licenseControllerProvider),
      ),
      data: (state) => switch (state) {
        Licensed() => child,
        Unlicensed() => ActivationPage(state: state),
      },
    );
  }
}

class _DeviceError extends StatelessWidget {
  const _DeviceError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.deviceUnavailable),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.retryButton)),
          ],
        ),
      ),
    );
  }
}

/// Shown while the stored license is checked, so the screen is never blank.
class _Checking extends StatelessWidget {
  const _Checking();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BrandLoader(
          size: 48,
          accentColor: BrandColors.coral,
          color: Theme.of(context).colorScheme.primary,
          semanticLabel: AppLocalizations.of(context).loading,
        ),
      ),
    );
  }
}
