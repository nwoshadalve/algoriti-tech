// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_colors.dart';

enum ConnectivityTone { good, waiting, problem }

/// Shared frame for a device on the connectivity page: icon, name, a status
/// pill (icon + word, never colour alone) and the device's own content.
class ConnectivityCard extends StatelessWidget {
  const ConnectivityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.statusLabel,
    required this.tone,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String statusLabel;
  final ConnectivityTone tone;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.6,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.sm + Spacing.xs),
                    child: Icon(icon, size: 24, color: scheme.primary),
                  ),
                ),
                const SizedBox(width: Spacing.sm + Spacing.xs),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Flexible(
                  child: StatusPill(label: statusLabel, tone: tone),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm + Spacing.xs),
            child,
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.tone});

  final String label;
  final ConnectivityTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (icon, color) = switch (tone) {
      ConnectivityTone.good => (
        Icons.check_circle_rounded,
        BrandColors.positive,
      ),
      ConnectivityTone.waiting => (
        Icons.schedule_rounded,
        scheme.onSurfaceVariant,
      ),
      ConnectivityTone.problem => (Icons.error_rounded, BrandColors.coral),
    };

    return Semantics(
      liveRegion: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm + Spacing.xs,
            vertical: Spacing.xs + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: Spacing.xs + 2),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
