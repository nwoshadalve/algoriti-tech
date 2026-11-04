// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../application/queue_desk_table_controller.dart';
import '../domain/board_models.dart';
import '../domain/token_query.dart';
import 'queue_desk_filter_menu.dart';
import 'queue_desk_format.dart';
import 'queue_desk_token_status.dart';

/// The statuses a patient can be filtered by, in lifecycle order.
const _statusOrder = [
  TokenStatus.waiting,
  TokenStatus.called,
  TokenStatus.skipped,
  TokenStatus.entered,
  TokenStatus.cancelled,
];

/// Search on one line; under it the queue and status menus, the "not
/// printed" toggle and sorting. It only reports what the receptionist chose;
/// the table answers.
class QueueDeskTableToolbar extends StatefulWidget {
  const QueueDeskTableToolbar({
    super.key,
    required this.state,
    required this.queues,
    required this.onSearch,
    required this.onStatus,
    required this.onQueue,
    required this.onToggleNotPrinted,
    required this.onSort,
    required this.onClear,
    this.onSearchFocus,
    this.compact = false,
  });

  final DeskTableState state;
  final List<QueueTypeBoardControl> queues;
  final ValueChanged<String> onSearch;
  final ValueChanged<TokenStatus?> onStatus;
  final ValueChanged<String?> onQueue;
  final VoidCallback onToggleNotPrinted;
  final ValueChanged<TokenSort> onSort;
  final VoidCallback onClear;

  /// Told when the search box gains or loses focus, so the desk can make room
  /// above the keyboard.
  final ValueChanged<bool>? onSearchFocus;

  /// Leaves only the search box, to save height while the keyboard is open.
  final bool compact;

  @override
  State<QueueDeskTableToolbar> createState() => _QueueDeskTableToolbarState();
}

class _QueueDeskTableToolbarState extends State<QueueDeskTableToolbar> {
  late final TextEditingController _search;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.state.query.search);
    _focus.addListener(_reportFocus);
  }

  void _reportFocus() => widget.onSearchFocus?.call(_focus.hasFocus);

  @override
  void didUpdateWidget(QueueDeskTableToolbar old) {
    super.didUpdateWidget(old);
    // Cleared from outside (Clear filters): the box follows. Typing never
    // lands here with a different text, because the box is the source.
    final search = widget.state.query.search;
    if (search != old.state.query.search && search != _search.text) {
      _search.text = search;
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_reportFocus)
      ..dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _searchBox(context),
        // Offstage keeps the tree as it is, so the search box keeps its focus.
        Offstage(
          offstage: widget.compact,
          child: Padding(
            padding: const EdgeInsets.only(top: Spacing.sm),
            child: _Filters(
              state: widget.state,
              queues: widget.queues,
              onQueue: widget.onQueue,
              onStatus: widget.onStatus,
              onToggleNotPrinted: widget.onToggleNotPrinted,
              onSort: widget.onSort,
              onClear: widget.onClear,
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchBox(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _search,
      builder: (context, _) => TextField(
        controller: _search,
        focusNode: _focus,
        onChanged: widget.onSearch,
        autocorrect: false,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          hintText: l10n.deskSearchPatients,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.text.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.deskSearchClear,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _search.clear();
                    widget.onSearch('');
                  },
                ),
        ),
      ),
    );
  }
}

/// The queue and status menus, the "not printed" toggle and sorting.
class _Filters extends StatelessWidget {
  const _Filters({
    required this.state,
    required this.queues,
    required this.onQueue,
    required this.onStatus,
    required this.onToggleNotPrinted,
    required this.onSort,
    required this.onClear,
  });

  final DeskTableState state;
  final List<QueueTypeBoardControl> queues;
  final ValueChanged<String?> onQueue;
  final ValueChanged<TokenStatus?> onStatus;
  final VoidCallback onToggleNotPrinted;
  final ValueChanged<TokenSort> onSort;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    String count(int n) => queueDeskFormatSerial(n, locale);
    final total = state.counts.values.fold<int>(0, (a, b) => a + b);
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DeskFilterMenu<String>(
          tooltip: l10n.deskFieldQueue,
          selected: state.query.queueTypeId,
          choices: [
            (value: null, label: l10n.deskFilterAllQueues),
            for (final q in queues)
              (value: q.queueTypeId, label: queueDeskQueueName(locale, q)),
          ],
          onSelected: onQueue,
        ),
        DeskFilterMenu<TokenStatus>(
          tooltip: l10n.deskColStatus,
          selected: state.query.status,
          choices: [
            (
              value: null,
              label: '${l10n.deskFilterAllStatuses} ${count(total)}',
            ),
            for (final status in _statusOrder)
              (
                value: status,
                label:
                    '${queueDeskStatusLabel(l10n, status)} '
                    '${count(state.counts[status] ?? 0)}',
              ),
          ],
          onSelected: onStatus,
        ),
        FilterChip(
          visualDensity: VisualDensity.compact,
          label: Text(l10n.deskFilterNotPrinted),
          selected: state.query.notPrintedOnly,
          onSelected: (_) => onToggleNotPrinted(),
        ),
        _SortMenu(query: state.query, onSort: onSort),
        if (state.query.hasFilters)
          IconButton(
            tooltip: l10n.deskClearFilters,
            icon: const Icon(Icons.filter_alt_off_outlined),
            onPressed: onClear,
          ),
      ],
    );
  }
}

/// Sorting for the card layout, which has no column headings; the same
/// choice again reverses the order.
class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.query, required this.onSort});

  final TokenQuery query;
  final ValueChanged<TokenSort> onSort;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      TokenSort.issued: l10n.deskColIssued,
      TokenSort.id: l10n.deskColPatientId,
      TokenSort.name: l10n.deskColName,
      TokenSort.serial: l10n.deskColSerial,
      TokenSort.queue: l10n.deskColQueue,
      TokenSort.wait: l10n.deskColWait,
      TokenSort.status: l10n.deskColStatus,
    };
    return PopupMenuButton<TokenSort>(
      tooltip: l10n.deskSortBy,
      // The sort icon points the way it sorts: up for ascending.
      icon: Transform.flip(
        flipY: query.ascending,
        child: const Icon(Icons.sort, size: 22),
      ),
      onSelected: onSort,
      itemBuilder: (_) => [
        for (final e in labels.entries)
          CheckedPopupMenuItem(
            value: e.key,
            checked: query.sort == e.key,
            child: Text(e.value),
          ),
      ],
    );
  }
}
