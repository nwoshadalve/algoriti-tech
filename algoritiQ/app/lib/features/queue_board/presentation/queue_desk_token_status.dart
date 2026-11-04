// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/board_models.dart';

String queueDeskStatusLabel(AppLocalizations l10n, TokenStatus status) =>
    switch (status) {
      TokenStatus.waiting => l10n.deskStatusWaiting,
      TokenStatus.called => l10n.deskStatusCalled,
      TokenStatus.entered => l10n.deskStatusEntered,
      TokenStatus.skipped => l10n.deskStatusMissed,
      TokenStatus.cancelled => l10n.deskStatusCancelled,
    };

Color _statusColor(ColorScheme scheme, TokenStatus status) => switch (status) {
  TokenStatus.waiting => scheme.onSurfaceVariant,
  TokenStatus.called => scheme.primary,
  TokenStatus.entered => BrandColors.positive,
  TokenStatus.skipped => scheme.error,
  TokenStatus.cancelled => scheme.outline,
};

/// The queue status as a labelled pill (the word always carries the meaning;
/// the colour only helps).
class DeskTokenStatusCell extends StatelessWidget {
  const DeskTokenStatusCell({super.key, required this.token});

  final BoardTokenView token;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color = _statusColor(theme.colorScheme, token.status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Radii.field),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        // One line always: a long word (Cancelled, a translation) shrinks
        // a little rather than breaking in two.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            queueDeskStatusLabel(l10n, token.status),
            maxLines: 1,
            softWrap: false,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
