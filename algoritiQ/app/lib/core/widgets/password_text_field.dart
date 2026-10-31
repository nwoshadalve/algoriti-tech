// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';

/// A password field with its label above it and a button to show or hide
/// what was typed. Same look as [LabeledTextField].
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;

  /// Guidance under the field while there is no error.
  final String? hint;
  final String? errorText;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hint = widget.hint;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            obscureText: !_visible,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onSubmitted == null
                ? null
                : (_) => widget.onSubmitted!(),
            decoration: InputDecoration(
              errorText: widget.errorText,
              helperText: widget.errorText == null ? hint : null,
              helperMaxLines: 3,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _visible = !_visible),
                tooltip: _visible
                    ? l10n.hidePasswordTooltip
                    : l10n.showPasswordTooltip,
                icon: Icon(
                  _visible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
