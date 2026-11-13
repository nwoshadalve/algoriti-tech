// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:io';

import 'package:algoritiq_app/features/tv_live/application/call_clip_keys.dart';
import 'package:algoritiq_app/features/tv_live/data/prerecorded_call_voice.dart';
import 'package:algoritiq_app/features/tv_live/data/wav.dart';
import 'package:algoritiq_app/features/tv_live/domain/bengali_number_words.dart';
import 'package:flutter_test/flutter_test.dart';

/// The real recorded clips in `assets/announcements/` must be one format and
/// must build every call. When they cannot, the app falls back to the phone's
/// own text-to-speech, which may speak in another language (Hindi).
void main() {
  Future<List<int>?> load(String key) async {
    final file = File('assets/announcements/$key.wav');
    return file.existsSync() ? file.readAsBytesSync() : null;
  }

  test('should have every clip in one format', () {
    final formats = <String>{};
    for (final key in allCallClipKeys) {
      final wav = Wav.parse(
        File('assets/announcements/$key.wav').readAsBytesSync(),
      );
      formats.add('${wav.sampleRate} Hz, ${wav.channels} channel(s)');
    }

    expect(formats, hasLength(1), reason: '$formats');
  });

  test('should build the recorded call for every kind of serial', () async {
    final voice = PrerecordedCallVoice(load: load);
    final serials = <int>{
      for (var s = 1; s <= 1200; s++) s,
      for (var s = 1000; s <= 100000; s += 997) s,
      for (var s = 2000; s <= 99000; s += 1000) s,
      1,
      6,
      9,
      99,
      100,
      106,
      199,
      999,
      1001,
      9999,
      10000,
      10001,
      25678,
      99999,
      100000,
    };
    final failed = <int>[];

    for (final serial in serials) {
      final clip = await voice.callClip(serial: serial, queueTypeId: 'regular');
      if (clip == null) failed.add(serial);
    }

    expect(failed, isEmpty, reason: 'no recorded call for $failed');
    expect(maxSpokenSerial, 100000);
  });

  test(
    'should build the recorded call for report and dressing and a recall',
    () async {
      final voice = PrerecordedCallVoice(load: load);

      for (final queue in ['regular', 'report', 'dressing']) {
        for (final recall in [false, true]) {
          final clip = await voice.callClip(
            serial: 106,
            queueTypeId: queue,
            recall: recall,
          );
          expect(clip, isNotNull, reason: '$queue recall=$recall');
        }
      }
    },
  );
}
