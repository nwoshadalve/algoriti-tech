// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// Why the browser warns about the connection, and the certificate
/// fingerprint to compare with the one the browser shows. Side by side on a
/// [wide] panel, stacked on a narrow one.
class CertificateNote extends StatelessWidget {
  const CertificateNote({
    super.key,
    required this.fingerprint,
    required this.wide,
  });

  final String fingerprint;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    final note = Text(l10n.certNote, style: muted);
    final tile = DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(Radii.field),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.certFingerprintLabel, style: muted),
                  SelectableText(
                    _twoLines(fingerprint),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          note,
          const SizedBox(height: Spacing.sm),
          tile,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 5, child: note),
        const SizedBox(width: Spacing.md),
        Expanded(flex: 6, child: tile),
      ],
    );
  }

  /// `AA:BB:…` in two even lines, so it never breaks in the middle of a pair.
  static String _twoLines(String fingerprint) {
    final pairs = fingerprint.split(':');
    final half = (pairs.length + 1) ~/ 2;
    return '${pairs.take(half).join(':')}\n${pairs.skip(half).join(':')}';
  }
}
