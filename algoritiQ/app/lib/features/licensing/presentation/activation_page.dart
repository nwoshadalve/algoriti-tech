// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/card_page.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/license_state.dart';
import 'activation_card.dart';

/// Shown until a valid license for this device is entered.
class ActivationPage extends StatelessWidget {
  const ActivationPage({super.key, required this.state});

  final Unlicensed state;

  @override
  Widget build(BuildContext context) {
    return CardPage(
      footer: const _Footer(),
      child: ActivationCard(
        state: state,
        twoColumn: CardPage.isTwoColumn(context),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline_rounded, size: 16, color: color),
        const SizedBox(width: Spacing.sm),
        Flexible(
          child: Text(
            AppLocalizations.of(context).activationFooter,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
