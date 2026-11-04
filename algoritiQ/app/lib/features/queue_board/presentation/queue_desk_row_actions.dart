// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/widgets/brand_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/board_models.dart';

/// Width of the print icon and the more menu at the end of a table row.
const deskRowActionsWidth = 80.0;

/// What a row can do. [printerBusy] holds every print while one slip prints.
final class DeskRowActions {
  const DeskRowActions({
    required this.printerBusy,
    required this.onPrint,
    required this.onReprint,
    required this.onEditPatient,
    required this.onCancel,
  });

  final bool printerBusy;
  final void Function(BoardTokenView token) onPrint;
  final void Function(BoardTokenView token) onReprint;
  final void Function(BoardTokenView token) onEditPatient;
  final void Function(BoardTokenView token) onCancel;
}

/// The print icon (waiting/called only, while a slip is still needed) and the more menu.
class DeskRowActionsCell extends StatelessWidget {
  const DeskRowActionsCell({
    super.key,
    required this.token,
    required this.actions,
  });

  final BoardTokenView token;
  final DeskRowActions actions;

  bool get _active =>
      token.status == TokenStatus.waiting ||
      token.status == TokenStatus.called ||
      token.status == TokenStatus.skipped;

  /// Print and reprint apply only while the token is still in the live queue.
  bool get _inQueueForPrint =>
      token.status == TokenStatus.waiting || token.status == TokenStatus.called;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final printed = token.latestPrintStatus == 'SENT';
    return SizedBox(
      width: deskRowActionsWidth,
      child: Row(
        children: [
          SizedBox(
            width: deskRowActionsWidth / 2,
            child: Center(child: _printIcon(context, l10n, printed)),
          ),
          SizedBox(
            width: deskRowActionsWidth / 2,
            child: PopupMenuButton<VoidCallback>(
              tooltip: l10n.deskRowMore,
              icon: const Icon(Icons.more_horiz),
              onSelected: (action) => action(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: () => actions.onEditPatient(token),
                  child: Text(l10n.deskRowEditPatient),
                ),
                if (_inQueueForPrint)
                  PopupMenuItem(
                    value: () => actions.onReprint(token),
                    child: Text(l10n.deskRowReprint),
                  ),
                if (_active)
                  PopupMenuItem(
                    value: () => actions.onCancel(token),
                    child: Text(l10n.deskRowCancelToken),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _printIcon(BuildContext context, AppLocalizations l10n, bool printed) {
    if (!_inQueueForPrint || printed) return const SizedBox.shrink();
    if (token.latestPrintStatus == 'PENDING') {
      return BrandLoader(semanticLabel: l10n.deskPrintBusy);
    }
    return IconButton(
      tooltip: l10n.deskPrintNeeded,
      color: Theme.of(context).colorScheme.error,
      icon: const Icon(Icons.print_outlined),
      onPressed: actions.printerBusy ? null : () => actions.onPrint(token),
    );
  }
}
