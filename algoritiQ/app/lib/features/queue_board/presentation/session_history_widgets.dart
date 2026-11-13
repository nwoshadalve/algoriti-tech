// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/board_models.dart';
import '../domain/session_history_models.dart';
import 'queue_desk_format.dart';
import 'queue_desk_token_status.dart';
import 'session_history_format.dart';

/// "Running now" / "Ended" / "Ended by admin" as a pill.
class SessionStatusPill extends StatelessWidget {
  const SessionStatusPill({super.key, required this.session});

  final SessionSummary session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final forced =
        !session.isOpen && session.closeReason?.trim().isNotEmpty == true;
    final color = session.isOpen
        ? BrandColors.positive
        : forced
        ? scheme.error
        : scheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Radii.field),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        child: Text(
          historyStatusLabel(l10n, session),
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// A number with its label, e.g. "12 Entered".
class SessionStat extends StatelessWidget {
  const SessionStat({super.key, required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          queueDeskFormatSerial(value, locale),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// The counts of a session or of one queue in it.
class SessionStatRow extends StatelessWidget {
  const SessionStatRow({super.key, required this.counts, this.freeCount});

  final Map<TokenStatus, int> counts;

  /// Patients seen free; shown for a whole session only.
  final int? freeCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    int of(TokenStatus s) => counts[s] ?? 0;
    final issued = counts.values.fold(0, (a, b) => a + b);
    return Wrap(
      spacing: Spacing.lg,
      runSpacing: Spacing.sm,
      children: [
        SessionStat(value: issued, label: l10n.historyTokens),
        SessionStat(
          value: of(TokenStatus.entered),
          label: l10n.deskStatusEntered,
        ),
        SessionStat(
          value: of(TokenStatus.skipped),
          label: l10n.deskStatusMissed,
        ),
        SessionStat(
          value: of(TokenStatus.cancelled),
          label: l10n.deskStatusCancelled,
        ),
        SessionStat(
          value: of(TokenStatus.waiting) + of(TokenStatus.called),
          label: l10n.historyNotSeen,
        ),
        if (freeCount != null)
          SessionStat(value: freeCount!, label: l10n.historyFree),
      ],
    );
  }
}

/// One session in the list: when it ran, who ran it and how it went.
class SessionHistoryCard extends StatelessWidget {
  const SessionHistoryCard({
    super.key,
    required this.session,
    required this.showChamber,
    required this.onTap,
  });

  final SessionSummary session;
  final bool showChamber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final now = DateTime.now();
    final closed = session.closedAt;
    final start = historyClock(context, session.openedAt);
    final range = closed == null
        ? l10n.historyTimeOpen(start)
        : l10n.historyTime(start, historyClock(context, closed));
    final reason = session.closeReason?.trim() ?? '';
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          historyDay(context, session.openedAt),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (showChamber && session.chamberName.isNotEmpty)
                          Text(session.chamberName, style: muted),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  SessionStatusPill(session: session),
                ],
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                '$range · ${historyDuration(l10n, historyRunTime(session, now))}',
                style: theme.textTheme.bodyMedium,
              ),
              if (session.openedByName != null)
                Text(l10n.historyOpenedBy(session.openedByName!), style: muted),
              if (closed != null && session.closedByName != null)
                Text(l10n.historyEndedBy(session.closedByName!), style: muted),
              if (reason.isNotEmpty)
                Text(
                  l10n.historyReason(reason),
                  style: muted?.copyWith(color: theme.colorScheme.error),
                ),
              const SizedBox(height: Spacing.md),
              SessionStatRow(
                counts: session.counts,
                freeCount: session.freeCount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One patient of a past session and what became of the token.
class SessionTokenRow extends StatelessWidget {
  const SessionTokenRow({super.key, required this.token});

  final BoardTokenView token;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    String clock(DateTime at) => historyClock(context, at);
    final times = [
      '${l10n.historyColIssued}: ${clock(token.issuedAt)}',
      if (token.firstCalledAt != null)
        '${l10n.historyColCalled}: ${clock(token.firstCalledAt!)}',
      if (token.enteredAt != null)
        '${l10n.deskStatusEntered}: ${clock(token.enteredAt!)}',
      if (token.cancelledAt != null)
        '${l10n.deskStatusCancelled}: ${clock(token.cancelledAt!)}',
    ].join(' · ');
    final reason = token.cancelReason?.trim() ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              queueDeskFormatSerial(token.serial, locale),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(token.patientName, style: theme.textTheme.bodyLarge),
                Text(
                  '${queueDeskFormatDigits(token.clinicPatientId, locale)} · ${queueDeskQueueNameForToken(locale, token)}',
                  style: muted,
                ),
                Text(times, style: muted),
                if (reason.isNotEmpty) Text(reason, style: muted),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          DeskTokenStatusCell(token: token),
        ],
      ),
    );
  }
}
