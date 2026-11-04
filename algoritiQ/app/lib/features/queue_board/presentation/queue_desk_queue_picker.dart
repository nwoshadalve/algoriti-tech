// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/board_models.dart';
import 'queue_desk_dialog_layout.dart';
import 'queue_desk_format.dart';

/// Choose the queue a token goes into: one tappable option per queue showing
/// its name and how many are waiting. The chosen one is filled and ticked, so
/// the choice never rests on colour alone.
class DeskQueuePicker extends StatelessWidget {
  const DeskQueuePicker({
    super.key,
    required this.controls,
    required this.selectedId,
    required this.onSelected,
    this.enabled = true,
    this.errorText,
  });

  final List<QueueTypeBoardControl> controls;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${l10n.deskFieldQueue} *', style: deskFormLabelStyle(context)),
        const SizedBox(height: Spacing.xs),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (final control in controls)
              _QueueOption(
                name: queueDeskQueueName(locale, control),
                waiting: l10n.deskWaitingShort(
                  queueDeskFormatSerial(control.waitingCount, locale),
                ),
                selected: control.queueTypeId == selectedId,
                onTap: enabled ? () => onSelected(control.queueTypeId) : null,
              ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _QueueOption extends StatelessWidget {
  const _QueueOption({
    required this.name,
    required this.waiting,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String waiting;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = BorderRadius.circular(Radii.field);
    return Semantics(
      button: true,
      selected: selected,
      label: '$name, $waiting',
      excludeSemantics: true,
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: shape,
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: shape,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 120),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Icon(Icons.check, size: 18, color: scheme.primary),
                    const SizedBox(width: Spacing.sm),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        waiting,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
