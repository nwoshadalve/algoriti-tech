// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// The bottom row of a setup step: an outlined Back button (when there is a
/// previous step) beside the main [primary] button. Both are the same height.
class StepActions extends StatelessWidget {
  const StepActions({super.key, required this.primary, this.onBack});

  final Widget primary;

  /// Null on the first step.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final onBack = this.onBack;
    if (onBack == null) return primary;
    return Row(
      children: [
        OutlinedButton(
          onPressed: onBack,
          child: Text(AppLocalizations.of(context).backButton),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(child: primary),
      ],
    );
  }
}
