import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';

/// The device code on a tinted row with a copy button.
class DeviceCodeRow extends StatelessWidget {
  const DeviceCodeRow({
    super.key,
    required this.label,
    required this.code,
    required this.copyLabel,
    required this.onCopy,
  });

  final String label;
  final String code;
  final String copyLabel;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Radii.field),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: Spacing.md,
              top: Spacing.xs,
              right: Spacing.xs,
              bottom: Spacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    code,
                    style: theme.textTheme.titleLarge?.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                IconButton.outlined(
                  onPressed: onCopy,
                  tooltip: copyLabel,
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
