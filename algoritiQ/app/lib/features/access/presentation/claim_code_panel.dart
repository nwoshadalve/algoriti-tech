// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../application/access_providers.dart';

/// The claim code the admin types on the web app, like a queue token: the
/// code large on a ticket, a bar that runs down with the time left, and a
/// button for a new code. Updates every second; a new code appears by itself
/// when the old one expires or is used up.
class ClaimCodePanel extends ConsumerStatefulWidget {
  const ClaimCodePanel({super.key, this.compact = false});

  /// Tighter spacing, for screens that are short (wide landscape).
  final bool compact;

  @override
  ConsumerState<ClaimCodePanel> createState() => _ClaimCodePanelState();
}

class _ClaimCodePanelState extends ConsumerState<ClaimCodePanel> {
  static const _barHeight = 5.0;

  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _remaining(Duration left) {
    final seconds = left.inSeconds.clamp(0, 24 * 3600);
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final codes = ref.watch(claimCodesProvider);
    final code = codes.current();
    final left = code.expiresAt.difference(ref.watch(clockProvider)());
    final gap = widget.compact ? Spacing.sm : Spacing.md;
    final fraction = (left.inMilliseconds / codes.lifetime.inMilliseconds)
        .clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: code.display,
          // The time left runs down along the bottom edge of the ticket.
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(Radii.field),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.field - 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: gap,
                      horizontal: Spacing.sm,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SelectableText(
                        code.display,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                  LinearProgressIndicator(
                    value: fraction,
                    minHeight: _barHeight,
                    color: BrandColors.coral,
                    backgroundColor: scheme.outlineVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        // A Wrap, not a Row: with large text the button drops below the time
        // instead of overflowing.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Spacing.sm,
          children: [
            Text(
              l10n.codeExpiresIn(_remaining(left)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            OutlinedButton(
              onPressed: () => setState(codes.refresh),
              child: Text(l10n.newCodeButton),
            ),
          ],
        ),
      ],
    );
  }
}
