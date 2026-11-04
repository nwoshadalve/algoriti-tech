// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/board_models.dart';
import 'queue_desk_format.dart';

/// From this width the card is one slim row; narrower, the actions go under
/// the patient.
const _rowMinWidth = 640.0;

/// The patient being called now: big serial, name, ID and queue, and what the
/// receptionist can do next. It sizes to its content (a long name wraps to
/// two lines) and never needs a fixed height.
class DeskNowCalling extends StatelessWidget {
  const DeskNowCalling({
    super.key,
    required this.called,
    required this.onRecall,
    required this.onEntered,
    required this.onMissed,
    required this.onCancel,
  });

  final BoardTokenView? called;
  final VoidCallback onRecall;
  final VoidCallback onEntered;
  final VoidCallback onMissed;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final token = called;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm + Spacing.xs,
          vertical: Spacing.sm,
        ),
        child: token == null
            ? Text(
                l10n.deskCurrentCallEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= _rowMinWidth;
                  final identity = _Identity(
                    token: token,
                    // Narrow: Cancel sits beside the patient so the three main
                    // actions can share the full width underneath.
                    trailing: wide ? null : _CancelButton(onCancel: onCancel),
                  );
                  final actions = _Actions(
                    onRecall: onRecall,
                    onEntered: onEntered,
                    onMissed: onMissed,
                    onCancel: wide ? onCancel : null,
                    expand: !wide,
                  );
                  if (wide) {
                    return Row(
                      children: [
                        Expanded(child: identity),
                        const SizedBox(width: Spacing.md),
                        actions,
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      identity,
                      const SizedBox(height: Spacing.sm),
                      actions,
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.token, this.trailing});

  final BoardTokenView token;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          queueDeskFormatSerial(token.serial, locale),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                token.patientBengaliName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${token.clinicPatientId} · '
                '${queueDeskQueueNameForToken(locale, token)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onCancel,
    style: TextButton.styleFrom(
      minimumSize: const Size(0, 40),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
    ),
    child: Text(AppLocalizations.of(context).cancelEditButton),
  );
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.onRecall,
    required this.onEntered,
    required this.onMissed,
    required this.onCancel,
    required this.expand,
  });

  final VoidCallback onRecall;
  final VoidCallback onEntered;
  final VoidCallback onMissed;

  /// Null when Cancel is shown elsewhere (beside the patient).
  final VoidCallback? onCancel;

  /// Share the width equally (narrow card) instead of wrapping.
  final bool expand;

  static const _size = Size(0, 40);
  static const _padding = EdgeInsets.symmetric(horizontal: Spacing.sm);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buttons = <Widget>[
      OutlinedButton(
        onPressed: onRecall,
        style: OutlinedButton.styleFrom(minimumSize: _size, padding: _padding),
        child: Text(l10n.deskRecallBtn),
      ),
      FilledButton(
        onPressed: onEntered,
        style: FilledButton.styleFrom(minimumSize: _size, padding: _padding),
        child: Text(l10n.deskPatientEntered),
      ),
      OutlinedButton(
        onPressed: onMissed,
        style: OutlinedButton.styleFrom(minimumSize: _size, padding: _padding),
        child: Text(l10n.deskPatientMissed),
      ),
      if (onCancel != null)
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(minimumSize: _size, padding: _padding),
          child: Text(l10n.cancelEditButton),
        ),
    ];
    if (expand) {
      return Row(
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: Spacing.xs),
            Expanded(child: buttons[i]),
          ],
        ],
      );
    }
    return Wrap(
      spacing: Spacing.xs,
      runSpacing: Spacing.xs,
      alignment: WrapAlignment.end,
      children: buttons,
    );
  }
}
