// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/widgets/labeled_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/board_models.dart';
import 'queue_desk_dialog_layout.dart';

/// The patient's own details, shared by the new-patient and edit-patient
/// popups: names, phone, age and gender. Required fields show "Required"
/// once [showErrors] is on and they are empty.
class DeskPatientFields extends StatelessWidget {
  const DeskPatientFields({
    super.key,
    required this.bengaliName,
    required this.englishName,
    required this.phone,
    required this.age,
    required this.gender,
    required this.onGender,
    this.enabled = true,
    this.showErrors = false,
  });

  final TextEditingController bengaliName;
  final TextEditingController englishName;
  final TextEditingController phone;
  final TextEditingController age;
  final PatientGender? gender;
  final ValueChanged<PatientGender?> onGender;
  final bool enabled;
  final bool showErrors;

  String? _required(TextEditingController c, AppLocalizations l10n) =>
      showErrors && c.text.trim().isEmpty ? l10n.deskFieldRequired : null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        deskFormRow([
          LabeledTextField(
            compact: true,
            label: '${l10n.deskFieldBengaliName} *',
            controller: bengaliName,
            errorText: _required(bengaliName, l10n),
            enabled: enabled,
          ),
          LabeledTextField(
            compact: true,
            label: l10n.deskFieldEnglishName,
            controller: englishName,
            enabled: enabled,
          ),
        ]),
        deskFormFieldSpacer(),
        deskFormRow([
          LabeledTextField(
            compact: true,
            label: '${l10n.fieldPhone} *',
            controller: phone,
            errorText: _required(phone, l10n),
            keyboardType: TextInputType.phone,
            enabled: enabled,
          ),
          LabeledTextField(
            compact: true,
            label: l10n.deskFieldAge,
            controller: age,
            keyboardType: TextInputType.number,
            enabled: enabled,
          ),
        ]),
        deskFormFieldSpacer(),
        DeskLabeledDropdown<PatientGender?>(
          label: l10n.deskFieldGender,
          enabled: enabled,
          // "Prefer not to say" is the same as not set; one entry covers both.
          value: gender == PatientGender.notStated ? null : gender,
          onSelected: onGender,
          entries: [
            DropdownMenuEntry(value: null, label: l10n.deskGenderUnset),
            DropdownMenuEntry(
              value: PatientGender.male,
              label: l10n.deskGenderMale,
            ),
            DropdownMenuEntry(
              value: PatientGender.female,
              label: l10n.deskGenderFemale,
            ),
            DropdownMenuEntry(
              value: PatientGender.other,
              label: l10n.deskGenderOther,
            ),
          ],
        ),
      ],
    );
  }
}
