// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:io';

import 'package:algoritiq_app/features/tv_live/application/call_clip_keys.dart';
import 'package:algoritiq_app/features/tv_live/domain/bengali_number_words.dart';
import 'package:flutter_test/flutter_test.dart';

/// A spoken serial is built from recorded clips and, without them, said by the
/// phone's own voice from words. Both must cover 1 .. 100000.
void main() {
  group('the number as Bengali words', () {
    const cases = {
      1: 'এক',
      6: 'ছয়',
      10: 'দশ',
      42: 'বিয়াল্লিশ',
      99: 'নিরানব্বই',
      100: 'একশো',
      106: 'একশো ছয়',
      110: 'একশো দশ',
      199: 'একশো নিরানব্বই',
      200: 'দুইশো',
      999: 'নয়শো নিরানব্বই',
      1000: 'এক হাজার',
      1001: 'এক হাজার এক',
      1100: 'এক হাজার একশো',
      9999: 'নয় হাজার নয়শো নিরানব্বই',
      10000: 'দশ হাজার',
      10001: 'দশ হাজার এক',
      25678: 'পঁচিশ হাজার ছয়শো আটাত্তর',
      99999: 'নিরানব্বই হাজার নয়শো নিরানব্বই',
      100000: 'এক লাখ',
    };

    for (final entry in cases.entries) {
      test('should say ${entry.key} as ${entry.value}', () {
        expect(bengaliNumberWords(entry.key), entry.value);
      });
    }

    test('should have a word for every number from 0 to 99', () {
      expect(bengaliNumberWordsTo99, hasLength(100));
      expect(bengaliNumberWordsTo99.toSet(), hasLength(100));
    });

    test('should refuse a number that cannot be spoken', () {
      expect(() => bengaliNumberWords(0), throwsRangeError);
      expect(() => bengaliNumberWords(100001), throwsRangeError);
    });
  });

  group('the recorded clips of a number', () {
    test('should say 106 as "একশো" then "ছয়"', () {
      expect(callClipKeys(106), ['h1_c', 'n6']);
    });

    test('should say a whole hundred with the clip that ends a number', () {
      expect(callClipKeys(300), ['h3']);
    });

    test('should say a whole thousand as the number then "হাজার"', () {
      expect(callClipKeys(1000), ['n1', 'thousand']);
      expect(callClipKeys(25000), ['n25', 'thousand']);
    });

    test('should say thousands with more after them as one phrase', () {
      expect(callClipKeys(1001), ['t1', 'n1']);
      expect(callClipKeys(25678), ['t25', 'h6_c', 'n78']);
      expect(callClipKeys(99999), ['t99', 'h9_c', 'n99']);
    });

    test('should say 100000 as one lakh', () {
      expect(callClipKeys(100000), ['lakh1']);
    });

    test('should refuse a serial that cannot be spoken', () {
      expect(() => callClipKeys(0), throwsRangeError);
      expect(() => callClipKeys(100001), throwsRangeError);
    });

    test('should only use clips that are listed', () {
      final listed = allCallClipKeys.toSet();
      for (var serial = 1; serial <= maxSpokenSerial; serial++) {
        for (final key in callClipKeys(serial)) {
          expect(listed.contains(key), isTrue, reason: '$serial uses $key');
        }
      }
    });

    test('should have a recorded file for every listed clip', () {
      final missing = [
        for (final key in allCallClipKeys)
          if (!File('assets/announcements/$key.wav').existsSync()) key,
      ];

      expect(missing, isEmpty);
    });
  });
}
