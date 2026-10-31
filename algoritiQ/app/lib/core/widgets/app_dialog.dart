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
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    builder: (context) => AppDialog(title: title, body: body, actions: actions),
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
  });

  final String title;
  final Widget body;

  /// Footer buttons, in order; the primary one last. Empty hides the footer.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final max = DialogSize.maxFor(
      media.size,
      keyboard: media.viewInsets.bottom,
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

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
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.sm,
                Spacing.sm,
                Spacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: l10n.dialogClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            Flexible(
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: body,
                ),
              ),
            ),
            if (actions.isNotEmpty) ...[
              Divider(height: 1, color: scheme.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(Spacing.md),
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
