// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import 'brand_loader.dart';

/// Primary call-to-action button that swaps its label for [BrandLoader]
/// while [isLoading].
///
/// Keeps its size and enabled look while loading (no layout jump, no grey
/// flash) but ignores taps, so an action can't be fired twice. Reuse it for
/// any button that starts async work.
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.loadingLabel,
  });

  final String label;

  /// Null disables the button (unless it is loading).
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Announced to screen readers while loading, e.g. "Activating…".
  final String? loadingLabel;

  static void _ignore() {}

  @override
  Widget build(BuildContext context) {
    // The button's label colour, so the dots follow the theme's button style.
    final foreground =
        FilledButtonTheme.of(context).style?.foregroundColor?.resolve({}) ??
        Theme.of(context).colorScheme.onPrimary;
    return FilledButton(
      onPressed: isLoading && onPressed != null ? _ignore : onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Stays in layout so the button width doesn't change.
          Visibility(
            visible: !isLoading,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Text(label, textAlign: TextAlign.center),
          ),
          if (isLoading)
            BrandLoader(
              color: foreground,
              idleColor: foreground.withValues(alpha: 0.4),
              semanticLabel: loadingLabel ?? label,
            ),
        ],
      ),
    );
  }
}
