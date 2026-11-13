// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/tablet_session.dart';
import '../application/queue_board_providers.dart';
import '../domain/board_models.dart';
import '../domain/session_history_models.dart';
import '../domain/token_query.dart';
import 'queue_desk_format.dart';
import 'queue_desk_token_status.dart';
import 'session_history_format.dart';
import 'session_history_widgets.dart';

/// One past session: its times, the people, the outcome per queue and every
/// patient with what became of their token. Read only.
class SessionHistoryDetailPage extends ConsumerStatefulWidget {
  const SessionHistoryDetailPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<SessionHistoryDetailPage> createState() =>
      _SessionHistoryDetailPageState();
}

class _SessionHistoryDetailPageState
    extends ConsumerState<SessionHistoryDetailPage> {
  static const _pageSize = 30;

  SessionDetail? _detail;
  final _tokens = <BoardTokenView>[];
  Map<TokenStatus, int> _counts = const {};
  var _total = 0;
  TokenStatus? _status;
  var _loading = true;
  var _loadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_load()));
  }

  Future<void> _load({bool more = false}) async {
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null) return;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = _detail == null;
      }
    });
    try {
      final service = ref.read(queueBoardServiceProvider);
      final detail =
          _detail ?? await service.sessionDetail(account, widget.sessionId);
      final page = await service.searchHistoryTokens(
        account,
        widget.sessionId,
        TokenQuery(
          status: _status,
          sort: TokenSort.serial,
          ascending: true,
          limit: _pageSize,
          offset: more ? _tokens.length : 0,
        ),
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        if (!more) _tokens.clear();
        _tokens.addAll(page.items);
        _counts = page.counts;
        _total = page.total;
        _loading = false;
        _loadingMore = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _setStatus(TokenStatus? status) {
    if (status == _status) return;
    _status = status;
    unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyDetailTitle)),
      body: SafeArea(child: _body(l10n)),
    );
  }

  Widget _body(AppLocalizations l10n) {
    final detail = _detail;
    if (_loading) return const Center(child: BrandLoader(semanticLabel: ''));
    if (detail == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.historyLoadFailed),
            const SizedBox(height: Spacing.sm),
            OutlinedButton(
              onPressed: () => unawaited(_load()),
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      );
    }
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final session = detail.summary;
    final more = _tokens.length < _total;
    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        _summaryCard(l10n, session),
        const SizedBox(height: Spacing.md),
        if (detail.queues.isNotEmpty) ...[
          Text(
            l10n.historyByQueue,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          for (final queue in detail.queues)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.languageCode == 'bn' &&
                                queue.bengaliName.trim().isNotEmpty
                            ? queue.bengaliName
                            : queue.englishName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                      SessionStatRow(counts: queue.counts),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: Spacing.sm),
        ],
        Text(
          l10n.historyPatients,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        _statusFilters(l10n, session),
        const SizedBox(height: Spacing.sm),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: _tokens.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Text(l10n.historyNoPatients),
                )
              : Column(
                  children: [
                    for (var i = 0; i < _tokens.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      SessionTokenRow(token: _tokens[i]),
                    ],
                  ],
                ),
        ),
        if (more) ...[
          const SizedBox(height: Spacing.md),
          Align(
            child: _loadingMore
                ? const BrandLoader(semanticLabel: '')
                : OutlinedButton(
                    onPressed: () => unawaited(_load(more: true)),
                    child: Text(l10n.historyShowMore),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _statusFilters(AppLocalizations l10n, SessionSummary session) {
    final locale = Localizations.localeOf(context);
    final all = session.issued;
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        ChoiceChip(
          label: Text(
            '${l10n.deskFilterAll} ${queueDeskFormatSerial(all, locale)}',
          ),
          selected: _status == null,
          onSelected: (_) => _setStatus(null),
        ),
        for (final status in TokenStatus.values)
          if ((_counts[status] ?? 0) > 0 || _status == status)
            ChoiceChip(
              label: Text(
                '${queueDeskStatusLabel(l10n, status)} '
                '${queueDeskFormatSerial(_counts[status] ?? 0, locale)}',
              ),
              selected: _status == status,
              onSelected: (_) => _setStatus(status),
            ),
      ],
    );
  }

  Widget _summaryCard(AppLocalizations l10n, SessionSummary session) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final reason = session.closeReason?.trim() ?? '';
    Widget field(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: muted),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
    final closed = session.closedAt;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${historyDay(context, session.openedAt)}'
                    '${session.chamberName.isEmpty ? '' : ' · ${session.chamberName}'}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SessionStatusPill(session: session),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Wrap(
              spacing: Spacing.lg,
              runSpacing: Spacing.md,
              children: [
                field(
                  l10n.historyOpened,
                  [
                    historyClock(context, session.openedAt),
                    if (session.openedByName != null) session.openedByName!,
                  ].join(' · '),
                ),
                if (closed != null)
                  field(
                    l10n.historyEnded,
                    [
                      historyClock(context, closed),
                      if (session.closedByName != null) session.closedByName!,
                    ].join(' · '),
                  ),
                field(
                  l10n.historyDuration,
                  historyDuration(
                    l10n,
                    historyRunTime(session, DateTime.now()),
                  ),
                ),
                if (session.firstCalledAt != null)
                  field(
                    l10n.historyFirstCall,
                    historyClock(context, session.firstCalledAt!),
                  ),
                if (session.lastCalledAt != null)
                  field(
                    l10n.historyLastCall,
                    historyClock(context, session.lastCalledAt!),
                  ),
              ],
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.historyReason(reason),
                style: muted?.copyWith(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: Spacing.md),
            SessionStatRow(
              counts: session.counts,
              freeCount: session.freeCount,
            ),
          ],
        ),
      ),
    );
  }
}
