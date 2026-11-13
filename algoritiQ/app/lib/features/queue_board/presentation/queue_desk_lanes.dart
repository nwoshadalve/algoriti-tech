// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/board_models.dart';
import 'queue_desk_format.dart';

/// From this width a queue is one row (name, patient, actions, Call); narrower,
/// the patient and the actions go under the name.
const _rowMinWidth = 800.0;

/// One card per queue: its name and waiting count, **Call**, and, while it is
/// calling, the patient with Recall, Entered, Missed and Cancel. Every queue is
/// on screen at once (a queue is about 60 dp tall); the list scrolls inside
/// itself only when there are more queues than fit.
class DeskQueueLanes extends StatelessWidget {
  const DeskQueueLanes({
    super.key,
    required this.controls,
    required this.called,
    required this.busyQueueId,
    required this.onCall,
    required this.onRecall,
    required this.onEntered,
    required this.onMissed,
    required this.onCancel,
    required this.onEndSession,
  });

  final List<QueueTypeBoardControl> controls;

  /// The patients being called now, one per queue at most.
  final List<BoardTokenView> called;

  /// The queue whose Call is being carried out.
  final String? busyQueueId;
  final ValueChanged<String> onCall;
  final ValueChanged<String> onRecall;
  final ValueChanged<BoardTokenView> onEntered;
  final ValueChanged<BoardTokenView> onMissed;
  final ValueChanged<BoardTokenView> onCancel;
  final VoidCallback onEndSession;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _rowMinWidth;
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            for (final control in controls) ...[
              _Lane(
                control: control,
                token: _calledIn(control.queueTypeId),
                busy: control.queueTypeId == busyQueueId,
                wide: wide,
                onCall: onCall,
                onRecall: onRecall,
                onEntered: onEntered,
                onMissed: onMissed,
                onCancel: onCancel,
              ),
              const SizedBox(height: Spacing.sm),
            ],
            // Ending the session is rare and cannot be undone, so it is small,
            // plain and in the error colour, not a filled button.
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onEndSession,
                icon: const Icon(Icons.stop_circle_outlined, size: 18),
                label: Text(l10n.deskEndSession),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  BoardTokenView? _calledIn(String queueTypeId) {
    for (final token in called) {
      if (token.queueTypeId == queueTypeId) return token;
    }
    return null;
  }
}

class _Lane extends StatelessWidget {
  const _Lane({
    required this.control,
    required this.token,
    required this.busy,
    required this.wide,
    required this.onCall,
    required this.onRecall,
    required this.onEntered,
    required this.onMissed,
    required this.onCancel,
  });

  final QueueTypeBoardControl control;
  final BoardTokenView? token;
  final bool busy;
  final bool wide;
  final ValueChanged<String> onCall;
  final ValueChanged<String> onRecall;
  final ValueChanged<BoardTokenView> onEntered;
  final ValueChanged<BoardTokenView> onMissed;
  final ValueChanged<BoardTokenView> onCancel;

  static const _size = Size(0, 40);
  static const _padding = EdgeInsets.symmetric(horizontal: Spacing.md);

  /// A button label that shrinks a little instead of breaking in two.
  static Widget _label(String text) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, maxLines: 1, softWrap: false),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final called = token;
    final name = _Name(control: control);
    final patient = called == null ? const _Idle() : _Patient(token: called);
    // A queue that is calling has no Call button: Recall (or Call for a token
    // not yet announced) is with the patient's actions.
    final call = called == null ? _callButton(context) : null;
    final actions = called == null ? null : _actions(context, called);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: called == null
            ? null
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.18),
        border: Border.all(
          color: called == null
              ? theme.colorScheme.outlineVariant
              : theme.colorScheme.primary.withValues(alpha: 0.6),
        ),
        borderRadius: BorderRadius.circular(Radii.field),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm + Spacing.xs,
          vertical: Spacing.sm,
        ),
        child: wide
            ? Row(
                children: [
                  SizedBox(width: 150, child: name),
                  const SizedBox(width: Spacing.md),
                  Expanded(flex: 2, child: patient),
                  if (actions != null) ...[
                    const SizedBox(width: Spacing.md),
                    // Large text or long Bengali labels shrink the buttons a
                    // little instead of pushing Call off the screen.
                    Flexible(
                      flex: 3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: actions,
                      ),
                    ),
                  ],
                  if (call != null) ...[
                    const SizedBox(width: Spacing.md),
                    call,
                  ],
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: name),
                      if (call != null) ...[
                        const SizedBox(width: Spacing.sm),
                        call,
                      ],
                    ],
                  ),
                  if (called != null) ...[
                    const SizedBox(height: Spacing.sm),
                    patient,
                    const SizedBox(height: Spacing.sm),
                    actions!,
                  ],
                ],
              ),
      ),
    );
  }

  Widget _callButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return FilledButton(
      onPressed: busy || !control.canCallNext
          ? null
          : () => onCall(control.queueTypeId),
      style: FilledButton.styleFrom(
        minimumSize: const Size(96, 44),
        padding: _padding,
      ),
      child: busy
          ? BrandLoader(
              color: theme.colorScheme.onPrimary,
              semanticLabel: l10n.deskWorking,
            )
          : _label(l10n.deskCallBtn),
    );
  }

  Widget _actions(BuildContext context, BoardTokenView called) {
    final l10n = AppLocalizations.of(context);
    final buttons = <Widget>[
      // A token that came up on the board by itself has not been announced:
      // Call makes the first announcement; after that it is Recall.
      if (called.announced)
        OutlinedButton(
          onPressed: () => onRecall(control.queueTypeId),
          style: OutlinedButton.styleFrom(
            minimumSize: _size,
            padding: _padding,
          ),
          child: _label(l10n.deskRecallBtn),
        )
      else
        FilledButton(
          onPressed: () => onRecall(control.queueTypeId),
          style: FilledButton.styleFrom(minimumSize: _size, padding: _padding),
          child: _label(l10n.deskCallBtn),
        ),
      FilledButton.tonal(
        onPressed: () => onEntered(called),
        style: FilledButton.styleFrom(minimumSize: _size, padding: _padding),
        child: _label(l10n.deskPatientEntered),
      ),
      OutlinedButton(
        onPressed: () => onMissed(called),
        style: OutlinedButton.styleFrom(minimumSize: _size, padding: _padding),
        child: _label(l10n.deskPatientMissed),
      ),
      TextButton(
        onPressed: () => onCancel(called),
        style: TextButton.styleFrom(minimumSize: _size, padding: _padding),
        child: _label(l10n.cancelEditButton),
      ),
    ];
    if (wide) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: Spacing.xs),
            buttons[i],
          ],
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: Spacing.xs),
          Expanded(child: buttons[i]),
        ],
      ],
    );
  }
}

/// The queue's name and how many wait.
class _Name extends StatelessWidget {
  const _Name({required this.control});

  final QueueTypeBoardControl control;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          queueDeskQueueName(locale, control),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          l10n.deskWaitingCount(control.waitingCount),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// A queue that is not calling.
class _Idle extends StatelessWidget {
  const _Idle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      AppLocalizations.of(context).deskCurrentCallEmpty,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// The patient being called: big serial, name, and ID.
class _Patient extends StatelessWidget {
  const _Patient({required this.token});

  final BoardTokenView token;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          queueDeskFormatSerial(token.serial, locale),
          style: theme.textTheme.headlineSmall?.copyWith(
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
                token.patientName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                queueDeskFormatDigits(token.clinicPatientId, locale),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
