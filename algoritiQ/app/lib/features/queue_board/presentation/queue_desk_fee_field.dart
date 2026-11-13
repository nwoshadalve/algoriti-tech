// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/labeled_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../fee_codes/application/fee_code_service.dart';
import '../../fee_codes/domain/fee_code.dart';
import 'queue_desk_dialog_layout.dart';
import 'queue_desk_format.dart';

/// The fee of a visit in a desk form.
///
/// While the admin has defined no fee codes this is the free "Fee (BDT)"
/// field it always was. Once codes exist it is a dropdown of them (and "No
/// fee", the default); picking one fills [controller] with its amount, so the
/// form reads the fee from [controller] either way.
///
/// With [onFreeChanged] an "F" toggle sits beside it: a free patient pays no
/// fee, so while [free] is on the fee input is hidden and [controller] cleared.
class DeskFeeField extends ConsumerStatefulWidget {
  const DeskFeeField({
    super.key,
    required this.controller,
    required this.enabled,
    this.errorText,
    this.free = false,
    this.onFreeChanged,
  });

  final TextEditingController controller;
  final bool enabled;

  /// Shown under the free field only (a dropdown cannot hold a bad value).
  final String? errorText;

  /// The visit is free (no fee).
  final bool free;
  final ValueChanged<bool>? onFreeChanged;

  @override
  ConsumerState<DeskFeeField> createState() => _DeskFeeFieldState();
}

class _DeskFeeFieldState extends ConsumerState<DeskFeeField> {
  static const _none = '';

  /// A fee the visit already has that matches no code (typed before codes
  /// existed, or a code that was since removed): kept as it is.
  static const _current = '\u0000current';

  /// The code the person picked, so two codes with the same amount do not
  /// swap places in the list.
  String? _picked;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  /// A draft restored into the controller changes the amount from outside.
  void _onText() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final onFree = widget.onFreeChanged;
    if (onFree == null) return _feeInput(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: widget.free
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l10n.deskFreeLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : _feeInput(context),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: l10n.deskFreeTooltip,
          child: FilterChip(
            key: const ValueKey('desk-free-toggle'),
            label: Text(l10n.deskFreeShort),
            selected: widget.free,
            onSelected: widget.enabled
                ? (on) {
                    if (on) widget.controller.clear();
                    onFree(on);
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _feeInput(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final codes = ref.watch(feeCodesProvider).asData?.value ?? const [];
    if (codes.isEmpty) {
      return LabeledTextField(
        compact: true,
        label: l10n.deskFieldFee,
        controller: widget.controller,
        errorText: widget.errorText,
        keyboardType: TextInputType.number,
        enabled: widget.enabled,
      );
    }

    final amount = queueDeskParseNumber(widget.controller.text);
    final match = _matching(codes, amount);
    return DeskLabeledDropdown<String>(
      label: l10n.deskFieldFee,
      value: amount == null ? _none : (match?.id ?? _current),
      enabled: widget.enabled,
      entries: [
        DropdownMenuEntry(value: _none, label: l10n.deskFeeNone),
        for (final fee in codes)
          DropdownMenuEntry(
            value: fee.id,
            label: '${fee.code} — ${fee.amountBdt}',
          ),
        if (amount != null && match == null)
          DropdownMenuEntry(value: _current, label: '$amount'),
      ],
      onSelected: (id) {
        _picked = id;
        if (id == null || id == _none) {
          widget.controller.clear();
        } else if (id != _current) {
          final fee = codes.firstWhere((f) => f.id == id);
          widget.controller.text = fee.amountBdt.toString();
        }
      },
    );
  }

  FeeCode? _matching(List<FeeCode> codes, int? amount) {
    if (amount == null) return null;
    final picked = codes.where((f) => f.id == _picked).firstOrNull;
    if (picked != null && picked.amountBdt == amount) return picked;
    return codes.where((f) => f.amountBdt == amount).firstOrNull;
  }
}
