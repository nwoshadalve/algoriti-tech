// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'connectivity_card.dart';

/// Placeholder until the TV display is built.
class TvCard extends StatelessWidget {
  const TvCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ConnectivityCard(
      icon: Icons.tv_rounded,
      title: l10n.tvTitle,
      statusLabel: l10n.tvStatus,
      tone: ConnectivityTone.waiting,
      child: Text(
        l10n.tvBody,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
