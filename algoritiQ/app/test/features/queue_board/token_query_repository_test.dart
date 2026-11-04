// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue_board/data/drift_queue_board_repository.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/queue_board/domain/token_query.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

/// Queue display order the desk would pass: regular, report, dressing.
const _order = {'regular': 1, 'report': 2, 'dressing': 3};

void main() {
  late QueueDeskKit desk;

  Future<TokenRows> query(TokenQuery q) async {
    final session = await desk.boardRepo.openSessionForChamber(deskChamberId);
    return desk.boardRepo.querySessionTokens(
      sessionId: session!.id,
      query: q,
      nowMs: desk.kit.clock.now.millisecondsSinceEpoch,
      queueOrder: _order,
    );
  }

  Future<List<int>> serials(TokenQuery q) async => [
    for (final row in (await query(q)).rows) row.serial,
  ];

  /// Adds a patient one minute after the previous one, so issue times differ.
  Future<IssuedTokenResult> add(
    String name,
    String phone, {
    String? english,
    String queue = 'regular',
  }) async {
    desk.kit.clock.advance(const Duration(minutes: 1));
    return desk.addPatient(
      name,
      phone,
      englishName: english,
      queue: queue,
      command: 'cmd-$phone',
    );
  }

  setUp(() async {
    desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
  });

  group('search', () {
    setUp(() async {
      await add('করিম উদ্দিন', '01711000111', english: 'Karim Uddin');
      await add('রহিমা বেগম', '01822000222', english: 'Rahima Begum');
      await add('100% সালমা', '01933000333', queue: 'report');
    });

    test(
      'should match a Bengali name part, English name in any case',
      () async {
        expect(await serials(const TokenQuery(search: 'করিম')), [1001]);
        expect(await serials(const TokenQuery(search: 'BEGUM')), [1002]);
      },
    );

    test('should match patient id prefix, serial and phone prefix', () async {
      final id = (await query(const TokenQuery(search: 'করিম'))).rows;
      final patient = await desk.boardRepo.patientById(id.single.patientId);
      expect(
        await serials(TokenQuery(search: patient!.clinicPatientId)),
        contains(1001),
      );
      expect(await serials(const TokenQuery(search: '2001')), [2001]);
      expect(await serials(const TokenQuery(search: '01822')), [1002]);
      // Fewer digits than a phone search needs: not a prefix of every number.
      expect(await serials(const TokenQuery(search: '0182')), isEmpty);
    });

    test('should treat % _ and a quote as plain text', () async {
      expect(await serials(const TokenQuery(search: '%')), [2001]);
      expect(await serials(const TokenQuery(search: '_')), isEmpty);
      expect(await serials(const TokenQuery(search: "x'; --")), isEmpty);
    });

    test('should find nothing for an unknown name', () async {
      final result = await query(const TokenQuery(search: 'অজানা'));
      expect(result.rows, isEmpty);
      expect(result.total, 0);
    });
  });

  group('filters and counts', () {
    setUp(() async {
      await add('এক', '01711000001');
      await add('দুই', '01711000002', queue: 'report');
      await add('তিন', '01711000003');
      // Serial 1001 called, 1002 stays waiting (report), 1003 cancelled.
      await desk.board.callNext(desk.account, deskChamberId, 'regular');
      final third = (await query(const TokenQuery())).rows
          .firstWhere((r) => r.serial == 1002);
      await desk.board.cancelToken(desk.account, third.id, '');
    });

    test('should filter by status while counts ignore that filter', () async {
      final result = await query(const TokenQuery(status: TokenStatus.called));
      expect(result.rows.map((r) => r.serial), [1001]);
      expect(result.total, 1);
      expect(result.counts[TokenStatus.called], 1);
      expect(result.counts[TokenStatus.waiting], 1);
      expect(result.counts[TokenStatus.cancelled], 1);
    });

    test('should filter by queue', () async {
      expect(await serials(const TokenQuery(queueTypeId: 'report')), [2001]);
    });

    test('should filter to tokens that are not printed', () async {
      final rows = (await query(const TokenQuery())).rows;
      await desk.boardRepo.setLatestPrintStatus(rows[0].id, 'SENT');
      await desk.boardRepo.setLatestPrintStatus(rows[1].id, 'FAILED');
      final unprinted = await query(const TokenQuery(notPrintedOnly: true));
      expect(unprinted.rows.map((r) => r.id), isNot(contains(rows[0].id)));
      expect(unprinted.rows.map((r) => r.id), contains(rows[1].id));
    });

    test('counts should honour search and queue filter', () async {
      final result = await query(const TokenQuery(queueTypeId: 'report'));
      expect(result.counts[TokenStatus.waiting], 1);
      expect(result.counts[TokenStatus.called] ?? 0, 0);
    });
  });

  group('sorting', () {
    setUp(() async {
      // issue order: 1001 (ঘ), 2001 (ক), 1002 (খ)
      await add('ঘ', '01711000001');
      await add('ক', '01711000002', queue: 'report');
      await add('খ', '01711000003');
      await desk.board.callNext(desk.account, deskChamberId, 'regular');
    });

    Future<List<int>> sorted(TokenSort sort, {bool ascending = true}) =>
        serials(TokenQuery(sort: sort, ascending: ascending));

    test('should sort newest issued first by default', () async {
      expect(await serials(const TokenQuery()), [1002, 2001, 1001]);
    });

    test('should sort by issue time both ways', () async {
      expect(await sorted(TokenSort.issued), [1001, 2001, 1002]);
    });

    test('should sort by Bengali name both ways', () async {
      expect(await sorted(TokenSort.name), [2001, 1002, 1001]);
      expect(await sorted(TokenSort.name, ascending: false), [
        1001,
        1002,
        2001,
      ]);
    });

    test('should sort by serial both ways', () async {
      expect(await sorted(TokenSort.serial), [1001, 1002, 2001]);
      expect(await sorted(TokenSort.serial, ascending: false), [
        2001,
        1002,
        1001,
      ]);
    });

    test('should sort by queue display order, then serial', () async {
      expect(await sorted(TokenSort.queue), [1001, 1002, 2001]);
      expect(await sorted(TokenSort.queue, ascending: false), [
        2001,
        1002,
        1001,
      ]);
    });

    test('should sort by patient id both ways', () async {
      expect(await sorted(TokenSort.id), [1001, 2001, 1002]);
      expect(await sorted(TokenSort.id, ascending: false), [1002, 2001, 1001]);
    });

    test('should sort by status in lifecycle order', () async {
      // 1001 is called, the other two wait.
      expect((await sorted(TokenSort.status)).first, isNot(1001));
      expect((await sorted(TokenSort.status)).last, 1001);
      expect((await sorted(TokenSort.status, ascending: false)).first, 1001);
    });

    test('should sort by wait, frozen at the first call', () async {
      desk.kit.clock.advance(const Duration(hours: 1));
      // 1001 waited 1 minute for its call; the others have waited ~1 hour.
      expect((await sorted(TokenSort.wait)).first, 1001);
      expect(
        (await sorted(TokenSort.wait, ascending: false)).first,
        isNot(1001),
      );
    });
  });

  group('paging', () {
    test('should give every row once with no gaps over 70 tokens', () async {
      for (var i = 0; i < 70; i++) {
        await add(
          'রোগী $i',
          '0171100${(1000 + i).toString()}',
          queue: i.isEven ? 'regular' : 'report',
        );
      }
      final seen = <String>[];
      for (var offset = 0; offset < 100; offset += 30) {
        final page = await query(TokenQuery(limit: 30, offset: offset));
        expect(page.total, 70);
        seen.addAll(page.rows.map((r) => r.id));
      }
      expect(seen, hasLength(70));
      expect(seen.toSet(), hasLength(70));
    });

    test('should return no rows past the end but keep the total', () async {
      await add('এক', '01711000001');
      final page = await query(const TokenQuery(offset: 90));
      expect(page.rows, isEmpty);
      expect(page.total, 1);
    });

    test('should order ties on the sort key by token id', () async {
      // Two patients with the same name: name sort must still be stable.
      await add('একই', '01711000001');
      await add('একই', '01711000002');
      final first = await query(
        const TokenQuery(sort: TokenSort.name, ascending: true),
      );
      final second = await query(
        const TokenQuery(sort: TokenSort.name, ascending: true),
      );
      expect(first.rows.map((r) => r.id), second.rows.map((r) => r.id));
      final ids = first.rows.map((r) => r.id).toList();
      expect(ids, [...ids]..sort());
    });

    test(
      'should freeze the wait of a token cancelled before its call',
      () async {
        await add('এক', '01711000001');
        await add('দুই', '01711000002');
        final first = (await query(
          const TokenQuery(sort: TokenSort.serial, ascending: true),
        )).rows.first;
        await desk.board.cancelToken(desk.account, first.id, '');
        desk.kit.clock.advance(const Duration(hours: 1));

        // The cancelled one waited ~1 minute; the other has waited ~1 hour.
        expect(
          await serials(
            const TokenQuery(sort: TokenSort.wait, ascending: true),
          ),
          [1001, 1002],
        );
      },
    );

    test('should clamp a future issue time to a zero wait', () async {
      await add('এক', '01711000001');
      desk.kit.clock.advance(const Duration(hours: -2));
      expect(await serials(const TokenQuery(sort: TokenSort.wait)), [1001]);
    });
  });
}
