// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// Share of the screen a dialog may take, by orientation. A dialog is sized
/// from the screen it is on, never in fixed pixels.
abstract final class DialogSize {
  static const portraitWidth = 0.90;
  static const portraitHeight = 0.70;
  static const landscapeWidth = 0.55;
  static const landscapeHeight = 0.85;

  /// Never narrower or wider than this (dp), whatever the screen.
  static const minWidth = 280.0;
  static const maxWidth = 640.0;

  static Size maxFor(
    Size screen, {
    double keyboard = 0,
    bool ignoreKeyboardInset = false,
  }) {
    final landscape = screen.width > screen.height;
    final width = (screen.width * (landscape ? landscapeWidth : portraitWidth))
        .clamp(minWidth, maxWidth);
    final heightBase = ignoreKeyboardInset
        ? screen.height
        : (screen.height - keyboard);
    final height = heightBase * (landscape ? landscapeHeight : portraitHeight);
    return Size(width, height);
  }
}

/// Opens an [AppDialog]. The one popup for confirmations and short forms.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  required Widget body,
  List<Widget> actions = const [],
  bool dismissible = true,
  double? maxWidth,
  bool compact = false,
  bool fixedSizeWithKeyboard = false,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    builder: (context) => AppDialog(
      title: title,
      body: body,
      actions: actions,
      maxWidth: maxWidth,
      compact: compact,
      fixedSizeWithKeyboard: fixedSizeWithKeyboard,
    ),
  );
}

/// The shared popup: a **fixed header** (title and close), a **fixed footer**
/// (actions) and a **body between them that scrolls** when it does not fit.
///
/// It is as small as its content, up to a share of the screen set by
/// [DialogSize] (more width in portrait, more height in landscape), so it
/// fits phones and tablets, both orientations and both themes, and stays
/// clear of the keyboard. All colours come from the theme.
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.maxWidth,
    this.compact = false,
    this.fixedSizeWithKeyboard = false,
  });

  final String title;
  final Widget body;

  /// Footer buttons, in order; the primary one last. Empty hides the footer.
  final List<Widget> actions;

  /// Wider than [DialogSize.maxWidth] when set (e.g. multi-column desk forms).
  final double? maxWidth;

  /// Smaller title and body padding, for dense tablet forms.
  final bool compact;

  /// Keep the dialog's max height when the keyboard opens; body scrolls inside
  /// and the dialog shifts up above the keyboard.
  final bool fixedSizeWithKeyboard;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final baseMax = DialogSize.maxFor(
      media.size,
      keyboard: media.viewInsets.bottom,
      ignoreKeyboardInset: fixedSizeWithKeyboard,
    );
    final widthCap = maxWidth ?? DialogSize.maxWidth;
    var maxHeight = baseMax.height;
    if (fixedSizeWithKeyboard) {
      final inset = media.viewInsets;
      final margin = Spacing.md * 2;
      final availableHeight =
          media.size.height - inset.top - inset.bottom - margin;
      if (availableHeight > 0) {
        maxHeight = maxHeight.clamp(0, availableHeight);
      }
    }
    final max = Size(
      baseMax.width.clamp(DialogSize.minWidth, widthCap),
      maxHeight,
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final titleStyle = compact
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);
    // Everything shrinks while the keyboard is up: a landscape tablet leaves
    // ~200 dp for the whole dialog, and the fields need that room.
    final keyboardOpen = fixedSizeWithKeyboard && media.viewInsets.bottom > 0;
    final bodyPadding = keyboardOpen
        ? Spacing.sm
        : (compact ? Spacing.md : Spacing.lg);
    final headerPadding = keyboardOpen
        ? const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.xs, 0)
        : compact
        ? const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.sm,
            Spacing.xs,
            Spacing.sm,
          )
        : const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.sm,
            Spacing.sm,
            Spacing.sm,
          );
    final footerPadding = compact ? Spacing.sm : Spacing.md;
    // A fixed footer would take the room the fields need, so with the keyboard
    // up the buttons move into the scrolling body.
    final footer = Wrap(
      alignment: WrapAlignment.end,
      spacing: Spacing.sm + Spacing.xs,
      runSpacing: Spacing.sm,
      children: actions,
    );

    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: keyboardOpen
          ? const EdgeInsets.all(Spacing.xs)
          : const EdgeInsets.all(Spacing.md),
      alignment: fixedSizeWithKeyboard ? Alignment.topCenter : Alignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: max.width,
          maxWidth: max.width,
          maxHeight: max.height,
        ),
        child: SizedBox(
          width: max.width,
          height: fixedSizeWithKeyboard ? max.height : null,
          child: Column(
            mainAxisSize: fixedSizeWithKeyboard
                ? MainAxisSize.max
                : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: headerPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(title, style: titleStyle),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: l10n.dialogClose,
                      iconSize: compact ? 20 : 24,
                      visualDensity: compact || keyboardOpen
                          ? VisualDensity.compact
                          : VisualDensity.standard,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: scheme.outlineVariant),
              if (fixedSizeWithKeyboard)
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.manual,
                      padding: EdgeInsets.all(bodyPadding),
                      // Always a Column so [body] keeps its place in the tree
                      // when the keyboard opens; a different parent would
                      // rebuild the fields, drop focus and close the keyboard.
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          body,
                          if (keyboardOpen && actions.isNotEmpty) ...[
                            const SizedBox(height: Spacing.md),
                            footer,
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(bodyPadding),
                      child: body,
                    ),
                  ),
                ),
              if (actions.isNotEmpty && !keyboardOpen) ...[
                Divider(height: 1, color: scheme.outlineVariant),
                Padding(padding: EdgeInsets.all(footerPadding), child: footer),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
