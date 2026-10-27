import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../application/access_providers.dart';

/// The claim code the admin types on the web app, with the time left and a
/// button for a new code. Updates every second; a new code appears by itself
/// when the old one expires or is used up.
class ClaimCodePanel extends ConsumerStatefulWidget {
  const ClaimCodePanel({super.key});

  @override
  ConsumerState<ClaimCodePanel> createState() => _ClaimCodePanelState();
}

class _ClaimCodePanelState extends ConsumerState<ClaimCodePanel> {
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
    final codes = ref.watch(claimCodesProvider);
    final code = codes.current();
    final left = code.expiresAt.difference(ref.watch(clockProvider)());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: code.display,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Spacing.md),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Spacing.md,
                horizontal: Spacing.sm,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SelectableText(
                  code.display,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.codeExpiresIn(_remaining(left)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(codes.refresh),
              child: Text(l10n.newCodeButton),
            ),
          ],
        ),
      ],
    );
  }
}
