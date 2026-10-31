// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/breakpoints.dart';
import '../../../core/widgets/page_header.dart';
import '../../../l10n/app_localizations.dart';
import 'printer_card.dart';
import 'tv_card.dart';

/// Receptionist connectivity page: printer now, TV screen later. One column in
/// portrait, side by side in landscape.
class ConnectivityPage extends ConsumerWidget {
  const ConnectivityPage({super.key});

  static const _maxContent = 1152.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide =
            constraints.maxWidth >= Breakpoints.twoColumn + 2 * Spacing.md;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.md,
            Spacing.md,
            Spacing.lg + MediaQuery.paddingOf(context).bottom,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    title: l10n.connectivityTitle,
                    description: l10n.connectivityIntro,
                  ),
                  if (sideBySide)
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: PrinterCard()),
                        SizedBox(width: Spacing.md),
                        Expanded(child: TvCard()),
                      ],
                    )
                  else ...const [
                    PrinterCard(),
                    SizedBox(height: Spacing.md),
                    TvCard(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
