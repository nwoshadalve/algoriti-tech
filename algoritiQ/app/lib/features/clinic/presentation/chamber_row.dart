// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/chamber.dart';

/// One chamber in a list. Shows an edit button when [onEdit] is given.
class ChamberRow extends StatelessWidget {
  const ChamberRow({
    super.key,
    required this.chamber,
    this.onEdit,
    this.editTooltip,
  });

  final Chamber chamber;
  final VoidCallback? onEdit;
  final String? editTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final location = chamber.location;
    final phone = chamber.phone;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Radii.field),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.sm,
          Spacing.sm,
          Spacing.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.local_hospital_outlined, color: scheme.onSurface),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chamber.name, style: theme.textTheme.titleSmall),
                  for (final line in [?location, ?phone])
                    Text(
                      line,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                tooltip: editTooltip,
                icon: const Icon(Icons.edit_outlined),
              ),
          ],
        ),
      ),
    );
  }
}
