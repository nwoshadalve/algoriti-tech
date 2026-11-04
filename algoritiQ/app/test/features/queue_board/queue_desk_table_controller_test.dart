// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:algoritiq_app/features/access/application/tablet_session.dart';
import 'package:algoritiq_app/features/access/domain/account.dart';
import 'package:algoritiq_app/features/queue_board/application/queue_board_providers.dart';
import 'package:algoritiq_app/features/queue_board/application/queue_board_service.dart';
import 'package:algoritiq_app/features/queue_board/application/queue_desk_table_controller.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/queue_board/domain/token_query.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _chamber = 'chamber-1';

final _admin = Account(
  id: 'admin',
  username: 'admin',
  displayName: 'Admin',
  email: '',
  role: Role.admin,
  createdAt: DateTime.utc(2026),
);

class _Session extends TabletSession {
  @override
  TabletSignIn? build() => TabletSignIn(_admin, 'token');
}

BoardTokenView _view(int serial) => BoardTokenView(
  id: 'token-$serial',
  serial: serial,
  queueTypeId: 'regular',
  queueEnglishName: 'Regular',
  queueBengaliName: 'সাধারণ',
  patientId: 'patient-$serial',
  clinicPatientId: '$serial',
  patientBengaliName: 'রোগী $serial',
  status: TokenStatus.waiting,
  issuedAt: DateTime.utc(2026),
);

/// A board that answers token queries from [answer], and records them.
class _FakeBoard extends Fake implements QueueBoardService {
  final queries = <TokenQuery>[];
  Future<TokenPage> Function(TokenQuery query) answer = (q) async =>
      TokenPage.empty;

  @override
  Future<TokenPage> searchSessionTokens(
    Account account,
    String chamberId,
    TokenQuery query,
  ) {
    queries.add(query);
    return answer(query);
  }
}

/// [total] tokens numbered from 1001, served in pages by offset and limit.
Future<TokenPage> Function(TokenQuery) _pages(int total) =>
    (q) async => TokenPage(
      items: [
        for (var i = q.offset; i < q.offset + q.limit && i < total; i++)
          _view(1001 + i),
      ],
      total: total,
      counts: {TokenStatus.waiting: total},
    );

void main() {
  late _FakeBoard board;
  late ProviderContainer container;

  QueueDeskTableController controller() =>
      container.read(queueDeskTableProvider(_chamber).notifier);
  DeskTableState state() => container.read(queueDeskTableProvider(_chamber));

  /// Lets the initial load (and anything else queued) finish.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 20));

  setUp(() {
    board = _FakeBoard();
    container = ProviderContainer(
      overrides: [
        queueBoardServiceProvider.overrideWithValue(board),
        tabletSessionProvider.overrideWith(_Session.new),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Starts listening (the provider is auto-disposed) and loads page one.
  Future<void> open() async {
    container.listen(queueDeskTableProvider(_chamber), (_, _) {});
    await settle();
  }

  test('should load the first page when opened', () async {
    board.answer = _pages(70);

    await open();

    expect(state().items, hasLength(30));
    expect(state().total, 70);
    expect(state().counts[TokenStatus.waiting], 70);
    expect(state().loading, isFalse);
    expect(state().hasMore, isTrue);
  });

  test('should send one query after a pause in typing', () async {
    board.answer = _pages(5);
    await open();
    board.queries.clear();

    controller().setSearch('ক');
    controller().setSearch('করি');
    controller().setSearch('করিম');
    expect(
      state().query.search,
      'করিম',
      reason: 'the box shows what was typed',
    );
    await Future<void>.delayed(
      QueueDeskTableController.searchPause + const Duration(milliseconds: 60),
    );

    expect(board.queries, hasLength(1));
    expect(board.queries.single.search, 'করিম');
    expect(board.queries.single.offset, 0);
  });

  test('should never let a slower older answer replace a newer one', () async {
    board.answer = _pages(5);
    await open();
    final slow = Completer<TokenPage>();
    board.answer = (q) => q.status == TokenStatus.called
        ? slow.future
        : Future.value(
            TokenPage(items: [_view(2001)], total: 1, counts: const {}),
          );

    controller().setStatus(TokenStatus.called); // slow
    controller().setStatus(TokenStatus.waiting); // fast, newer
    await settle();
    slow.complete(TokenPage(items: [_view(1001)], total: 1, counts: const {}));
    await settle();

    expect(state().items.single.serial, 2001);
    expect(state().query.status, TokenStatus.waiting);
  });

  test(
    'should toggle the direction on the same heading and reset on a new one',
    () async {
      board.answer = _pages(5);
      await open();

      controller().sortBy(TokenSort.name);
      expect(state().query.sort, TokenSort.name);
      expect(state().query.ascending, isTrue);
      controller().sortBy(TokenSort.name);
      expect(state().query.ascending, isFalse);
      controller().sortBy(TokenSort.serial);
      expect(state().query.sort, TokenSort.serial);
      expect(state().query.ascending, isTrue);
    },
  );

  test('should append the next page and stop at the total', () async {
    board.answer = _pages(45);
    await open();

    await controller().loadMore();
    expect(state().items, hasLength(45));
    expect(state().hasMore, isFalse);
    board.queries.clear();
    await controller().loadMore();

    expect(board.queries, isEmpty);
    expect(state().items.map((t) => t.serial).toSet(), hasLength(45));
  });

  test('should not repeat a row when a new token shifts the pages', () async {
    board.answer = _pages(40);
    await open();
    // Newest first: a token issued meanwhile pushes row 30 onto page two.
    board.answer = (q) async => TokenPage(
      items: [
        for (var i = q.offset - 1; i < q.offset - 1 + q.limit && i < 40; i++)
          _view(1001 + i),
      ],
      total: 41,
      counts: const {},
    );

    await controller().loadMore();

    final serials = state().items.map((t) => t.serial).toList();
    expect(serials.toSet(), hasLength(serials.length));
  });

  test(
    'should start again from the first page when a filter changes',
    () async {
      board.answer = _pages(70);
      await open();
      await controller().loadMore();
      board.queries.clear();

      controller().toggleNotPrinted();
      await settle();

      expect(board.queries.single.offset, 0);
      expect(board.queries.single.notPrintedOnly, isTrue);
      expect(state().items, hasLength(30));
    },
  );

  test('should reload in place without hiding the rows', () async {
    board.answer = _pages(70);
    await open();
    await controller().loadMore();
    board.queries.clear();
    var sawLoading = false;
    container.listen(queueDeskTableProvider(_chamber), (_, next) {
      sawLoading = sawLoading || next.loading;
    });

    await controller().reload();

    expect(sawLoading, isFalse);
    expect(board.queries.single.limit, 60, reason: 'every loaded row again');
    expect(board.queries.single.offset, 0);
    expect(state().items, hasLength(60));
  });

  test('should keep the rows and flag a failure', () async {
    board.answer = _pages(5);
    await open();
    board.answer = (_) async => throw StateError('db');

    await controller().reload();

    expect(state().failed, isTrue);
    expect(state().items, hasLength(5));
  });

  test('should clear every filter at once', () async {
    board.answer = _pages(5);
    await open();
    controller().setStatus(TokenStatus.called);
    controller().setQueue('report');
    controller().toggleNotPrinted();
    await settle();

    controller().clearFilters();
    await settle();

    final q = state().query;
    expect(q.hasFilters, isFalse);
  });

  test('should show an empty table when no session is open', () async {
    board.answer = (_) async => TokenPage.empty;

    await open();

    expect(state().items, isEmpty);
    expect(state().total, 0);
    expect(state().failed, isFalse);
  });
}
