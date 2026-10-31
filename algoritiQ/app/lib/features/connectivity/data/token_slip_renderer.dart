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

/// Draws a [TokenSlip] as a black-and-white picture, 384 dots wide, and turns
/// it into a print job. Bengali has to be drawn here: the printer has no
/// Bengali font of its own.
///
/// Layout, top to bottom: chamber, doctor, a rule, the queue type beside the
/// big token number, a rule, registration ID, date and time.
final class TokenSlipRenderer {
  const TokenSlipRenderer();

  static const _margin = 14.0;
  static const _ink = Color(0xFF000000);
  static const _paper = Color(0xFFFFFFFF);

  Future<Uint8List> render(TokenSlip slip) async {
    final width = printerDotsWide.toDouble();
    final inner = width - 2 * _margin;

    TextPainter text(
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
            fontSize: size,
            fontWeight: weight,
            color: color,
            height: 1.3,
          ),
        ),
        textAlign: align,
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
        ellipsis: '…',
      )..layout(minWidth: 0, maxWidth: maxWidth ?? inner);
    }

    final chamber = text(slip.chamberName, 26, weight: FontWeight.w700);
    final doctor = text(slip.doctorName, 24, maxLines: 1);
    final type = text(
      slip.queueType.bengaliLabel,
      28,
      weight: FontWeight.w700,
      color: _paper,
      maxLines: 1,
      maxWidth: inner * 0.5,
    );
    final number = text(
      slip.tokenText,
      104,
      weight: FontWeight.w700,
      maxLines: 1,
      maxWidth: inner * 0.62,
      align: TextAlign.right,
    );
    final id = text('ID: ${slip.idText}', 26, weight: FontWeight.w700);
    final when = text(slip.issuedText, 22, weight: FontWeight.w400);

    const gap = 10.0;
    const rule = 2.0;
    const pillPadX = 18.0;
    const pillPadY = 8.0;
    final rowHeight = number.height > type.height + 2 * pillPadY
        ? number.height
        : type.height + 2 * pillPadY;
    final height =
        _margin +
        chamber.height +
        4 +
        doctor.height +
        gap +
        rule +
        gap +
        rowHeight +
        gap +
        rule +
        gap +
        id.height +
        2 +
        when.height +
        _margin;

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

    final pill = Rect.fromLTWH(
      _margin,
      y + (rowHeight - (type.height + 2 * pillPadY)) / 2,
      type.width + 2 * pillPadX,
      type.height + 2 * pillPadY,
    );
    canvas.drawRect(pill, Paint()..color = _ink);
    type.paint(canvas, Offset(pill.left + pillPadX, pill.top + pillPadY));
    number.paint(
      canvas,
      Offset(
        width - _margin - number.width,
        y + (rowHeight - number.height) / 2,
      ),
    );
    y += rowHeight + gap;

    _dashedRule(canvas, y, width);
    y += rule + gap;
    centred(id);
    y += id.height + 2;
    centred(when);

    final picture = recorder.endRecording();
    final image = await picture.toImage(printerDotsWide, height.ceil());
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final rgba = data!.buffer.asUint8List();
    final heightDots = image.height;
    image.dispose();
    picture.dispose();
    return encodeRasterJob(
      rgba: rgba,
      width: printerDotsWide,
      height: heightDots,
    );
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
