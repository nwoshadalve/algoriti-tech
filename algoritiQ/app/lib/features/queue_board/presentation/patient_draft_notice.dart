// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// Tells that what was typed is kept as a draft, and lets the person throw it
/// away. Shows nothing while the form is as it was saved.
class PatientDraftNotice extends StatelessWidget {
  const PatientDraftNotice({
    super.key,
    required this.visible,
    required this.restored,
    required this.onDiscard,
    this.enabled = true,
  });

  /// There is something typed that is not saved.
  final bool visible;

  /// The form was filled from a draft when it opened.
  final bool restored;
  final VoidCallback onDiscard;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.sm + Spacing.xs,
            Spacing.xs,
            Spacing.xs,
            Spacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  restored ? l10n.draftRestored : l10n.draftKept,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              TextButton(
                onPressed: enabled ? onDiscard : null,
                child: Text(l10n.draftDiscard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
