// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/card_page.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/user_management_service.dart';
import '../application/receptionist_scope_service.dart';

/// Receptionist picks a chamber or doctor before opening the board.
class WorkScopeSelectPage extends StatelessWidget {
  const WorkScopeSelectPage({
    super.key,
    required this.options,
    required this.assignmentTarget,
    required this.onSelected,
  });

  final List<WorkScopeOption> options;
  final AssignmentTarget assignmentTarget;
  final ValueChanged<WorkScopeOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final intro = assignmentTarget == AssignmentTarget.chamber
        ? l10n.workScopeIntroChamber
        : l10n.workScopeIntroDoctor;

    return CardPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.workScopeTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: Spacing.sm),
          Text(
            intro,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          for (final option in options) ...[
            _ScopeChoiceTile(option: option, onTap: () => onSelected(option)),
            const SizedBox(height: Spacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ScopeChoiceTile extends StatelessWidget {
  const _ScopeChoiceTile({required this.option, required this.onTap});

  final WorkScopeOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: option.name,
      child: Material(
        color: scheme.surface,
        elevation: 1,
        shadowColor: scheme.shadow.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (option.detail != null &&
                          option.detail!.trim().isNotEmpty) ...[
                        const SizedBox(height: Spacing.xs),
                        Text(
                          option.detail!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
