import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/step_progress.dart';
import '../../../l10n/app_localizations.dart';

/// Card shared by every setup step.
///
/// Narrow (portrait): title, intro, step progress, then the [body], stacked.
/// Wide (landscape): one slim header row (title left, step progress right)
/// and the [body] below using the full width, so a step fits a short screen.
/// Bodies choose their own wide layout with [SetupCard.isWide].
class SetupCard extends StatelessWidget {
  const SetupCard({
    super.key,
    required this.step,
    required this.title,
    required this.intro,
    required this.body,
  });

  /// Zero-based setup step (profile 0, chambers 1, ready 2; 3 = all done).
  final int step;
  final String title;
  final String intro;
  final Widget body;

  /// Card width from which the wide layout is used.
  static const _wideCardWidth = 648.0;

  /// Body width from which a body should use its wide (grid) layout.
  static const wideBodyWidth = 640.0;

  /// Whether a body that is [width] wide should use its wide layout.
  static bool isWide(double width) => width >= wideBodyWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final labels = [
      l10n.setupStepProfile,
      l10n.setupStepChambers,
      l10n.setupStepReady,
    ];

    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _wideCardWidth) {
            return Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Spacing.lg),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: StepProgress(
                            labels: labels,
                            current: step,
                            dense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  body,
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: Spacing.sm),
                Text(
                  intro,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                StepProgress(labels: labels, current: step),
                const SizedBox(height: Spacing.lg),
                body,
              ],
            ),
          );
        },
      ),
    );
  }
}
