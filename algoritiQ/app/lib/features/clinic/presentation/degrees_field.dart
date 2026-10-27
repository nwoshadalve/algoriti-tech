import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// A doctor's degrees, added one at a time and shown as removable chips in
/// the order they were added (e.g. MBBS, then BCS, then MS).
class DegreesField extends StatefulWidget {
  const DegreesField({
    super.key,
    required this.degrees,
    required this.enabled,
    required this.onChanged,
    this.errorText,
    this.compact = false,
  });

  final List<String> degrees;
  final bool enabled;
  final ValueChanged<List<String>> onChanged;

  /// Shown under the input, e.g. "Add at least one degree."
  final String? errorText;

  /// For short screens: smaller label, and the chips in one row that scrolls
  /// sideways instead of wrapping onto many rows.
  final bool compact;

  @override
  State<DegreesField> createState() => _DegreesFieldState();
}

class _DegreesFieldState extends State<DegreesField> {
  final _controller = TextEditingController();
  final _strip = ScrollController();

  @override
  void didUpdateWidget(DegreesField old) {
    super.didUpdateWidget(old);
    // A degree was added: bring the new chip into view at the end.
    if (widget.degrees.length > old.degrees.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_strip.hasClients) {
          _strip.animateTo(
            _strip.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _strip.dispose();
    super.dispose();
  }

  void _add() {
    final degree = _controller.text.trim();
    if (degree.isEmpty) return;
    _controller.clear();
    widget.onChanged([...widget.degrees, degree]);
  }

  void _remove(int index) {
    widget.onChanged([...widget.degrees]..removeAt(index));
  }

  Widget _chip(AppLocalizations l10n, int index, String degree) => InputChip(
    label: Text(degree),
    deleteButtonTooltipMessage: l10n.removeDegreeTooltip(degree),
    onDeleted: widget.enabled ? () => _remove(index) : null,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.degreesLabel,
            style:
                (widget.compact
                        ? theme.textTheme.labelMedium
                        : theme.textTheme.labelLarge)
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: widget.compact ? Spacing.xs : Spacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _add(),
                  decoration: InputDecoration(errorText: widget.errorText),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              IconButton.outlined(
                onPressed: widget.enabled ? _add : null,
                tooltip: l10n.addDegreeButton,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          if (widget.degrees.isNotEmpty) ...[
            SizedBox(height: widget.compact ? Spacing.xs : Spacing.sm),
            if (widget.compact)
              SingleChildScrollView(
                controller: _strip,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (index, degree) in widget.degrees.indexed)
                      Padding(
                        padding: const EdgeInsets.only(right: Spacing.sm),
                        child: _chip(l10n, index, degree),
                      ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.xs,
                children: [
                  for (final (index, degree) in widget.degrees.indexed)
                    _chip(l10n, index, degree),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
