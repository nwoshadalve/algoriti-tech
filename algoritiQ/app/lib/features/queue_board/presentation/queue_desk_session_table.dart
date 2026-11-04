// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../application/queue_desk_table_controller.dart';
import '../domain/board_models.dart';
import '../domain/token_query.dart';
import 'queue_desk_row_actions.dart';
import 'queue_desk_token_rows.dart';

/// Below this width (before text scaling) the table becomes one card per
/// patient.
const _tableMinWidth = 500.0;

/// Ask for the next page when this close to the end of the list.
const _loadMoreWithin = 240.0;

/// The patients of today's session, a page at a time: headings that sort, the
/// rows, and the empty / loading / failed states. The list is the only part
/// that scrolls. Everything it shows came from the database already searched,
/// filtered and ordered, so nothing here sorts or filters.
class QueueDeskTokenTable extends StatelessWidget {
  const QueueDeskTokenTable({
    super.key,
    required this.state,
    required this.printerBusyTokenId,
    required this.onSort,
    required this.onLoadMore,
    required this.onRetry,
    required this.onClearFilters,
    required this.onPrint,
    required this.onReprint,
    required this.onEditPatient,
    required this.onCancel,
  });

  final DeskTableState state;

  /// Token being printed now; every print icon waits for it.
  final String? printerBusyTokenId;
  final ValueChanged<TokenSort> onSort;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;
  final void Function(BoardTokenView token) onPrint;
  final void Function(BoardTokenView token) onReprint;
  final void Function(BoardTokenView token) onEditPatient;
  final void Function(BoardTokenView token) onCancel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Large system text needs the room of a card, not a squeezed table.
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final wide = constraints.maxWidth / scale >= _tableMinWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide) DeskTokenHeaderRow(query: state.query, onSort: onSort),
            Expanded(child: _body(context, wide)),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, bool wide) {
    final l10n = AppLocalizations.of(context);
    if (state.items.isEmpty) {
      if (state.loading) {
        return Center(child: BrandLoader(semanticLabel: l10n.deskWorking));
      }
      if (state.failed) {
        return _Message(
          text: l10n.deskLoadFailed,
          action: l10n.retryButton,
          onAction: onRetry,
        );
      }
      if (state.query.hasFilters) {
        return _Message(
          text: l10n.deskNoMatch,
          action: l10n.deskClearFilters,
          onAction: onClearFilters,
        );
      }
      return _Message(
        text: l10n.deskSessionEmpty,
        hint: l10n.deskSessionEmptyHint,
      );
    }
    final actions = DeskRowActions(
      printerBusy: printerBusyTokenId != null,
      onPrint: onPrint,
      onReprint: onReprint,
      onEditPatient: onEditPatient,
      onCancel: onCancel,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.failed)
          _FailedBanner(text: l10n.deskLoadFailed, onRetry: onRetry),
        Expanded(child: _list(wide, actions)),
      ],
    );
  }

  Widget _list(bool wide, DeskRowActions actions) {
    final rows = state.items;
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < _loadMoreWithin) onLoadMore();
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: Spacing.sm),
        itemCount: rows.length + (state.loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= rows.length) {
            return const Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: Center(child: BrandLoader()),
            );
          }
          final token = rows[index];
          return wide
              ? DeskTokenTableRow(
                  key: ValueKey(token.id),
                  token: token,
                  actions: actions,
                )
              : DeskTokenCardRow(
                  key: ValueKey(token.id),
                  token: token,
                  actions: actions,
                );
        },
      ),
    );
  }
}

/// A centred message, with an optional hint and one action.
class _Message extends StatelessWidget {
  const _Message({required this.text, this.hint, this.action, this.onAction});

  final String text;
  final String? hint;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (hint != null) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: Spacing.md),
              OutlinedButton(onPressed: onAction, child: Text(action!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown above rows that are already on screen when a reload failed.
class _FailedBanner extends StatelessWidget {
  const _FailedBanner({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).retryButton),
          ),
        ],
      ),
    );
  }
}
