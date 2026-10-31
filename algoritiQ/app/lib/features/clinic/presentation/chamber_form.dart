// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../l10n/app_localizations.dart';

/// Name, address and phone fields (all required) with the add / save and
/// cancel buttons. Wide: two rows with compact fields and the button beside
/// the phone. Narrow: stacked.
class ChamberForm extends StatelessWidget {
  const ChamberForm({
    super.key,
    required this.name,
    required this.location,
    required this.phone,
    required this.busy,
    required this.isEditing,
    required this.nameError,
    required this.locationError,
    required this.phoneError,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController name;
  final TextEditingController location;
  final TextEditingController phone;
  final bool busy;
  final bool isEditing;
  final String? nameError;
  final String? locationError;
  final String? phoneError;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  static const _wideWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideWidth;
        final nameField = LabeledTextField(
          label: l10n.chamberNameLabel,
          controller: name,
          enabled: !busy,
          errorText: nameError,
          textInputAction: TextInputAction.next,
          compact: wide,
        );
        final locationField = LabeledTextField(
          label: l10n.chamberLocationLabel,
          controller: location,
          enabled: !busy,
          errorText: locationError,
          textInputAction: TextInputAction.next,
          compact: wide,
        );
        final phoneField = LabeledTextField(
          label: l10n.chamberPhoneLabel,
          controller: phone,
          enabled: !busy,
          errorText: phoneError,
          textInputAction: TextInputAction.done,
          onSubmitted: onSubmit,
          keyboardType: TextInputType.phone,
          compact: wide,
        );
        final submit = OutlinedButton(
          onPressed: busy ? null : onSubmit,
          child: Text(
            isEditing ? l10n.saveChamberButton : l10n.addChamberButton,
            textAlign: TextAlign.center,
          ),
        );
        final cancel = isEditing
            ? TextButton(
                onPressed: busy ? null : onCancel,
                child: Text(l10n.cancelEditButton),
              )
            : null;

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              nameField,
              const SizedBox(height: Spacing.md),
              locationField,
              const SizedBox(height: Spacing.md),
              phoneField,
              const SizedBox(height: Spacing.md),
              submit,
              ?cancel,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: nameField),
                const SizedBox(width: Spacing.md),
                Expanded(child: locationField),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: phoneField),
                const SizedBox(width: Spacing.md),
                Expanded(child: submit),
              ],
            ),
            ?cancel,
          ],
        );
      },
    );
  }
}
