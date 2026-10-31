// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
/// Width breakpoints (dp).
abstract final class Breakpoints {
  /// Below this the layout is phone-sized.
  static const double compact = 600;

  /// From this width, landscape screens can lay forms out in two columns.
  static const double twoColumn = 720;

  /// From this width, the receptionist dashboard keeps the nav rail visible
  /// (matches the web dashboard at `lg`).
  static const double dashboardNav = 1024;
}
