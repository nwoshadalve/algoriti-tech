// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:algoritiq_app/features/access/domain/account.dart';
import 'package:algoritiq_app/features/queue/data/drift_queue_repository.dart';
import 'package:algoritiq_app/features/queue/domain/queue_models.dart';
import 'package:algoritiq_app/features/queue_board/application/queue_board_service.dart';
import 'package:algoritiq_app/features/tv_live/application/announcement_service.dart';
import 'package:algoritiq_app/features/tv_live/application/tv_live_publisher.dart';
import 'package:algoritiq_app/features/queue_board/domain/board_models.dart';
import 'package:algoritiq_app/features/queue_board/domain/token_query.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/queue_desk_kit.dart';

class _Voice implements AnnouncementPreparer {
  _Voice(this.url);
  final String? url;

  @override
  Future<String?> prepare({
    required String callId,
    required int serial,
    required String queueTypeId,
    required String queueLabelBn,
    bool recall = false,
  }) async => url;
}

class _Call {
  _Call(this.serial, this.callId, this.announcementUrl);
  final int serial;
  final String callId;
  final String? announcementUrl;
}

class _RecordingTv implements TvLivePublisher {
  final calls = <_Call>[];

  @override
  Future<Map<String, Object?>> buildLiveSnapshot() async => const {};

  @override
  Future<void> notifyQueueUpdated(String chamberId) async {}

  @override
  Future<void> notifyTokenCalled({
    required String chamberId,
    required String tokenId,
    required String queueTypeId,
    required int serial,
    required String callId,
    String? announcementUrl,
  }) async => calls.add(_Call(serial, callId, announcementUrl));
}

void main() {
  test('should load queue board snapshot for a chamber', () async {
    final desk = await QueueDeskKit.open();

    final snapshot = await desk.board.loadBoard(desk.account, deskChamberId);

    expect(snapshot.chamberId, deskChamberId);
    expect(snapshot.sessionOpen, isFalse);
  });

  test('should show a new patient in the session at once', () async {
    final desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);

    final issued = await desk.addPatient('করিম', '01711000111');

    expect(issued.printStatus, 'PENDING');
    final board = await desk.board.loadBoard(desk.account, deskChamberId);
    expect(board.tokens.map((t) => t.patientName), ['করিম']);
    expect(board.tokens.single.status, TokenStatus.waiting);
  });

  test('should not save the patient when the token cannot be issued', () async {
    final desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);

    await expectLater(
      desk.addPatient('করিম', '01711000111', queue: 'no-such-queue'),
      throwsA(isA<QueueBoardRefused>()),
    );

    expect(await desk.searchNames('01711000111'), isEmpty);
  });

  test('should save nothing when the session is closed', () async {
    final desk = await QueueDeskKit.open();

    await expectLater(
      desk.addPatient('করিম', '01711000111'),
      throwsA(isA<QueueBoardRefused>()),
    );

    expect(await desk.searchNames('01711000111'), isEmpty);
  });

  test(
    'should issue a token when the chamber has its own copy of the queue types',
    () async {
      // Regression: a type id exists once per owner (clinic default and
      // chamber override), and issuing looked it up by id alone, so it matched
      // two rows and failed after the patient was already saved.
      final desk = await QueueDeskKit.open();
      await desk.board.loadBoard(desk.account, deskChamberId);
      await desk.queueRepo.saveChamberSettings(
        deskChamberId,
        const ChamberQueueSettings(useClinicDefaults: false),
      );
      final clinicTypes = await desk.queueRepo.loadTypesForOwner(
        clinicOwnerKey,
      );
      for (final type in clinicTypes) {
        await desk.queueRepo.upsertType(ownerKey: deskChamberId, type: type);
      }
      await desk.board.startSession(desk.account, deskChamberId);

      final issued = await desk.addPatient(
        'করিম',
        '01711000111',
        queue: clinicTypes.first.id,
      );

      expect(issued.token.serial, clinicTypes.first.startNumber);
    },
  );

  group('patient search', () {
    Future<QueueDeskKit> deskWithPatients() async {
      final desk = await QueueDeskKit.open();
      await desk.board.startSession(desk.account, deskChamberId);
      await desk.addPatient('করিম উদ্দিন', '01711000111', command: 'a');
      await desk.addPatient('Rahima Begum', '01822000222', command: 'b');
      return desk;
    }

    test('should find by part of a name written in Bengali', () async {
      final desk = await deskWithPatients();

      expect(await desk.searchNames('করিম'), ['করিম উদ্দিন']);
      expect(await desk.searchNames('উদ্দিন'), ['করিম উদ্দিন']);
    });

    test(
      'should find by a name written in English in any letter case',
      () async {
        final desk = await deskWithPatients();

        expect(await desk.searchNames('rahima'), ['Rahima Begum']);
        expect(await desk.searchNames('BEGUM'), ['Rahima Begum']);
      },
    );

    test('should find by the start of a phone number', () async {
      final desk = await deskWithPatients();

      expect(await desk.searchNames('0171'), ['করিম উদ্দিন']);
      expect(await desk.searchNames('01822000222'), ['Rahima Begum']);
    });

    test('should find by patient id', () async {
      final desk = await deskWithPatients();
      final board = await desk.board.loadBoard(desk.account, deskChamberId);
      final id = board.tokens
          .firstWhere((t) => t.patientName == 'করিম উদ্দিন')
          .clinicPatientId;

      expect(await desk.searchNames(id), ['করিম উদ্দিন']);
    });

    test('should treat % and _ in the search as plain text', () async {
      final desk = await deskWithPatients();

      expect(await desk.searchNames('%'), isEmpty);
      expect(await desk.searchNames('_'), isEmpty);
    });

    test('should find nobody for an unknown name', () async {
      final desk = await deskWithPatients();

      expect(await desk.searchNames('অজানা'), isEmpty);
    });
  });

  test('should update a patient so search finds the new details', () async {
    final desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
    final issued = await desk.addPatient('করিম', '01711000111');

    final updated = await desk.board.updatePatient(
      desk.account,
      issued.token.patientId,
      const PatientInput(
        name: 'করিম হোসেন',
        phone: '01911999888',
        approximateAgeYears: 40,
        gender: PatientGender.male,
      ),
    );

    expect(updated.name, 'করিম হোসেন');
    expect(updated.gender, PatientGender.male);
    expect(await desk.searchNames('01911'), ['করিম হোসেন']);
    expect(await desk.searchNames('01711'), isEmpty);
  });

  test('should keep the token when the print fails', () async {
    final desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
    final issued = await desk.addPatient('করিম', '01711000111');

    await desk.board.recordPrintResult(
      desk.account,
      issued.token.id,
      issued.printAttemptId,
      PrintAttemptStatus.failed,
    );

    final board = await desk.board.loadBoard(desk.account, deskChamberId);
    expect(board.tokens.single.latestPrintStatus, 'FAILED');
    expect(board.tokens.single.status, TokenStatus.waiting);
    expect(board.printerBusyTokenId, isNull);
  });

  test('should free the printer when a print never reported back', () async {
    final desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
    final issued = await desk.addPatient('করিম', '01711000111');
    expect(
      (await desk.board.loadBoard(
        desk.account,
        deskChamberId,
      )).printerBusyTokenId,
      issued.token.id,
    );

    desk.kit.clock.advance(
      QueueBoardService.printAttemptTimeout + const Duration(seconds: 1),
    );

    final board = await desk.board.loadBoard(desk.account, deskChamberId);
    expect(board.printerBusyTokenId, isNull);
    expect(board.tokens.single.latestPrintStatus, 'FAILED');
  });

  test('should free the printer when the app stopped mid-issue', () async {
    final desk = await QueueDeskKit.open();
    await desk.board.startSession(desk.account, deskChamberId);
    final issued = await desk.addPatient('করিম', '01711000111');
    // The token says PENDING but its attempt was never written.
    final db = desk.kit.database;
    await db.delete(db.tokenPrintAttempts).go();

    desk.kit.clock.advance(
      QueueBoardService.printAttemptTimeout + const Duration(seconds: 1),
    );

    final board = await desk.board.loadBoard(desk.account, deskChamberId);
    expect(board.printerBusyTokenId, isNull);
    expect(board.tokens.single.id, issued.token.id);
    expect(board.tokens.single.latestPrintStatus, 'FAILED');
  });

  group('announcing a call', () {
    test(
      'should send the spoken call with the token that was called',
      () async {
        final tv = _RecordingTv();
        final desk = await QueueDeskKit.open(
          tvLive: tv,
          announcer: _Voice('/clip/1'),
        );
        await desk.board.startSession(desk.account, deskChamberId);
        await desk.addPatient('করিম', '01711000111');

        final called = await desk.board.callNext(
          desk.account,
          deskChamberId,
          'regular',
        );

        expect(tv.calls.single.serial, called.serial);
        expect(tv.calls.single.announcementUrl, '/clip/1');
      },
    );

    test('should send a fresh call id on a recall', () async {
      final tv = _RecordingTv();
      final desk = await QueueDeskKit.open(
        tvLive: tv,
        announcer: _Voice('/clip'),
      );
      await desk.board.startSession(desk.account, deskChamberId);
      await desk.addPatient('করিম', '01711000111');
      await desk.board.callNext(desk.account, deskChamberId, 'regular');

      await desk.board.recall(desk.account, deskChamberId, 'regular');

      expect(tv.calls, hasLength(2));
      expect(tv.calls[0].callId, isNot(tv.calls[1].callId));
      expect(tv.calls[1].announcementUrl, '/clip');
    });

    test('should still call the patient when no voice can be made', () async {
      final tv = _RecordingTv();
      final desk = await QueueDeskKit.open(tvLive: tv, announcer: _Voice(null));
      await desk.board.startSession(desk.account, deskChamberId);
      await desk.addPatient('করিম', '01711000111');

      await desk.board.callNext(desk.account, deskChamberId, 'regular');

      expect(tv.calls.single.announcementUrl, isNull);
    });
  });

  group('one session at a time', () {
    Future<void> addChamber(QueueDeskKit desk, String id, String name) => desk
        .kit
        .database
        .into(desk.kit.database.chambers)
        .insert(
          ChambersCompanion.insert(
            id: id,
            doctorId: 'seed-doctor',
            name: name,
            patientIdPrefix: '777',
            createdAt: DateTime.utc(2026).millisecondsSinceEpoch,
          ),
        );

    test('should refuse a second chamber while one session is open', () async {
      final desk = await QueueDeskKit.open();
      await addChamber(desk, 'other', 'Room 2');
      await desk.board.startSession(desk.account, deskChamberId);

      await expectLater(
        desk.board.startSession(desk.account, 'other'),
        throwsA(
          isA<QueueBoardRefused>()
              .having(
                (e) => e.problem,
                'problem',
                QueueBoardProblem.otherSessionOpen,
              )
              .having((e) => e.code, 'chamber', 'Room 1'),
        ),
      );
    });

    test(
      'should let the other chamber start once the first has ended',
      () async {
        final desk = await QueueDeskKit.open();
        await addChamber(desk, 'other', 'Room 2');
        await desk.board.startSession(desk.account, deskChamberId);
        await desk.board.endSession(desk.account, deskChamberId);

        await desk.board.startSession(desk.account, 'other');

        final board = await desk.board.loadBoard(desk.account, 'other');
        expect(board.sessionOpen, isTrue);
      },
    );
  });

  group('ending the session', () {
    test('should close the session and let a new one start', () async {
      final desk = await QueueDeskKit.open();
      await desk.board.startSession(desk.account, deskChamberId);
      await desk.addPatient('করিম', '01711000111');

      await desk.board.endSession(desk.account, deskChamberId);

      final closed = await desk.board.loadBoard(desk.account, deskChamberId);
      expect(closed.sessionOpen, isFalse);
      await desk.board.startSession(desk.account, deskChamberId);
      final reopened = await desk.board.loadBoard(desk.account, deskChamberId);
      expect(reopened.sessionOpen, isTrue);
      expect(reopened.queueControls.first.waitingCount, 0);
    });

    test('should refuse when no session is open', () async {
      final desk = await QueueDeskKit.open();

      expect(
        () => desk.board.endSession(desk.account, deskChamberId),
        throwsA(isA<Object>()),
      );
    });

    test('should refuse tokens for a closed session', () async {
      final desk = await QueueDeskKit.open();
      await desk.board.startSession(desk.account, deskChamberId);
      await desk.board.endSession(desk.account, deskChamberId);

      expect(
        () => desk.addPatient('করিম', '01711000111'),
        throwsA(isA<Object>()),
      );
    });
  });

  group('search digits', () {
    Future<List<String>> found(QueueDeskKit desk, String text) async {
      final page = await desk.board.searchSessionTokens(
        desk.account,
        deskChamberId,
        TokenQuery(search: text),
      );
      return [for (final t in page.items) t.patientName];
    }

    test('should find a phone typed in Bengali digits', () async {
      final desk = await QueueDeskKit.open();
      await desk.board.startSession(desk.account, deskChamberId);
      await desk.addPatient('করিম', '01711000111');

      expect(await found(desk, '০১৭১১০০০'), ['করিম']);
    });

    test('should not match every phone on a short number', () async {
      final desk = await QueueDeskKit.open();
      await desk.board.startSession(desk.account, deskChamberId);
      await desk.addPatient('করিম', '01711000111', command: 'a');
      await desk.addPatient('রহিম', '01722000222', command: 'b');

      // "17" is no one's serial or ID, only the start of both phones.
      expect(await found(desk, '17'), isEmpty);
    });
  });

  group('session table page', () {
    test('should return views with patient and queue names', () async {
      final desk = await QueueDeskKit.open();
      await desk.board.startSession(desk.account, deskChamberId);
      await desk.addPatient('করিম', '01711000111', queue: 'report');

      final page = await desk.board.searchSessionTokens(
        desk.account,
        deskChamberId,
        const TokenQuery(search: 'করিম'),
      );

      expect(page.total, 1);
      expect(page.items.single.patientName, 'করিম');
      expect(page.items.single.queueEnglishName, 'Report');
      expect(page.counts[TokenStatus.waiting], 1);
    });

    test('should be empty while no session is open', () async {
      final desk = await QueueDeskKit.open();

      final page = await desk.board.searchSessionTokens(
        desk.account,
        deskChamberId,
        const TokenQuery(),
      );

      expect(page.items, isEmpty);
      expect(page.total, 0);
      expect(page.counts, isEmpty);
    });

    test('should refuse a receptionist who has no chamber', () async {
      final desk = await QueueDeskKit.open();
      final stranger = Account(
        id: 'nobody',
        username: 'nobody',
        displayName: 'Nobody',
        email: '',
        role: Role.receptionist,
        createdAt: DateTime.utc(2026),
      );

      await expectLater(
        desk.board.searchSessionTokens(
          stranger,
          deskChamberId,
          const TokenQuery(),
        ),
        throwsA(
          isA<QueueBoardRefused>().having(
            (e) => e.problem,
            'problem',
            QueueBoardProblem.forbidden,
          ),
        ),
      );
    });

    test('should load the board without tokens when asked', () async {
      final desk = await QueueDeskKit.open();
      await desk.board.startSession(desk.account, deskChamberId);
      await desk.addPatient('করিম', '01711000111');
      await desk.board.callNext(desk.account, deskChamberId, 'regular');

      final board = await desk.board.loadBoard(
        desk.account,
        deskChamberId,
        includeTokens: false,
      );

      expect(board.tokens, isEmpty);
      expect(board.calledToken?.patientName, 'করিম');
      expect(board.queueControls, isNotEmpty);
      expect(
        (await desk.board.loadBoard(desk.account, deskChamberId)).tokens,
        hasLength(1),
      );
    });
  });
}
