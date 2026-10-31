// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/brand_colors.dart';
import 'toast_controller.dart';

/// Widest a toast gets on a tablet; on a phone it spans the screen.
const _toastMaxWidth = 420.0;

/// Touch target of the close control (48 dp minimum).
const _closeTarget = 48.0;

/// Draws the toaster above the whole app. Mount once, in `MaterialApp.builder`.
class ToastHost extends ConsumerWidget {
  const ToastHost({super.key, required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.watch(toastControllerProvider);
    return Stack(
      children: [
        ?child,
        if (toasts.isNotEmpty)
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _toastMaxWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final toast in toasts)
                          Padding(
                            key: ValueKey(toast.id),
                            padding: const EdgeInsets.only(top: Spacing.sm),
                            child: _ToastCard(
                              toast: toast,
                              onClose: () => ref
                                  .read(toastControllerProvider.notifier)
                                  .dismiss(toast.id),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({required this.toast, required this.onClose});

  final ToastMessage toast;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final (icon, accent) = switch (toast.kind) {
      ToastKind.success => (Icons.check_circle_rounded, BrandColors.positive),
      ToastKind.error => (Icons.error_rounded, BrandColors.coral),
      ToastKind.info => (Icons.info_rounded, scheme.onSurfaceVariant),
    };

    return Semantics(
      liveRegion: true,
      container: true,
      child: Material(
        color: scheme.surface,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Radii.field),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.field),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: Spacing.md,
              top: Spacing.xs,
              bottom: Spacing.xs,
              right: Spacing.xs,
            ),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 22),
                const SizedBox(width: Spacing.sm + Spacing.xs),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                    child: Text(
                      toast.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: l10n.toastDismiss,
                  excludeSemantics: true,
                  child: InkResponse(
                    onTap: onClose,
                    radius: Spacing.lg,
                    child: const SizedBox.square(
                      dimension: _closeTarget,
                      child: Icon(Icons.close_rounded, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
