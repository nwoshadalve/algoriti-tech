// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// "1 of 2 chambers" with one segment per chamber the license allows.
class ChamberQuota extends StatelessWidget {
  const ChamberQuota({super.key, required this.count, required this.limit});

  final int count;
  final int limit;

  /// Segments only make sense for a handful of chambers.
  static const _maxSegments = 8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = AppLocalizations.of(context).chamberQuota(count, limit);
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (limit <= _maxSegments) ...[
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                for (var i = 0; i < limit; i++) ...[
                  if (i > 0) const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: i < count
                            ? scheme.primary
                            : scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
