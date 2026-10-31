// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../l10n/app_localizations.dart';
import 'degrees_field.dart';
import 'profile_controllers.dart';
import 'setup_card.dart';

/// The doctor profile form. Only the name is required; the rest is shown on
/// the TV when filled in.
///
/// Narrow: one column. Wide (landscape): a three-column grid with compact
/// fields, so the whole form fits a short screen:
///
/// ```text
/// photo        name          designation
/// hospital     registration  specialty
/// degrees (two columns wide) back / continue
/// ```
class ProfileFields extends StatelessWidget {
  const ProfileFields({
    super.key,
    required this.controllers,
    required this.degrees,
    required this.enabled,
    required this.errors,
    required this.onDegreesChanged,
    required this.photo,
    required this.action,
  });

  final ProfileControllers controllers;
  final List<String> degrees;
  final bool enabled;
  final ProfileErrors errors;
  final ValueChanged<List<String>> onDegreesChanged;

  /// Builds the photo field; `true` asks for the compact version.
  final Widget Function(bool compact) photo;

  /// The Continue button (and any message).
  final Widget action;

  static const _gap = Spacing.md;
  static const _rowGap = Spacing.sm;

  /// Lines the action up with the degrees input, below the input's label.
  static const _actionTopOffset = 22.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = SetupCard.isWide(constraints.maxWidth);
        final fields = _Fields(
          controllers: controllers,
          enabled: enabled,
          errors: errors,
          compact: wide,
        );
        final degreesField = DegreesField(
          degrees: degrees,
          enabled: enabled,
          errorText: errors.degrees,
          onChanged: onDegreesChanged,
          compact: wide,
        );
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              photo(false),
              const SizedBox(height: _rowGap),
              fields.name,
              const SizedBox(height: _rowGap),
              degreesField,
              for (final field in fields.details) ...[
                const SizedBox(height: _rowGap),
                field,
              ],
              const SizedBox(height: _rowGap),
              action,
            ],
          );
        }
        final column = (constraints.maxWidth - 2 * _gap) / 3;
        Widget cell(Widget child, {int span = 1}) =>
            SizedBox(width: column * span + _gap * (span - 1), child: child);
        Widget row(List<Widget> cells) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, c) in cells.indexed) ...[
              if (i > 0) const SizedBox(width: _gap),
              c,
            ],
          ],
        );
        return Column(
          children: [
            row([
              cell(photo(true)),
              cell(fields.name),
              cell(fields.details[0]),
            ]),
            const SizedBox(height: _rowGap),
            row([
              cell(fields.details[1]),
              cell(fields.details[2]),
              cell(fields.details[3]),
            ]),
            const SizedBox(height: _rowGap),
            row([
              cell(degreesField, span: 2),
              cell(
                Padding(
                  padding: const EdgeInsets.only(top: _actionTopOffset),
                  child: action,
                ),
              ),
            ]),
          ],
        );
      },
    );
  }
}

/// Messages for the required profile fields that were left blank.
class ProfileErrors {
  const ProfileErrors({
    this.name,
    this.designation,
    this.degrees,
    this.specialty,
  });

  final String? name;
  final String? designation;
  final String? degrees;
  final String? specialty;
}

/// The plain text fields, built once and placed by the layout.
class _Fields {
  _Fields({
    required this.controllers,
    required this.enabled,
    required this.errors,
    required this.compact,
  });

  final ProfileControllers controllers;
  final bool enabled;
  final ProfileErrors errors;
  final bool compact;

  Widget get name => Builder(
    builder: (context) => LabeledTextField(
      label: AppLocalizations.of(context).doctorNameLabel,
      controller: controllers.name,
      enabled: enabled,
      errorText: errors.name,
      textInputAction: TextInputAction.next,
      compact: compact,
    ),
  );

  /// Designation, hospital, registration number, specialty (in that order).
  List<Widget> get details => [
    _field(
      (l) => l.designationLabel,
      controllers.designation,
      error: errors.designation,
    ),
    _field((l) => l.workplaceLabel, controllers.workplace),
    _field(
      (l) => l.registrationLabel,
      controllers.registration,
      capitalization: TextCapitalization.characters,
    ),
    _field(
      (l) => l.specialtyLabel,
      controllers.specialty,
      error: errors.specialty,
      last: true,
    ),
  ];

  Widget _field(
    String Function(AppLocalizations) label,
    TextEditingController controller, {
    String? error,
    TextCapitalization capitalization = TextCapitalization.words,
    bool last = false,
  }) => Builder(
    builder: (context) => LabeledTextField(
      label: label(AppLocalizations.of(context)),
      controller: controller,
      enabled: enabled,
      errorText: error,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      capitalization: capitalization,
      compact: compact,
    ),
  );
}
