// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/token_slip.dart';
import 'escpos_raster.dart';
import 'token_slip_fonts.dart';

/// Draws a [TokenSlip] as a black-and-white picture, 384 dots wide, and turns
/// it into a print job. Bengali has to be drawn here: the printer has no
/// Bengali font of its own.
///
/// Layout, top to bottom: chamber, doctor, a rule, queue type pill then the
/// big token number (stacked), a rule, registration ID, date and time.
final class TokenSlipRenderer {
  const TokenSlipRenderer();

  static const _margin = 14.0;
  static const _ink = Color(0xFF000000);
  static const _paper = Color(0xFFFFFFFF);
  static const _idLabel = 'আইডি:';

  Future<Uint8List> render(TokenSlip slip) async {
    final image = await _renderToImage(slip);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final rgba = data!.buffer.asUint8List();
    final heightDots = image.height;
    image.dispose();
    return encodeRasterJob(
      rgba: rgba,
      width: printerDotsWide,
      height: heightDots,
      feedLines: tokenSlipFeedLines,
    );
  }

  Future<ui.Image> _renderToImage(TokenSlip slip) async {
    await ensureTokenSlipFontsLoaded();
    final width = printerDotsWide.toDouble();
    final inner = width - 2 * _margin;

    TextPainter paintText(
      String value,
      double size, {
      FontWeight weight = FontWeight.w500,
      Color color = _ink,
      TextAlign align = TextAlign.center,
      double? maxWidth,
      int maxLines = 2,
    }) {
      return TextPainter(
        text: TextSpan(
          text: value,
          style: TextStyle(
            fontFamily: brandFontFamily,
            fontFamilyFallback: const [bengaliFontFamily],
            fontSize: size,
            fontWeight: weight,
            color: color,
            height: 1.35,
          ),
        ),
        textAlign: align,
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
        ellipsis: '…',
      )..layout(minWidth: 0, maxWidth: maxWidth ?? inner);
    }

    TextPainter fitSerial(String value, double maxWidth) {
      var size = 104.0;
      while (size >= 52) {
        final tp = paintText(
          value,
          size,
          weight: FontWeight.w700,
          maxLines: 1,
          align: TextAlign.center,
          maxWidth: inner,
        );
        if (tp.width <= maxWidth) return tp;
        size -= 4;
      }
      return paintText(
        value,
        52,
        weight: FontWeight.w700,
        maxLines: 1,
        align: TextAlign.center,
        maxWidth: inner,
      );
    }

    final chamber = paintText(slip.chamberName, 26, weight: FontWeight.w700);
    final doctor = paintText(slip.doctorName, 24, maxLines: 1);
    const pillPadX = 18.0;
    const pillPadY = 8.0;
    const queueBlockGap = 6.0;
    final type = paintText(
      slip.queueText,
      28,
      weight: FontWeight.w700,
      color: _paper,
      maxLines: 1,
      maxWidth: inner - 2 * pillPadX,
    );
    final pillWidth = type.width + 2 * pillPadX;
    final number = fitSerial(slip.tokenText, inner);
    final id = paintText(
      '$_idLabel ${slip.idText}',
      26,
      weight: FontWeight.w700,
    );
    final when = paintText(
      slip.isReprint ? '${slip.issuedText} · REPRINT' : slip.issuedText,
      22,
      weight: FontWeight.w400,
    );

    const gap = 10.0;
    const rule = 2.0;
    final queueBlockHeight =
        type.height + 2 * pillPadY + queueBlockGap + number.height;
    final height =
        _margin +
        chamber.height +
        4 +
        doctor.height +
        gap +
        rule +
        gap +
        queueBlockHeight +
        gap +
        rule +
        gap +
        id.height +
        2 +
        when.height +
        _margin +
        tokenSlipBottomBlankDots;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = _paper,
    );

    var y = _margin;
    void centred(TextPainter tp) =>
        tp.paint(canvas, Offset(_margin + (inner - tp.width) / 2, y));

    centred(chamber);
    y += chamber.height + 4;
    centred(doctor);
    y += doctor.height + gap;
    _dashedRule(canvas, y, width);
    y += rule + gap;

    final pillLeft = _margin + (inner - pillWidth) / 2;
    final pill = Rect.fromLTWH(
      pillLeft,
      y,
      pillWidth,
      type.height + 2 * pillPadY,
    );
    canvas.drawRect(pill, Paint()..color = _ink);
    type.paint(canvas, Offset(pill.left + pillPadX, pill.top + pillPadY));
    y += type.height + 2 * pillPadY + queueBlockGap;
    number.paint(canvas, Offset(_margin + (inner - number.width) / 2, y));
    y += number.height + gap;

    _dashedRule(canvas, y, width);
    y += rule + gap;
    centred(id);
    y += id.height + 2;
    centred(when);

    final picture = recorder.endRecording();
    final heightDots = height.ceil();
    final image = await picture.toImage(printerDotsWide, heightDots);
    picture.dispose();
    return image;
  }

  void _dashedRule(Canvas canvas, double y, double width) {
    final paint = Paint()
      ..color = _ink
      ..strokeWidth = 2;
    for (var x = _margin; x < width - _margin; x += 14) {
      canvas.drawLine(Offset(x, y + 1), Offset(x + 8, y + 1), paint);
    }
  }
}
