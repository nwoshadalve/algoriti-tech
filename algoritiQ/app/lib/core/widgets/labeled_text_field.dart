import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Text field with its label above it, as used across forms. No example
/// text inside: the label says what goes here.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.errorText,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.capitalization = TextCapitalization.words,
    this.keyboardType,
    this.compact = false,
  });

  final String label;
  final TextEditingController controller;
  final String? errorText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final TextCapitalization capitalization;
  final TextInputType? keyboardType;

  /// Smaller label and tighter gap, for short (landscape) screens.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                (compact
                        ? theme.textTheme.labelMedium
                        : theme.textTheme.labelLarge)
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: compact ? Spacing.xs : Spacing.sm),
          TextField(
            controller: controller,
            enabled: enabled,
            textCapitalization: capitalization,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
            decoration: InputDecoration(errorText: errorText),
          ),
        ],
      ),
    );
  }
}
