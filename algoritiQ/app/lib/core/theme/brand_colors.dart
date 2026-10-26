import 'package:flutter/material.dart';

/// AlgoritiQ brand palette. Source: `branding/README.md`.
abstract final class BrandColors {
  static const navy = Color(0xFF0B1F3A);
  static const coral = Color(0xFFFF5C39);
  static const white = Color(0xFFFFFFFF);

  /// Light page background, one step off white so cards lift.
  static const mist = Color(0xFFF4F6FA);

  /// Dark card surface, one step lighter than [navy].
  static const navyRaised = Color(0xFF12294A);

  /// Dark tinted fill (code rows, chips) on top of [navyRaised].
  static const navyTint = Color(0xFF1E3A66);
}
