// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../data/sign_in_preference_store.dart';

/// Password vs PIN within the same sign-in section.
class SignInMethodSwitch extends StatelessWidget {
  const SignInMethodSwitch({
    super.key,
    required this.mode,
    required this.onChanged,
    required this.passwordLabel,
    required this.pinLabel,
    this.enabled = true,
  });

  final SignInMode mode;
  final ValueChanged<SignInMode> onChanged;
  final String passwordLabel;
  final String pinLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SignInMode>(
      segments: [
        ButtonSegment(value: SignInMode.password, label: Text(passwordLabel)),
        ButtonSegment(value: SignInMode.pin, label: Text(pinLabel)),
      ],
      selected: {mode},
      showSelectedIcon: false,
      onSelectionChanged: enabled
          ? (selection) => onChanged(selection.first)
          : null,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Spacing above the method switch inside the sign-in form.
const signInMethodSwitchGap = Spacing.md;
