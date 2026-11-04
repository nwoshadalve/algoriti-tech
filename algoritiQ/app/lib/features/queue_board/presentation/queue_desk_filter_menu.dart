// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';

/// One choice of a [DeskFilterMenu]; a null [value] means "no filter".
typedef DeskFilterChoice<T> = ({T? value, String label});

/// A dropdown that filters the table by one thing (a queue, a status). It is
/// outlined in the brand colour while a filter is on.
class DeskFilterMenu<T> extends StatelessWidget {
  const DeskFilterMenu({
    super.key,
    required this.tooltip,
    required this.choices,
    required this.selected,
    required this.onSelected,
  });

  final String tooltip;
  final List<DeskFilterChoice<T>> choices;

  /// The chosen value; null when nothing filters.
  final T? selected;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = choices.firstWhere(
      (c) => c.value == selected,
      orElse: () => choices.first,
    );
    return PopupMenuButton<int>(
      tooltip: tooltip,
      onSelected: (index) => onSelected(choices[index].value),
      itemBuilder: (_) => [
        for (var i = 0; i < choices.length; i++)
          CheckedPopupMenuItem<int>(
            value: i,
            checked: choices[i].value == selected,
            child: Text(choices[i].label),
          ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: selected == null
                ? theme.colorScheme.outlineVariant
                : theme.colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(Radii.field),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.only(left: Spacing.md, right: Spacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(current.label, style: theme.textTheme.labelLarge),
                const SizedBox(width: Spacing.xs),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
