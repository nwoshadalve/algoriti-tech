import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// Where the user is in getting a device activated.
enum ActivationStep { copyCode, getKey, enterKey }

/// Three-step progress row: earlier steps are checked, the current one is
/// highlighted in coral. State is never shown by colour alone.
class ActivationStepper extends StatelessWidget {
  const ActivationStepper({super.key, required this.current});

  final ActivationStep current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.activationStepCopy,
      l10n.activationStepGet,
      l10n.activationStepEnter,
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final step in ActivationStep.values)
          Expanded(
            child: _StepCell(
              step: step,
              label: labels[step.index],
              status: _statusOf(step),
              spokenStatus: switch (_statusOf(step)) {
                _Status.done => l10n.stepDone,
                _Status.current => l10n.stepCurrent,
                _Status.pending => '',
              },
            ),
          ),
      ],
    );
  }

  _Status _statusOf(ActivationStep step) {
    if (step.index < current.index) return _Status.done;
    return step == current ? _Status.current : _Status.pending;
  }
}

enum _Status { done, current, pending }

class _StepCell extends StatelessWidget {
  const _StepCell({
    required this.step,
    required this.label,
    required this.status,
    required this.spokenStatus,
  });

  final ActivationStep step;
  final String label;
  final _Status status;
  final String spokenStatus;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isFirst = step.index == 0;
    final isLast = step.index == ActivationStep.values.length - 1;
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
                  visible: !isFirst,
                  color: _lineColor(scheme, reached),
                ),
              ),
              _Dot(step: step, status: status),
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
  const _Dot({required this.step, required this.status});

  final ActivationStep step;
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
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    ).format(step.index + 1);

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: status == _Status.done
          ? Icon(Icons.check_rounded, size: 18, color: foreground)
          : Text(
              number,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
    );
  }
}
