// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_dialog.dart';

/// Wider cap than default popups so desk forms can use two columns.
const deskDialogMaxWidth = 720.0;

/// Vertical gap between every field row in desk popups.
const deskFormFieldGap = Spacing.sm;

/// Matches dense [TextField] and [DropdownButtonFormField] height in desk forms.
const deskFormControlHeight = 40.0;

const _deskInputPadding = EdgeInsets.symmetric(
  horizontal: Spacing.sm,
  vertical: 10,
);

const _deskButtonHeight = 36.0;
const _deskButtonFontSize = 13.0;

ButtonStyle deskDialogFilledButtonStyle(BuildContext context) =>
    FilledButton.styleFrom(
      minimumSize: const Size(0, _deskButtonHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      textStyle: const TextStyle(
        fontSize: _deskButtonFontSize,
        fontWeight: FontWeight.w600,
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

ButtonStyle deskDialogOutlinedButtonStyle(BuildContext context) =>
    OutlinedButton.styleFrom(
      minimumSize: const Size(0, _deskButtonHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      textStyle: const TextStyle(
        fontSize: _deskButtonFontSize,
        fontWeight: FontWeight.w600,
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

ButtonStyle deskDialogTextButtonStyle(BuildContext context) =>
    TextButton.styleFrom(
      minimumSize: const Size(0, _deskButtonHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.sm,
      ),
      textStyle: const TextStyle(
        fontSize: _deskButtonFontSize,
        fontWeight: FontWeight.w600,
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

/// Dense inputs and desk-sized footer buttons, matching [queue_desk_panel].
class DeskFormDialog extends StatelessWidget {
  const DeskFormDialog({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  final String title;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          isDense: true,
          contentPadding: _deskInputPadding,
          constraints: const BoxConstraints(minHeight: deskFormControlHeight),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: deskDialogFilledButtonStyle(context),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: deskDialogOutlinedButtonStyle(context),
        ),
        textButtonTheme: TextButtonThemeData(
          style: deskDialogTextButtonStyle(context),
        ),
      ),
      child: AppDialog(
        title: title,
        body: body,
        actions: actions,
        maxWidth: deskDialogMaxWidth,
        compact: true,
        fixedSizeWithKeyboard: true,
      ),
    );
  }
}

SizedBox deskFormFieldSpacer() => const SizedBox(height: deskFormFieldGap);

Widget deskFormRow(List<Widget> children) {
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: deskFormFieldGap),
          Expanded(child: children[i]),
        ],
      ],
    ),
  );
}

TextStyle? deskFormLabelStyle(BuildContext context) =>
    Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

TextStyle? deskFormBodyStyle(BuildContext context) =>
    Theme.of(context).textTheme.bodySmall;

/// Label + dropdown, same height as compact [LabeledTextField].
class DeskLabeledDropdown<T> extends StatelessWidget {
  const DeskLabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onSelected,
    required this.entries,
    this.enabled = true,
  });

  final String label;
  final T? value;
  final ValueChanged<T?> onSelected;
  final List<DropdownMenuEntry<T>> entries;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: deskFormLabelStyle(context)),
        const SizedBox(height: Spacing.xs),
        SizedBox(
          height: deskFormControlHeight,
          child: DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            isDense: true,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: _deskInputPadding,
            ),
            style: deskFormBodyStyle(context),
            items: [
              for (final entry in entries)
                DropdownMenuItem<T>(
                  value: entry.value,
                  child: Text(entry.label, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: enabled ? onSelected : null,
          ),
        ),
      ],
    );
  }
}
