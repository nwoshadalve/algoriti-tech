// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

bool _slipFontsLoaded = false;

/// Loads slip fonts in tests (and any headless render) so Bengali glyphs paint.
Future<void> ensureTokenSlipFontsLoaded() async {
  if (_slipFontsLoaded) return;
  final jakarta = FontLoader(brandFontFamily)
    ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans.ttf'));
  await jakarta.load();

  final bengali = FontLoader(bengaliFontFamily)
    ..addFont(rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/NotoSansBengali-Bold.ttf'));
  await bengali.load();
  _slipFontsLoaded = true;
}
