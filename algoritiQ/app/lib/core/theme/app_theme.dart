import 'package:flutter/material.dart';

import 'brand_colors.dart';

/// Brand font bundled in `assets/fonts` (SIL OFL). Works offline.
const brandFontFamily = 'PlusJakartaSans';

abstract final class AppTheme {
  static final light = _build(
    ColorScheme.fromSeed(
      seedColor: BrandColors.navy,
      brightness: Brightness.light,
    ).copyWith(
      primary: BrandColors.navy,
      onPrimary: BrandColors.white,
      tertiary: BrandColors.coral,
      surface: BrandColors.white,
    ),
  );

  static final dark = _build(
    ColorScheme.fromSeed(
      seedColor: BrandColors.navy,
      brightness: Brightness.dark,
    ).copyWith(
      primary: BrandColors.white,
      onPrimary: BrandColors.navy,
      tertiary: BrandColors.coral,
      surface: BrandColors.navy,
    ),
  );

  static ThemeData _build(ColorScheme scheme) => ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    fontFamily: brandFontFamily,
  );
}
