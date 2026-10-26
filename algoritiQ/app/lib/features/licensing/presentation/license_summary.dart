import '../domain/license_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/license_controller.dart';
import '../domain/license_state.dart';

/// Compact license info: type, limits, expiry (and a notice during grace).
class LicenseSummary extends ConsumerWidget {
  const LicenseSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(licenseControllerProvider).value;
    if (state is! Licensed) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final payload = state.payload;
    final expiresAt = payload.expiresAt;

    final summary = switch (payload.type) {
      LicenseType.doctor => l10n.licenseSummaryDoctor(payload.maxChambers),
      LicenseType.chamber => l10n.licenseSummaryChamber(payload.maxDoctors),
    };
    final validity = expiresAt == null
        ? l10n.licenseNoExpiry
        : l10n.licenseValidUntil(expiresAt);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(summary, style: theme.textTheme.bodyMedium),
        Text(validity, style: theme.textTheme.bodySmall),
        if (state.status == LicenseStatus.grace)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.licenseGraceNotice,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
      ],
    );
  }
}
