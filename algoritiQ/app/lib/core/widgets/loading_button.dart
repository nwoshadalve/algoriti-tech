import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
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
    this.icon,
  });

  final String label;

  /// Null disables the button (unless it is loading).
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Announced to screen readers while loading, e.g. "Activating…".
  final String? loadingLabel;
  final IconData? icon;

  static void _ignore() {}

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(label, textAlign: TextAlign.center)),
                if (icon != null) ...[
                  const SizedBox(width: Spacing.sm),
                  Icon(icon, size: 20),
                ],
              ],
            ),
          ),
          if (isLoading)
            BrandLoader(size: 24, semanticLabel: loadingLabel ?? label),
        ],
      ),
    );
  }
}
