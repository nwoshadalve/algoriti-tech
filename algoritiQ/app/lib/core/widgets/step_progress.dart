import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';

/// Step-by-step progress row: earlier steps are checked, the [current] one
/// is highlighted in coral. A [current] past the last step shows all done.
/// State is never shown by colour alone.
class StepProgress extends StatelessWidget {
  const StepProgress({
    super.key,
    required this.labels,
    required this.current,
    this.dense = false,
  });

  final List<String> labels;

  /// Zero-based index of the step the user is on.
  final int current;

  /// One slim row for short screens: only the current step shows its label.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (dense) {
      return Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                  child: _Line(
                    visible: true,
                    color: _lineColor(
                      Theme.of(context).colorScheme,
                      i <= current,
                    ),
                  ),
                ),
              ),
            // The current step may shrink (label ellipsis) at large text
            // sizes; the other steps are only a dot.
            Flexible(
              flex: i == current ? 2 : 0,
              child: Semantics(
                label: '${labels[i]} ${_spoken(l10n, i)}'.trim(),
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dot(number: i + 1, status: _statusOf(i)),
                    if (i == current) ...[
                      const SizedBox(width: Spacing.sm),
                      Flexible(
                        child: Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: _StepCell(
              index: i,
              isLast: i == labels.length - 1,
              label: labels[i],
              status: _statusOf(i),
              spokenStatus: _spoken(l10n, i),
            ),
          ),
      ],
    );
  }

  String _spoken(AppLocalizations l10n, int index) =>
      switch (_statusOf(index)) {
        _Status.done => l10n.stepDone,
        _Status.current => l10n.stepCurrent,
        _Status.pending => '',
      };

  Color _lineColor(ColorScheme scheme, bool filled) =>
      filled ? scheme.primary : scheme.outlineVariant;

  _Status _statusOf(int index) {
    if (index < current) return _Status.done;
    return index == current ? _Status.current : _Status.pending;
  }
}

enum _Status { done, current, pending }

class _StepCell extends StatelessWidget {
  const _StepCell({
    required this.index,
    required this.isLast,
    required this.label,
    required this.status,
    required this.spokenStatus,
  });

  final int index;
  final bool isLast;
  final String label;
  final _Status status;
  final String spokenStatus;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reached = status != _Status.pending;

    return Semantics(
      label: '$label $spokenStatus'.trim(),
      excludeSemantics: true,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Line(
                  visible: index > 0,
                  color: _lineColor(scheme, reached),
                ),
              ),
              _Dot(number: index + 1, status: status),
              Expanded(
                child: _Line(
                  visible: !isLast,
                  color: _lineColor(scheme, status == _Status.done),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: status == _Status.pending
                    ? scheme.onSurfaceVariant
                    : scheme.onSurface,
                fontWeight: status == _Status.current
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _lineColor(ColorScheme scheme, bool filled) =>
      filled ? scheme.primary : scheme.outlineVariant;
}

class _Line extends StatelessWidget {
  const _Line({required this.visible, required this.color});

  final bool visible;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 2, child: visible ? ColoredBox(color: color) : null);
}

class _Dot extends StatelessWidget {
  const _Dot({required this.number, required this.status});

  final int number;
  final _Status status;

  static const _size = 28.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      _Status.done => (scheme.primary, scheme.onPrimary),
      _Status.current => (scheme.tertiary, scheme.onTertiary),
      _Status.pending => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
    };
    final text = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    ).format(number);

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: status == _Status.done
          ? Icon(Icons.check_rounded, size: 18, color: foreground)
          : Text(
              text,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
    );
  }
}
