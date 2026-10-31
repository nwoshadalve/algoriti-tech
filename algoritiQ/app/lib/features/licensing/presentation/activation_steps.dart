// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/widgets/step_progress.dart';
import '../../../l10n/app_localizations.dart';

/// Where the user is in getting a device activated.
enum ActivationStep { copyCode, getKey, enterKey }

class ActivationStepper extends StatelessWidget {
  const ActivationStepper({super.key, required this.current});

  final ActivationStep current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StepProgress(
      labels: [
        l10n.activationStepCopy,
        l10n.activationStepGet,
        l10n.activationStepEnter,
      ],
      current: current.index,
    );
  }
}
