// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../domain/token_slip.dart';

/// Static slip mock-up for design review in a browser — not sent to the printer.
///
/// Open [defaultPreviewPath] from the repo (fonts load via relative `@font-face`).
/// Do not export PNG from Flutter tests; headless text raster often misleads.
final class TokenSlipPreviewHtml {
  const TokenSlipPreviewHtml();

  static const defaultPreviewPath = 'tool/token-slip-preview.html';

  /// Relative to `app/` when the HTML file lives under `tool/`.
  static const fontsBase = '../assets/fonts';

  String document(TokenSlip slip) {
    final reprint = slip.isReprint ? ' · REPRINT' : '';
    final when = slip.isReprint
        ? '${slip.issuedText}$reprint'
        : slip.issuedText;
    return '''
<!DOCTYPE html>
<html lang="bn">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Token slip preview</title>
  <style>
    @font-face {
      font-family: 'Plus Jakarta Sans';
      src: url('$fontsBase/PlusJakartaSans.ttf') format('truetype');
      font-weight: 100 800;
      font-style: normal;
    }
    @font-face {
      font-family: 'Noto Sans Bengali';
      src: url('$fontsBase/NotoSansBengali-Regular.ttf') format('truetype');
      font-weight: 400;
      font-style: normal;
    }
    @font-face {
      font-family: 'Noto Sans Bengali';
      src: url('$fontsBase/NotoSansBengali-Bold.ttf') format('truetype');
      font-weight: 700;
      font-style: normal;
    }
    * { box-sizing: border-box; }
    body {
      margin: 1rem;
      background: #e8e8e8;
      font-family: system-ui, sans-serif;
    }
    .note {
      max-width: 28rem;
      margin-bottom: 1rem;
      font-size: 0.875rem;
      line-height: 1.5;
    }
    .slip {
      width: 384px;
      padding: 14px 14px 46px;
      background: #fff;
      color: #000;
      font-family: 'Plus Jakarta Sans', 'Noto Sans Bengali', sans-serif;
      line-height: 1.35;
    }
    .chamber {
      font-size: 26px;
      font-weight: 700;
      text-align: center;
    }
    .doctor {
      margin-top: 4px;
      font-size: 24px;
      text-align: center;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .rule {
      margin: 10px 0;
      border: none;
      border-top: 2px dashed #000;
      height: 0;
    }
    .queue-block {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 6px;
    }
    .pill {
      padding: 8px 18px;
      background: #000;
      color: #fff;
      font-size: 28px;
      font-weight: 700;
      white-space: nowrap;
      max-width: 100%;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .serial {
      font-size: 104px;
      font-weight: 700;
      line-height: 1;
      text-align: center;
      width: 100%;
    }
    .id {
      font-size: 26px;
      font-weight: 700;
      text-align: center;
    }
    .when {
      margin-top: 2px;
      font-size: 22px;
      text-align: center;
    }
  </style>
</head>
<body>
  <p class="note">Design mock-up only (58&nbsp;mm / 384&nbsp;dot width). Real slips are rasterized by <code>TokenSlipRenderer</code> with the same bundled fonts. Open this file from the repo so fonts resolve.</p>
  <article class="slip" aria-label="Token slip">
    <div class="chamber">${_escape(slip.chamberName)}</div>
    <div class="doctor">${_escape(slip.doctorName)}</div>
    <hr class="rule"/>
    <div class="queue-block">
      <span class="pill">${_escape(slip.queueText)}</span>
      <span class="serial">${_escape(slip.tokenText)}</span>
    </div>
    <hr class="rule"/>
    <div class="id">আইডি: ${_escape(slip.idText)}</div>
    <div class="when">${_escape(when)}</div>
  </article>
</body>
</html>
''';
  }

  String _escape(String raw) {
    const map = {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;'};
    final out = StringBuffer();
    for (final unit in raw.runes) {
      final ch = String.fromCharCode(unit);
      out.write(map[ch] ?? ch);
    }
    return out.toString();
  }
}
