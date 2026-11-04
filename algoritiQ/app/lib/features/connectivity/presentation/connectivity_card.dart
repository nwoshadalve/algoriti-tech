// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_colors.dart';

enum ConnectivityTone { good, waiting, problem }

/// The colour of a tone. Used for icons, tints and outlines only; words stay
/// in the normal text colour so they keep their contrast.
Color connectivityToneColor(BuildContext context, ConnectivityTone tone) =>
    switch (tone) {
      ConnectivityTone.good => BrandColors.positive,
      ConnectivityTone.waiting => Theme.of(
        context,
      ).colorScheme.onSurfaceVariant,
      ConnectivityTone.problem => BrandColors.coral,
    };

/// Size of the tone icon tile at the head of a device card.
const _tileSize = 56.0;

/// Shared frame for a device on the connectivity page: a tinted icon tile, the
/// device name with its status (icon + word, never colour alone), then the
/// device's own content. A working or broken device gets a tinted outline so
/// the state reads from across the room.
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
    final color = connectivityToneColor(context, tone);
    final outlined = tone != ConnectivityTone.waiting;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(
          color: outlined
              ? color.withValues(alpha: 0.55)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(Radii.field),
                  ),
                  child: SizedBox(
                    width: _tileSize,
                    height: _tileSize,
                    child: Icon(icon, size: 30, color: color),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      StatusPill(label: statusLabel, tone: tone),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
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
    final color = connectivityToneColor(context, tone);
    final icon = switch (tone) {
      ConnectivityTone.good => Icons.check_circle_rounded,
      ConnectivityTone.waiting => Icons.schedule_rounded,
      ConnectivityTone.problem => Icons.error_rounded,
    };
    return Semantics(
      liveRegion: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm + Spacing.xs,
            vertical: Spacing.xs,
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

/// A line of body text for a device card.
class ConnectivityBody extends StatelessWidget {
  const ConnectivityBody(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }
}

/// The device that is set up, as a rounded chip: its icon and name.
class ConnectivityDeviceChip extends StatelessWidget {
  const ConnectivityDeviceChip({
    super.key,
    required this.icon,
    required this.name,
  });

  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Radii.field),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
