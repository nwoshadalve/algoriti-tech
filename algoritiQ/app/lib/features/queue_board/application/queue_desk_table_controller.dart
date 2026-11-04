// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../access/application/tablet_session.dart';
import '../domain/board_models.dart';
import '../domain/token_query.dart';
import 'queue_board_providers.dart';

/// What the session table shows now: the question asked, the rows loaded so
/// far, and where the loading stands.
final class DeskTableState {
  const DeskTableState({
    this.query = const TokenQuery(),
    this.items = const [],
    this.total = 0,
    this.counts = const {},
    this.loading = true,
    this.loadingMore = false,
    this.failed = false,
  });

  final TokenQuery query;
  final List<BoardTokenView> items;

  /// Matches after every filter, across all pages.
  final int total;
  final Map<TokenStatus, int> counts;

  /// A first page is on its way. The old rows stay on screen meanwhile.
  final bool loading;
  final bool loadingMore;
  final bool failed;

  bool get hasMore => items.length < total;

  DeskTableState copyWith({
    TokenQuery? query,
    List<BoardTokenView>? items,
    int? total,
    Map<TokenStatus, int>? counts,
    bool? loading,
    bool? loadingMore,
    bool? failed,
  }) => DeskTableState(
    query: query ?? this.query,
    items: items ?? this.items,
    total: total ?? this.total,
    counts: counts ?? this.counts,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    failed: failed ?? this.failed,
  );
}

/// One table per chamber, read from the database a page at a time. Searching,
/// filtering and sorting start again from page one; scrolling loads the next
/// page; an action on a patient reloads what is loaded without a loader.
final queueDeskTableProvider = NotifierProvider.autoDispose
    .family<QueueDeskTableController, DeskTableState, String>(
      QueueDeskTableController.new,
    );

class QueueDeskTableController extends Notifier<DeskTableState> {
  QueueDeskTableController(this.chamberId);

  final String chamberId;

  /// Typing waits this long, so a word is one question, not one per letter.
  static const searchPause = Duration(milliseconds: 300);
  static const pageSize = 30;

  Timer? _pause;

  /// Numbers each question; an answer to an older one is dropped.
  var _latest = 0;

  @override
  DeskTableState build() {
    ref.onDispose(() => _pause?.cancel());
    Future<void>.microtask(load);
    return const DeskTableState();
  }

  Future<void> load() => _replace(state.query);

  void setSearch(String text) {
    state = state.copyWith(query: state.query.copyWith(search: text));
    _pause?.cancel();
    _pause = Timer(searchPause, () => unawaited(_replace(state.query)));
  }

  void setStatus(TokenStatus? status) => _change(
    status == null
        ? state.query.copyWith(clearStatus: true)
        : state.query.copyWith(status: status),
  );

  void setQueue(String? queueTypeId) => _change(
    queueTypeId == null
        ? state.query.copyWith(clearQueue: true)
        : state.query.copyWith(queueTypeId: queueTypeId),
  );

  void toggleNotPrinted() => _change(
    state.query.copyWith(notPrintedOnly: !state.query.notPrintedOnly),
  );

  /// The same heading again reverses the order; a new one starts ascending.
  void sortBy(TokenSort sort) {
    final same = state.query.sort == sort;
    _change(
      state.query.copyWith(
        sort: sort,
        ascending: same ? !state.query.ascending : true,
      ),
    );
  }

  void clearFilters() => _change(
    state.query.copyWith(
      search: '',
      clearStatus: true,
      clearQueue: true,
      notPrintedOnly: false,
    ),
  );

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    await _run(
      state.query.copyWith(offset: state.items.length, limit: pageSize),
      append: true,
    );
  }

  /// Asks again for every row loaded so far, without hiding any of them.
  Future<void> reload() => _run(
    state.query.copyWith(
      offset: 0,
      limit: state.items.length > pageSize ? state.items.length : pageSize,
    ),
    quiet: true,
  );

  void _change(TokenQuery query) {
    _pause?.cancel();
    state = state.copyWith(query: query);
    unawaited(_replace(query));
  }

  Future<void> _replace(TokenQuery query) =>
      _run(query.copyWith(offset: 0, limit: pageSize));

  Future<void> _run(
    TokenQuery query, {
    bool append = false,
    bool quiet = false,
  }) async {
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null) return;
    final mine = ++_latest;
    state = state.copyWith(
      loading: !append && !quiet,
      loadingMore: append,
      failed: false,
    );
    try {
      final page = await ref
          .read(queueBoardServiceProvider)
          .searchSessionTokens(account, chamberId, query);
      if (!ref.mounted || mine != _latest) return;
      state = state.copyWith(
        // A token issued meanwhile shifts rows down, so a page can repeat one.
        items: append
            ? _withoutRepeats([...state.items, ...page.items])
            : page.items,
        total: page.total,
        counts: page.counts,
        loading: false,
        loadingMore: false,
      );
    } on Object {
      if (!ref.mounted || mine != _latest) return;
      state = state.copyWith(loading: false, loadingMore: false, failed: true);
    }
  }

  static List<BoardTokenView> _withoutRepeats(List<BoardTokenView> rows) {
    final seen = <String>{};
    return [
      for (final row in rows)
        if (seen.add(row.id)) row,
    ];
  }
}
