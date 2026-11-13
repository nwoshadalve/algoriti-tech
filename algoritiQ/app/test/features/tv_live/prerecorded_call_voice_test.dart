// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

import 'package:algoritiq_app/features/tv_live/application/call_clip_keys.dart';
import 'package:algoritiq_app/features/tv_live/data/prerecorded_call_voice.dart';
import 'package:algoritiq_app/features/tv_live/data/wav.dart';
import 'package:flutter_test/flutter_test.dart';

/// A clip of [samples] samples, each worth [value], at [rate] Hz.
List<int> _clip(int value, {int samples = 100, int rate = 24000}) {
  final pcm = Int16List(samples)..fillRange(0, samples, value);
  return Wav.build(pcm.buffer.asUint8List(), sampleRate: rate);
}

void main() {
  group('louder', () {
    int peakOf(List<int> wav) {
      final pcm = Wav.parse(wav).pcm;
      final view = ByteData.sublistView(pcm);
      var peak = 0;
      for (var i = 0; i < pcm.length ~/ 2; i++) {
        final v = view.getInt16(i * 2, Endian.little).abs();
        if (v > peak) peak = v;
      }
      return peak;
    }

    test('should bring a quiet clip up without clipping', () {
      final quiet = _clip(1000);

      final loud = Wav.louder(quiet);

      expect(peakOf(loud), greaterThan(peakOf(quiet) * 10));
      expect(peakOf(loud), lessThanOrEqualTo(32767));
      expect(Wav.parse(loud).pcm.length, Wav.parse(quiet).pcm.length);
    });

    test('should keep the sign of every sample', () {
      final pcm = Int16List.fromList([1000, -1000, 500, -500]);
      final wav = Wav.build(pcm.buffer.asUint8List(), sampleRate: 24000);

      final out = Wav.parse(Wav.louder(wav)).pcm;
      final view = ByteData.sublistView(out);

      expect(view.getInt16(0, Endian.little), greaterThan(0));
      expect(view.getInt16(2, Endian.little), lessThan(0));
      expect(view.getInt16(4, Endian.little), greaterThan(0));
      expect(view.getInt16(6, Endian.little), lessThan(0));
    });

    test('should leave silence and non-WAV data as it is', () {
      final silence = _clip(0);
      expect(Wav.louder(silence), same(silence));
      final junk = [1, 2, 3];
      expect(Wav.louder(junk), same(junk));
    });
  });

  group('call clip keys', () {
    test('should run the words of a number on into each other', () {
      expect(callClipKeys(1001), ['t1', 'n1']);
      expect(callClipKeys(1250), ['t1', 'h2_c', 'n50']);
      expect(callClipKeys(2300), ['t2', 'h3']);
      expect(callClipKeys(9999), ['t9', 'h9_c', 'n99']);
      expect(callClipKeys(305), ['h3_c', 'n5']);
      expect(callClipKeys(7), ['n7']);
      expect(callClipKeys(100), ['h1']);
    });

    test('should end a round thousand with the plain words', () {
      expect(callClipKeys(5000), ['n5', 'thousand']);
    });

    test('should refuse a serial it has no words for', () {
      expect(() => callClipKeys(0), throwsRangeError);
      expect(() => callClipKeys(100001), throwsRangeError);
    });

    test('should close a regular call with the plain request', () {
      expect(callClosingKey('regular'), 'come');
      expect(callClosingKey('custom'), 'come');
    });

    test('should close report and dressing calls with their own phrase', () {
      expect(callClosingKey('report'), 'come_report');
      expect(callClosingKey('dressing'), 'come_dressing');
    });

    test('should close a recall with a reminder phrase', () {
      expect(callClosingKey('regular', recall: true), 'recall_come');
      expect(callClosingKey('report', recall: true), 'recall_report');
      expect(callClosingKey('dressing', recall: true), 'recall_dressing');
    });

    test('should name every clip a call can need once', () {
      expect(
        allCallClipKeys,
        containsAll([
          'n0',
          'n99',
          'h9',
          'h9_c',
          't9',
          't99',
          'thousand',
          'lakh1',
          'token_c',
          'come',
        ]),
      );
      expect(allCallClipKeys, contains('recall_dressing'));
      expect(allCallClipKeys.toSet().length, allCallClipKeys.length);
      // 100 numbers, 9 hundreds twice, 99 thousands, "thousand", one lakh,
      // the token phrase and the six closing phrases.
      expect(allCallClipKeys.length, 100 + 18 + 99 + 1 + 1 + 1 + 6);
    });
  });

  group('prerecorded call voice', () {
    late Map<String, List<int>> library;
    late List<String> seen;
    late PrerecordedCallVoice voice;

    PrerecordedCallVoice build({
      Duration gap = Duration.zero,
      Duration numberGap = Duration.zero,
    }) => PrerecordedCallVoice(
      load: (key) async {
        seen.add(key);
        return library[key];
      },
      gap: gap,
      numberGap: numberGap,
    );

    setUp(() {
      library = {for (final k in allCallClipKeys) k: _clip(1000)};
      seen = [];
      voice = build();
    });

    test('should join the clips of a call into one clip', () async {
      final clip = await voice.callClip(serial: 1001, queueTypeId: 'regular');

      final wav = Wav.parse(clip!);
      // token + "এক হাজার" + এক + closing = 4 clips of 100 samples.
      expect(wav.pcm.length, 4 * 100 * 2);
      expect(wav.sampleRate, 24000);
    });

    test('should not name the regular queue', () async {
      await voice.callClip(serial: 7, queueTypeId: 'regular');

      expect(seen, ['token_c', 'n7', 'come']);
    });

    test('should close a report call with the report phrase', () async {
      await voice.callClip(serial: 7, queueTypeId: 'report');

      expect(seen.last, 'come_report');
    });

    test('should use the reminder phrase on a recall', () async {
      await voice.callClip(serial: 7, queueTypeId: 'dressing', recall: true);

      expect(seen.last, 'recall_dressing');
    });

    test('should put a pause between the words', () async {
      voice = build(gap: const Duration(milliseconds: 100));

      final clip = await voice.callClip(serial: 7, queueTypeId: 'custom');

      // 3 clips and a 100 ms pause before the closing phrase, at 24 kHz.
      expect(Wav.parse(clip!).pcm.length, (3 * 100 + 2400) * 2);
    });

    test('should pause between the words of a number', () async {
      voice = build(numberGap: const Duration(milliseconds: 100));

      // 101 is "একশো" + "এক": token, hundreds, one, closing; one pause, 100 ms.
      final clip = await voice.callClip(serial: 101, queueTypeId: 'custom');

      expect(Wav.parse(clip!).pcm.length, (4 * 100 + 2400) * 2);
    });

    test('should not pause inside a one-word number', () async {
      voice = build(numberGap: const Duration(milliseconds: 100));

      final clip = await voice.callClip(serial: 7, queueTypeId: 'custom');

      expect(Wav.parse(clip!).pcm.length, 3 * 100 * 2);
    });

    test('should make no clip when a needed one is missing', () async {
      library.remove('t1');

      expect(
        await voice.callClip(serial: 1001, queueTypeId: 'regular'),
        isNull,
      );
    });

    test(
      'should make no clip when the clips are not all the same format',
      () async {
        library['n1'] = _clip(1000, rate: 16000);

        expect(
          await voice.callClip(serial: 1001, queueTypeId: 'regular'),
          isNull,
        );
      },
    );

    test('should make no clip when a clip is not a WAV file', () async {
      library['token_c'] = [1, 2, 3];

      expect(await voice.callClip(serial: 7, queueTypeId: 'regular'), isNull);
    });

    test('should make a test clip of a sample serial', () async {
      final clip = await voice.testClip();

      expect(clip, isNotNull);
    });
  });
}
