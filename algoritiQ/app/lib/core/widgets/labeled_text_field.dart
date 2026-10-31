// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.maxLines = 1,
    this.hint,
    this.autocorrect = true,
    this.inputFormatters,
    this.obscureText = false,
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

  /// More than one line (for example a long key); the field grows to fit up
  /// to this many.
  final int maxLines;

  /// Guidance under the field while there is no error.
  final String? hint;

  /// Off for keys and codes, which no keyboard should "correct".
  final bool autocorrect;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;

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
            minLines: 1,
            maxLines: maxLines,
            autocorrect: autocorrect,
            enableSuggestions: autocorrect,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
            decoration: InputDecoration(
              errorText: errorText,
              helperText: errorText == null ? hint : null,
              helperMaxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
