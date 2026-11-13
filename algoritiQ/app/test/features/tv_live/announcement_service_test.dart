// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:algoritiq_app/features/tv_live/application/announcement_service.dart';
import 'package:algoritiq_app/features/tv_live/data/tts_call_voice.dart';
import 'package:algoritiq_app/features/tv_live/domain/call_voice.dart';
import 'package:algoritiq_app/features/tv_live/domain/speech_synthesizer.dart';
import 'package:flutter_test/flutter_test.dart';

class _Speech implements SpeechSynthesizer {
  final spoken = <String>[];
  Future<List<int>?> Function(String text)? behaviour;

  @override
  Future<List<int>?> synthesize(String text) async {
    spoken.add(text);
    return behaviour != null ? behaviour!(text) : [1, 2, 3];
  }
}

class _Fixed implements CallVoice {
  _Fixed(this.clip);
  final List<int>? clip;

  @override
  Future<List<int>?> callClip({
    required int serial,
    required String queueTypeId,
    String queueLabelBn = '',
    bool recall = false,
  }) async => clip;

  @override
  Future<List<int>?> testClip() async => clip;
}

class _Throws extends _Fixed {
  _Throws() : super(null);

  @override
  Future<List<int>?> callClip({
    required int serial,
    required String queueTypeId,
    String queueLabelBn = '',
    bool recall = false,
  }) async => throw StateError('broken');
}

void main() {
  late _Speech speech;
  late AnnouncementService service;

  Future<String?> prepare(
    AnnouncementService s, {
    String callId = 'c1',
    int serial = 7,
  }) => s.prepare(
    callId: callId,
    serial: serial,
    queueTypeId: 'regular',
    queueLabelBn: 'সাধারণ',
  );

  setUp(() {
    speech = _Speech();
    service = AnnouncementService(
      voices: [TtsCallVoice(speech)],
      timeout: const Duration(milliseconds: 200),
      keep: 3,
    );
  });

  test('should say the serial as Bengali words with the queue name', () async {
    await prepare(service, serial: 1001);

    expect(speech.spoken.single, contains('এক হাজার এক'));
    expect(speech.spoken.single, contains('সাধারণ'));
  });

  test('should say 106 as "একশো ছয়" when the phone speaks it', () async {
    await prepare(service, serial: 106);

    // য় is sent as the one character U+09DF, which a voice reads as "ছয়"; the
    // two-character form (য + a dot) is read as "ছু".
    expect(speech.spoken.single, contains('একশো ছ\u09df'));
    expect(speech.spoken.single, isNot(contains('\u09af\u09bc')));
  });

  test('should send য় as one character in every spoken word', () {
    final text = TtsCallVoice.textFor(96, 'রিপোর্ট');

    // ছিয়ানব্বই has the letter too.
    expect(text, contains('ছিয়ানব্বই'.replaceAll('\u09af\u09bc', '\u09df')));
    expect(text, isNot(contains('\u09af\u09bc')));
  });

  test(
    'should hand back an address the TV can fetch and keep the clip',
    () async {
      final url = await prepare(service);

      expect(url, '/api/v1/tv/announcements/c1');
      expect(service.clip('c1'), [1, 2, 3]);
    },
  );

  test('should not speak the same words twice on a recall', () async {
    await prepare(service);
    await prepare(service, callId: 'c2');

    expect(speech.spoken, hasLength(1));
    expect(service.clip('c2'), [1, 2, 3]);
  });

  test('should give no address when the voice cannot be made', () async {
    speech.behaviour = (_) async => null;

    expect(await prepare(service), isNull);
    expect(service.clip('c1'), isNull);
  });

  test('should give no address when the voice throws', () async {
    speech.behaviour = (_) async => throw StateError('engine died');

    expect(await prepare(service), isNull);
  });

  test('should not keep the queue waiting for a voice that hangs', () async {
    speech.behaviour = (_) => Completer<List<int>?>().future;

    final watch = Stopwatch()..start();

    expect(await prepare(service), isNull);
    expect(watch.elapsedMilliseconds, lessThan(1500));
  });

  test('should forget the oldest clips', () async {
    for (var i = 0; i < 5; i++) {
      await prepare(service, callId: 'c$i', serial: i + 1);
    }

    expect(service.clip('c0'), isNull);
    expect(service.clip('c4'), isNotNull);
  });

  test('should make a test clip that says it is a test', () async {
    final clip = await service.testClip();

    expect(clip, [1, 2, 3]);
    expect(speech.spoken.single, contains('পরীক্ষা'));
  });

  group('several voices', () {
    test('should use the first voice that can make the clip', () async {
      final recorded = _Fixed([9, 9]);
      service = AnnouncementService(voices: [recorded, TtsCallVoice(speech)]);

      await prepare(service);

      expect(service.clip('c1'), [9, 9]);
      expect(speech.spoken, isEmpty);
    });

    test('should fall back when the first voice has no clip', () async {
      service = AnnouncementService(
        voices: [_Fixed(null), TtsCallVoice(speech)],
      );

      await prepare(service);

      expect(service.clip('c1'), [1, 2, 3]);
    });

    test('should fall back when the first voice throws', () async {
      service = AnnouncementService(voices: [_Throws(), TtsCallVoice(speech)]);

      expect(await prepare(service), isNotNull);
    });
  });
}
