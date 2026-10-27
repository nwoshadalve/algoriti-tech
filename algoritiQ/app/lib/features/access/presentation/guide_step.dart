import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';

/// One numbered step of the admin guide: a round number, a title and the
/// step's content, on a panel one shade off the card so the steps read as
/// separate things.
class GuideStep extends StatelessWidget {
  const GuideStep({
    super.key,
    required this.number,
    required this.title,
    required this.child,
    this.compact = false,
  });

  final int number;
  final String title;
  final Widget child;

  /// Tighter padding, for screens that are short (wide landscape).
  final bool compact;

  static const _badgeSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final digits = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    ).format(number);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? Spacing.sm + Spacing.xs : Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              label: '$digits. $title',
              excludeSemantics: true,
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: _badgeSize,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.onSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          digits,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.surface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleSmall),
                  ),
                ],
              ),
            ),
            SizedBox(height: compact ? Spacing.sm : Spacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
