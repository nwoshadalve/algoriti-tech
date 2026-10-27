import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';

/// "Step 2 of 3 · name" with one bar per step, like the website's strip.
class ResetProgress extends StatelessWidget {
  const ResetProgress({super.key, required this.current, required this.labels});

  /// 1-based.
  final int current;
  final List<String> labels;

  static const _barHeight = 6.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label:
          '${l10n.resetStepOf(current, labels.length)}. ${labels[current - 1]}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const SizedBox(width: Spacing.xs + 2),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_barHeight),
                      color: i + 1 == current
                          ? BrandColors.coral
                          : i + 1 < current
                          ? scheme.onSurface
                          : scheme.outlineVariant,
                    ),
                    child: const SizedBox(height: _barHeight),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            '${l10n.resetStepOf(current, labels.length)} · ${labels[current - 1]}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
