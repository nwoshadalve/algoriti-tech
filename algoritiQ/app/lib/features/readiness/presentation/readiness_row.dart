import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/readiness_item.dart';
import 'readiness_status_icon.dart';

/// One item of the checklist: status icon, title, body, and a trailing action.
class ReadinessRow extends StatelessWidget {
  const ReadinessRow({
    super.key,
    required this.item,
    required this.title,
    required this.body,
    this.action,
  });

  final ReadinessItem item;
  final String title;
  final String body;

  /// Shown on the right when something can still be fixed.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final stateText = switch (item.state) {
      ReadinessState.done => l10n.readinessStateDone,
      ReadinessState.needed => l10n.readinessStateNeeded,
      ReadinessState.unconfirmed => l10n.readinessStateUnconfirmed,
    };

    return Semantics(
      container: true,
      label: '$title. $stateText. $body',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(Radii.field),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.sm,
            Spacing.sm,
            Spacing.xs,
            Spacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: ReadinessStatusIcon(state: item.state),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    Text(
                      body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ?action,
            ],
          ),
        ),
      ),
    );
  }
}
