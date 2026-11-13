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
import '../../../core/widgets/page_header.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/tablet_session.dart';
import '../application/queue_board_providers.dart';
import '../domain/session_history_models.dart';
import 'session_history_detail_page.dart';
import 'session_history_widgets.dart';

enum _Range { week, month, all }

/// Earlier queue sessions, newest first: when each ran and what happened.
/// A receptionist sees their own chambers; an admin sees all.
class SessionHistoryPage extends ConsumerStatefulWidget {
  const SessionHistoryPage({super.key});

  @override
  ConsumerState<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends ConsumerState<SessionHistoryPage> {
  static const _pageSize = 20;

  var _range = _Range.week;
  String? _chamberId;
  List<({String id, String name})> _chambers = const [];
  final _items = <SessionSummary>[];
  var _total = 0;
  var _loading = true;
  var _loadingMore = false;
  var _failed = false;
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_load()));
  }

  DateTime? get _from => switch (_range) {
    _Range.week => DateTime.now().subtract(const Duration(days: 7)),
    _Range.month => DateTime.now().subtract(const Duration(days: 30)),
    _Range.all => null,
  };

  Future<void> _load({bool more = false}) async {
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null) return;
    final generation = ++_generation;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
      }
      _failed = false;
    });
    try {
      final service = ref.read(queueBoardServiceProvider);
      if (_chambers.isEmpty) {
        _chambers = await service.historyChambers(account);
      }
      final page = await service.listSessions(
        account,
        SessionHistoryQuery(
          chamberId: _chamberId,
          from: _from,
          limit: _pageSize,
          offset: more ? _items.length : 0,
        ),
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        if (!more) _items.clear();
        _items.addAll(page.items);
        _total = page.total;
        _loading = false;
        _loadingMore = false;
      });
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _failed = true;
      });
    }
  }

  void _setRange(_Range range) {
    if (range == _range) return;
    _range = range;
    unawaited(_load());
  }

  void _setChamber(String? id) {
    if (id == _chamberId) return;
    _chamberId = id;
    unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pad = EdgeInsets.fromLTRB(
      Spacing.md,
      Spacing.md,
      Spacing.md,
      Spacing.md + MediaQuery.paddingOf(context).bottom,
    );
    return Padding(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: l10n.historyTitle,
            description: l10n.historyIntro,
            dense: true,
          ),
          _filters(l10n),
          const SizedBox(height: Spacing.md),
          Expanded(child: _body(l10n)),
        ],
      ),
    );
  }

  Widget _filters(AppLocalizations l10n) {
    final labels = {
      _Range.week: l10n.historyRange7,
      _Range.month: l10n.historyRange30,
      _Range.all: l10n.historyRangeAll,
    };
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final entry in labels.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: _range == entry.key,
            onSelected: (_) => _setRange(entry.key),
          ),
        if (_chambers.length > 1)
          DropdownButton<String?>(
            value: _chamberId,
            hint: Text(l10n.historyChamberLabel),
            onChanged: _setChamber,
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l10n.historyAllChambers),
              ),
              for (final c in _chambers)
                DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
            ],
          ),
      ],
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (_loading) return const Center(child: BrandLoader(semanticLabel: ''));
    if (_failed && _items.isEmpty) {
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
    if (_items.isEmpty) return Center(child: Text(l10n.historyEmpty));
    final more = _items.length < _total;
    return ListView.separated(
      itemCount: _items.length + (more ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: Spacing.sm),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return Align(
            alignment: Alignment.center,
            child: _loadingMore
                ? const BrandLoader(semanticLabel: '')
                : OutlinedButton(
                    onPressed: () => unawaited(_load(more: true)),
                    child: Text(l10n.historyShowMore),
                  ),
          );
        }
        final session = _items[index];
        return SessionHistoryCard(
          session: session,
          showChamber: _chambers.length > 1,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SessionHistoryDetailPage(sessionId: session.id),
            ),
          ),
        );
      },
    );
  }
}
