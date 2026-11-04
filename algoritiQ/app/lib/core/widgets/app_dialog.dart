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

  static Size maxFor(Size screen, {double keyboard = 0}) {
    final landscape = screen.width > screen.height;
    final width = (screen.width * (landscape ? landscapeWidth : portraitWidth))
        .clamp(minWidth, maxWidth);
    final height =
        (screen.height - keyboard) *
        (landscape ? landscapeHeight : portraitHeight);
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
  });

  final String title;
  final Widget body;

  /// Footer buttons, in order; the primary one last. Empty hides the footer.
  final List<Widget> actions;

  /// Wider than [DialogSize.maxWidth] when set (e.g. multi-column desk forms).
  final double? maxWidth;

  /// Smaller title and body padding, for dense tablet forms.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final baseMax = DialogSize.maxFor(
      media.size,
      keyboard: media.viewInsets.bottom,
    );
    final widthCap = maxWidth ?? DialogSize.maxWidth;
    final max = Size(
      baseMax.width.clamp(DialogSize.minWidth, widthCap),
      baseMax.height,
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final titleStyle = compact
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);
    final bodyPadding = compact ? Spacing.md : Spacing.lg;
    final headerPadding = compact
        ? const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.xs, Spacing.sm)
        : const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.sm,
            Spacing.sm,
            Spacing.sm,
          );
    final footerPadding = compact ? Spacing.sm : Spacing.md;

    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(Spacing.md),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    visualDensity: compact
                        ? VisualDensity.compact
                        : VisualDensity.standard,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            Flexible(
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(bodyPadding),
                  child: body,
                ),
              ),
            ),
            if (actions.isNotEmpty) ...[
              Divider(height: 1, color: scheme.outlineVariant),
              Padding(
                padding: EdgeInsets.all(footerPadding),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: Spacing.sm + Spacing.xs,
                  runSpacing: Spacing.sm,
                  children: actions,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
