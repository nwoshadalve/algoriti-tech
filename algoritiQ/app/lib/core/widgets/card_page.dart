// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/breakpoints.dart';
import 'brand_logo.dart';
import 'language_switcher.dart';

/// Full-screen page with a fixed top bar (logo and language toggle) and one
/// centred card below it. Same look in portrait and landscape, light and dark.
/// Only the card area scrolls, when the keyboard or a large text size leaves
/// too little room.
///
/// The card gets 440 dp, or 880 dp on wide landscape screens
/// ([isTwoColumn]); cards read their own width to pick a layout.
class CardPage extends StatelessWidget {
  const CardPage({
    super.key,
    required this.child,
    this.footer,
    this.wide = false,
  });

  final Widget child;

  /// Small note under the card (e.g. a privacy line).
  final Widget? footer;

  /// Long forms: on wide landscape screens the card grows to 1080 dp so the
  /// fields sit in columns instead of one long scrolling list.
  final bool wide;

  static const _cardMaxWidth = 440.0;
  static const _twoColumnMaxWidth = 880.0;
  static const _wideMaxWidth = 1080.0;

  /// Wide landscape screens lay forms out in two columns.
  static bool isTwoColumn(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width >= Breakpoints.twoColumn && size.width > size.height;
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.compact;
    final gutter = compact ? Spacing.md : Spacing.lg;
    final footer = this.footer;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(gutter, Spacing.xs, gutter, 0),
              child: const _TopBar(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(gutter, 0, gutter, Spacing.sm),
                  child: ConstrainedBox(
                    // Fill the area so the card sits centred; scroll when
                    // it can't.
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - Spacing.sm,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox.shrink(),
                        Padding(
                          // Tighter on wide landscape, where height is scarce.
                          padding: EdgeInsets.symmetric(
                            vertical: isTwoColumn(context)
                                ? Spacing.xs
                                : Spacing.sm,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: !isTwoColumn(context)
                                  ? _cardMaxWidth
                                  : wide
                                  ? _wideMaxWidth
                                  : _twoColumnMaxWidth,
                            ),
                            child: child,
                          ),
                        ),
                        footer ?? const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Logo left, language toggle right. Stays put while the card scrolls.
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: BrandLogo.wordmark(height: 28)),
        LanguageSwitcher(),
      ],
    );
  }
}
