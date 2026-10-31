// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import 'app_radii.dart';
import 'app_spacing.dart';
import 'brand_colors.dart';

/// Brand font bundled in `assets/fonts` (SIL OFL). Works offline.
const brandFontFamily = 'PlusJakartaSans';

/// Minimum touch target height for primary actions (dp).
const _buttonHeight = 52.0;

abstract final class AppTheme {
  static final light = _build(
    ColorScheme.fromSeed(
      seedColor: BrandColors.navy,
      brightness: Brightness.light,
    ).copyWith(
      primary: BrandColors.navy,
      onPrimary: BrandColors.white,
      tertiary: BrandColors.coral,
      onTertiary: BrandColors.navy,
      surface: BrandColors.white,
    ),
    page: BrandColors.mist,
  );

  static final dark = _build(
    ColorScheme.fromSeed(
      seedColor: BrandColors.navy,
      brightness: Brightness.dark,
    ).copyWith(
      primary: BrandColors.white,
      onPrimary: BrandColors.navy,
      tertiary: BrandColors.coral,
      onTertiary: BrandColors.navy,
      surface: BrandColors.navyRaised,
      surfaceContainerHighest: BrandColors.navyTint,
      outlineVariant: BrandColors.navyLine,
    ),
    page: BrandColors.navy,
  );

  static ThemeData _build(ColorScheme scheme, {required Color page}) {
    final fieldShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.field),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: page,
      fontFamily: brandFontFamily,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        // 48 dp tall fields: compact enough for a 533 dp-tall landscape screen.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm + Spacing.xs,
        ),
        border: _outline(scheme.outline),
        enabledBorder: _outline(scheme.outline),
        focusedBorder: _outline(scheme.primary, width: 2),
        errorBorder: _outline(scheme.error),
        focusedErrorBorder: _outline(scheme.error, width: 2),
      ),
      // Coral is the call-to-action colour (brand guide). Same button in both
      // themes: white label on the deeper action coral (AA contrast).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BrandColors.coralAction,
          foregroundColor: BrandColors.white,
          minimumSize: const Size(64, _buttonHeight),
          shape: fieldShape,
          textStyle: const TextStyle(
            fontFamily: brandFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      // Secondary actions (Back, Add, Change photo): same size and shape as
      // the filled button, ink-coloured outline, in light and dark.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(64, _buttonHeight),
          shape: fieldShape,
          side: BorderSide(color: scheme.outline),
          textStyle: const TextStyle(
            fontFamily: brandFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(48),
          shape: fieldShape,
        ),
      ),
    );
  }

  static OutlineInputBorder _outline(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.field),
        borderSide: BorderSide(color: color, width: width),
      );
}
