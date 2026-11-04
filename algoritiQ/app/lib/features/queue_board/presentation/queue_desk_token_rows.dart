// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/board_models.dart';
import '../domain/token_query.dart';
import 'queue_desk_format.dart';
import 'queue_desk_live_wait.dart';
import 'queue_desk_row_actions.dart';
import 'queue_desk_token_status.dart';

// Column shares, in the order shown: Patient ID, Name, Serial, Queue, Wait,
// Status. The name gets the most room; the actions have a fixed width.
const _flexId = 14;
const _flexName = 21;
const _flexSerial = 10;
const _flexQueue = 15;
const _flexWait = 13;
const _flexStatus = 17;

/// A column cell: its share of the row and a gap before the next one.
class _Cell extends StatelessWidget {
  const _Cell({required this.flex, required this.child});

  final int flex;
  final Widget child;

  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.only(right: Spacing.sm),
      child: child,
    ),
  );
}

/// The column headings. Tapping one sorts by it; tapping it again reverses.
class DeskTokenHeaderRow extends StatelessWidget {
  const DeskTokenHeaderRow({
    super.key,
    required this.query,
    required this.onSort,
  });

  final TokenQuery query;
  final ValueChanged<TokenSort> onSort;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    Widget heading(int flex, String title, TokenSort sort) => _Cell(
      flex: flex,
      child: _SortHeading(
        title: title,
        direction: query.sort == sort ? query.ascending : null,
        onTap: () => onSort(sort),
      ),
    );
    return Container(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      child: Row(
        children: [
          heading(_flexId, l10n.deskColPatientId, TokenSort.id),
          heading(_flexName, l10n.deskColName, TokenSort.name),
          heading(_flexSerial, l10n.deskColSerial, TokenSort.serial),
          heading(_flexQueue, l10n.deskColQueue, TokenSort.queue),
          heading(_flexWait, l10n.deskColWait, TokenSort.wait),
          heading(_flexStatus, l10n.deskColStatus, TokenSort.status),
          const SizedBox(width: deskRowActionsWidth),
        ],
      ),
    );
  }
}

/// One heading; [direction] is null when the table is not sorted by it.
class _SortHeading extends StatelessWidget {
  const _SortHeading({
    required this.title,
    required this.direction,
    required this.onTap,
  });

  final String title;
  final bool? direction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sorted = direction != null;
    final color = sorted
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: sorted
          ? '$title, ${direction! ? l10n.deskSortAscending : l10n.deskSortDescending}'
          : title,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          // The word and its arrow shrink together rather than truncate.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: sorted ? FontWeight.w700 : null,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
                if (sorted)
                  Icon(
                    direction! ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle? _clock(TextStyle? base) =>
    base?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

/// One patient as a table row.
class DeskTokenTableRow extends StatelessWidget {
  const DeskTokenTableRow({
    super.key,
    required this.token,
    required this.actions,
  });

  final BoardTokenView token;
  final DeskRowActions actions;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyMedium;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        child: Row(
          children: [
            _Cell(
              flex: _flexId,
              child: Text(token.clinicPatientId, style: body),
            ),
            _Cell(
              flex: _flexName,
              child: Tooltip(
                message: token.patientBengaliName,
                child: Text(
                  token.patientBengaliName,
                  style: body?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            _Cell(
              flex: _flexSerial,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  queueDeskFormatSerial(token.serial, locale),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            _Cell(
              flex: _flexQueue,
              child: Text(
                queueDeskQueueNameForToken(locale, token),
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _Cell(
              flex: _flexWait,
              child: DeskLiveWait(token: token, style: _clock(body)),
            ),
            _Cell(
              flex: _flexStatus,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: DeskTokenStatusCell(token: token),
              ),
            ),
            DeskRowActionsCell(token: token, actions: actions),
          ],
        ),
      ),
    );
  }
}

/// One patient as a card, for panes too narrow for the table.
class DeskTokenCardRow extends StatelessWidget {
  const DeskTokenCardRow({
    super.key,
    required this.token,
    required this.actions,
  });

  final BoardTokenView token;
  final DeskRowActions actions;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                queueDeskFormatSerial(token.serial, locale),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  token.patientBengaliName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              DeskLiveWait(token: token, style: _clock(muted)),
            ],
          ),
          // ID and queue, the status and the actions share one line.
          Row(
            children: [
              Expanded(
                child: Text(
                  '${token.clinicPatientId} · '
                  '${queueDeskQueueNameForToken(locale, token)}',
                  style: muted,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              DeskTokenStatusCell(token: token),
              DeskRowActionsCell(token: token, actions: actions),
            ],
          ),
        ],
      ),
    );
  }
}
