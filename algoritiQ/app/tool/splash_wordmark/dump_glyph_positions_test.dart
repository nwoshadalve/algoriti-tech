// Step 1 of 2 for the native splash wordmark (see build_vector.py).
//
// Lays out "AlgoritiQ" exactly like `BrandLogo` (same font, size, tracking and
// kerning) and writes each glyph's x position to `glyph_positions.json`, so
// the vector drawable's outlined text matches the in-app wordmark.
//
// Run from `algoritiQ/app`:
//   flutter test tool/splash_wordmark/dump_glyph_positions_test.dart
//   python tool/splash_wordmark/build_vector.py
import 'dart:convert';
import 'dart:io';

import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _text = 'AlgoritiQ';
const _output = 'tool/splash_wordmark/glyph_positions.json';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dumps glyph x positions for the wordmark', () async {
    final bytes = await File('assets/fonts/PlusJakartaSans.ttf').readAsBytes();
    final loader = FontLoader(brandFontFamily)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();

    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: _text,
        style: TextStyle(
          fontFamily: brandFontFamily,
          fontSize: 46,
          fontWeight: FontWeight.w700,
          fontVariations: [FontVariation('wght', 700)],
          letterSpacing: -1.5,
        ),
      ),
    )..layout();

    final glyphs = [
      for (var i = 0; i < _text.length; i++)
        {
          'char': _text[i],
          'x': painter
              .getBoxesForSelection(
                TextSelection(baseOffset: i, extentOffset: i + 1),
              )
              .first
              .left,
        },
    ];

    File(_output).writeAsStringSync(
      const JsonEncoder.withIndent('  ')
          .convert({'fontSize': 46, 'width': painter.width, 'glyphs': glyphs}),
    );
  });
}
