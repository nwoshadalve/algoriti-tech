// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:io';

import 'package:algoritiq_app/features/connectivity/data/token_slip_preview_html.dart';
import 'package:algoritiq_app/features/connectivity/domain/token_slip.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regenerates `tool/token-slip-preview.html` (open in a browser — not PNG).
void main() {
  test('writes token slip preview html', () {
    const generator = TokenSlipPreviewHtml();
    final slip = TokenSlip(
      chamberName: 'আল-খিদমাহ্ মেডিকেল সার্ভিসেস, চাঁদপুর',
      doctorName: 'ডাঃ মোঃ রহিম উদ্দিন',
      queueType: QueueType.regular,
      tokenNumber: 1234,
      registrationId: 'PT-26-00421',
      issuedAt: DateTime(2026, 10, 30, 12, 14),
    );
    final html = generator.document(slip);
    expect(html, contains('আইডি:'));
    expect(html, contains('১২৩৪'));
    expect(html, contains('NotoSansBengali-Regular.ttf'));

    File(TokenSlipPreviewHtml.defaultPreviewPath).writeAsStringSync(html);
    expect(File(TokenSlipPreviewHtml.defaultPreviewPath).existsSync(), isTrue);
  });
}
