// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

import 'package:algoritiq_app/features/connectivity/data/escpos_raster.dart';
import 'package:algoritiq_app/features/connectivity/data/token_slip_renderer.dart';
import 'package:algoritiq_app/features/connectivity/domain/token_slip.dart';
import 'package:flutter_test/flutter_test.dart';

TokenSlip slip({
  int number = 12,
  QueueType type = QueueType.regular,
  DateTime? at,
}) => TokenSlip(
  chamberName: 'আল-খিদমাহ্ মেডিকেল সার্ভিসেস, চাঁদপুর',
  doctorName: 'ডাঃ মোঃ রহিম উদ্দিন',
  queueType: type,
  tokenNumber: number,
  registrationId: 'PT-26-00421',
  issuedAt: at ?? DateTime(2026, 10, 30, 12, 14),
);

void main() {
  group('slip text', () {
    test('should write digits in Bengali and keep letters', () {
      expect(bengaliDigits('PT-26-00421'), 'PT-২৬-০০৪২১');
      expect(bengaliDigits('abc'), 'abc');
    });

    test('should show the token with at least two Bengali digits', () {
      expect(slip(number: 1).tokenText, '০১');
      expect(slip(number: 12).tokenText, '১২');
      expect(slip(number: 105).tokenText, '১০৫');
    });

    test('should name the three queues in Bengali', () {
      expect(QueueType.regular.bengaliLabel, 'নিয়মিত');
      expect(QueueType.report.bengaliLabel, 'রিপোর্ট');
      expect(QueueType.dressing.bengaliLabel, 'ড্রেসিং');
    });

    test('should write date and a 12-hour time', () {
      expect(slip().issuedText, '৩০/১০/২৬ · ১২:১৪ PM');
      expect(
        slip(at: DateTime(2026, 1, 5, 0, 5)).issuedText,
        '০৫/০১/২৬ · ১২:০৫ AM',
      );
      expect(
        slip(at: DateTime(2026, 1, 5, 13, 40)).issuedText,
        '০৫/০১/২৬ · ০১:৪০ PM',
      );
    });
  });

  group('print job', () {
    Uint8List pixels(int width, int height, int Function(int x, int y) gray) {
      final out = Uint8List(width * height * 4);
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          final g = gray(x, y);
          final p = (y * width + x) * 4;
          out[p] = out[p + 1] = out[p + 2] = g;
          out[p + 3] = 255;
        }
      }
      return out;
    }

    test('should start with init and a raster header, end with a feed', () {
      final job = encodeRasterJob(
        rgba: pixels(16, 3, (x, y) => 255),
        width: 16,
        height: 3,
      );

      expect(job.sublist(0, 2), [0x1B, 0x40]);
      expect(job.sublist(2, 10), [0x1D, 0x76, 0x30, 0x00, 2, 0, 3, 0]);
      expect(job.sublist(job.length - 3), [0x1B, 0x64, 3]);
      expect(job.length, 2 + 8 + 2 * 3 + 3);
    });

    test('should print dark pixels as set bits, left pixel first', () {
      final job = encodeRasterJob(
        rgba: pixels(16, 1, (x, y) => x == 0 || x == 9 ? 0 : 255),
        width: 16,
        height: 1,
      );

      expect(job.sublist(10, 12), [0x80, 0x40]);
    });

    test('should leave light grey and transparent pixels white', () {
      final rgba = pixels(8, 1, (x, y) => x < 4 ? 200 : 0);
      for (var x = 4; x < 8; x++) {
        rgba[x * 4 + 3] = 0;
      }

      final job = encodeRasterJob(rgba: rgba, width: 8, height: 1);

      expect(job[10], 0);
    });

    test('should fit 58 mm paper: 384 dots, 48 bytes a row', () {
      expect(printerDotsWide, 384);
      final job = encodeRasterJob(
        rgba: pixels(printerDotsWide, 2, (x, y) => 0),
        width: printerDotsWide,
        height: 2,
      );
      expect(job.sublist(6, 8), [48, 0]);
    });

    testWidgets('should draw the slip as a 384-dot raster job', (tester) async {
      final job = await tester.runAsync(
        () => const TokenSlipRenderer().render(slip()),
      );

      expect(job!.sublist(0, 2), [0x1B, 0x40]);
      expect(job.sublist(2, 8), [0x1D, 0x76, 0x30, 0x00, 48, 0]);
      final height = job[8] + job[9] * 256;
      expect(job.length, 2 + 8 + 48 * height + 3);
      expect(height, inInclusiveRange(150, 480));
      final ink = job
          .sublist(10, 10 + 48 * height)
          .where((byte) => byte != 0)
          .length;
      expect(ink, greaterThan(200), reason: 'something was drawn');
    });
  });
}
