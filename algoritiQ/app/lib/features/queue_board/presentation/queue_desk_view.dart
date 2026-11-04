// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../application/queue_desk_table_controller.dart';
import '../domain/board_models.dart';
import '../domain/token_query.dart';
import 'queue_desk_format.dart';
import 'queue_desk_now_calling.dart';
import 'queue_desk_queue_controls.dart';
import 'queue_desk_session_table.dart';
import 'queue_desk_table_toolbar.dart';

/// From this width, and only when wider than tall, the desk is a strip beside
/// the table (landscape); otherwise Now calling, the queues and the table are
/// stacked (portrait).
const _sideBySideMinWidth = 720.0;

/// In the stacked layout, the top part (Now calling and the queues) may take
/// this share of the height; beyond it, it scrolls inside itself so the table
/// keeps its room.
const _topShareOfHeight = 0.42;

/// A stacked desk shorter than this (a phone) cannot show everything at once,
/// so it scrolls as a page, with the table at a fixed height.
const _stackedScrollBelowHeight = 640.0;

/// A side-by-side desk needs this much height (the Honor Pad leaves 381);
/// shorter (a phone on its side), it scrolls as a page too.
const _sideBySideMinHeight = 340.0;
const _stackedTableHeight = 480.0;

/// The least height the table gets while the keyboard is open.
const _typingMinHeight = 140.0;

/// Width of the strip with Now calling and the queues in landscape.
const _stripWidth = 320.0;

/// Everything the desk can ask for. The panel answers each one; the view only
/// arranges the screen.
final class QueueDeskCallbacks {
  const QueueDeskCallbacks({
    required this.onCall,
    required this.onRecall,
    required this.onEntered,
    required this.onMissed,
    required this.onCancelCalled,
    required this.onAdd,
    required this.onAddExisting,
    required this.onSearch,
    required this.onStatus,
    required this.onQueue,
    required this.onToggleNotPrinted,
    required this.onClearFilters,
    required this.onSort,
    required this.onLoadMore,
    required this.onRetry,
    required this.onPrint,
    required this.onReprint,
    required this.onEditPatient,
    required this.onCancel,
    required this.onEndSession,
  });

  final ValueChanged<String> onCall;
  final ValueChanged<String> onRecall;
  final VoidCallback onEntered;
  final VoidCallback onMissed;
  final VoidCallback onCancelCalled;
  final VoidCallback onAdd;
  final VoidCallback onAddExisting;
  final ValueChanged<String> onSearch;
  final ValueChanged<TokenStatus?> onStatus;
  final ValueChanged<String?> onQueue;
  final VoidCallback onToggleNotPrinted;
  final VoidCallback onClearFilters;
  final ValueChanged<TokenSort> onSort;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final void Function(BoardTokenView token) onPrint;
  final void Function(BoardTokenView token) onReprint;
  final void Function(BoardTokenView token) onEditPatient;
  final void Function(BoardTokenView token) onCancel;
  final VoidCallback onEndSession;
}

/// The open-session desk on one screen: Now calling, the queues and the
/// patient table. Landscape puts a strip beside the table; portrait stacks
/// them. Only the table's rows scroll.
///
/// While the receptionist types in the search box with the keyboard open, the
/// desk shows only the patient table in the room above the keyboard, so what
/// is typed and what it finds stay in view.
class QueueDeskView extends StatefulWidget {
  const QueueDeskView({
    super.key,
    required this.snapshot,
    required this.table,
    required this.callbacks,
    this.busyQueueId,
  });

  final BoardSnapshot snapshot;
  final DeskTableState table;
  final QueueDeskCallbacks callbacks;
  final String? busyQueueId;

  @override
  State<QueueDeskView> createState() => _QueueDeskViewState();
}

class _QueueDeskViewState extends State<QueueDeskView> {
  /// Keeps the table, and so the search box and its focus, alive while the
  /// desk switches between its full and its typing arrangement.
  final _patientsKey = GlobalKey();
  bool _searchFocused = false;

  BoardSnapshot get snapshot => widget.snapshot;
  DeskTableState get table => widget.table;
  QueueDeskCallbacks get callbacks => widget.callbacks;

  void _onSearchFocus(bool focused) {
    if (focused == _searchFocused) return;
    setState(() => _searchFocused = focused);
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final typing = _searchFocused && keyboard > 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide =
            constraints.maxWidth >= _sideBySideMinWidth &&
            constraints.maxWidth > constraints.maxHeight &&
            constraints.maxHeight >= _sideBySideMinHeight;
        final nowCalling = DeskNowCalling(
          called: snapshot.calledToken,
          onRecall: () {
            final called = snapshot.calledToken;
            if (called != null) callbacks.onRecall(called.queueTypeId);
          },
          onEntered: callbacks.onEntered,
          onMissed: callbacks.onMissed,
          onCancel: callbacks.onCancelCalled,
        );
        final queues = _QueuesCard(
          controls: snapshot.queueControls,
          horizontalTiles: !sideBySide,
          busyQueueId: widget.busyQueueId,
          onCall: callbacks.onCall,
          onRecall: callbacks.onRecall,
          onEndSession: callbacks.onEndSession,
        );
        final patients = _PatientsCard(
          key: _patientsKey,
          snapshot: snapshot,
          table: table,
          callbacks: callbacks,
          compact: typing,
          onSearchFocus: _onSearchFocus,
        );
        if (typing) {
          // The desk's own top edge on screen decides how much is left.
          final box = context.findRenderObject();
          final top = box is RenderBox ? box.localToGlobal(Offset.zero).dy : 0;
          final room = MediaQuery.sizeOf(context).height - keyboard - top;
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: room.clamp(_typingMinHeight, constraints.maxHeight),
              child: patients,
            ),
          );
        }
        if (sideBySide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _stripWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    nowCalling,
                    const SizedBox(height: Spacing.sm),
                    Flexible(child: queues),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(child: patients),
            ],
          );
        }
        final top = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            nowCalling,
            const SizedBox(height: Spacing.sm),
            queues,
          ],
        );
        if (constraints.maxHeight < _stackedScrollBelowHeight) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                top,
                const SizedBox(height: Spacing.sm),
                SizedBox(height: _stackedTableHeight, child: patients),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * _topShareOfHeight,
              ),
              child: SingleChildScrollView(child: top),
            ),
            const SizedBox(height: Spacing.sm),
            Expanded(child: patients),
          ],
        );
      },
    );
  }
}

class _QueuesCard extends StatelessWidget {
  const _QueuesCard({
    required this.controls,
    required this.horizontalTiles,
    required this.busyQueueId,
    required this.onCall,
    required this.onRecall,
    required this.onEndSession,
  });

  final List<QueueTypeBoardControl> controls;
  final bool horizontalTiles;
  final String? busyQueueId;
  final ValueChanged<String> onCall;
  final ValueChanged<String> onRecall;
  final VoidCallback onEndSession;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controlsView = DeskQueueControls(
      controls: controls,
      horizontalTiles: horizontalTiles,
      busyQueueId: busyQueueId,
      onCall: onCall,
      onRecall: onRecall,
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm + Spacing.xs,
          vertical: Spacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.deskQueueControlsTitle,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                // Ending the session is rare and cannot be undone, so it is
                // small, plain and in the error colour, not a filled button.
                TextButton.icon(
                  onPressed: onEndSession,
                  icon: const Icon(Icons.stop_circle_outlined, size: 18),
                  label: Text(l10n.deskEndSession),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            // Rows share what is left and scroll only when they cannot fit;
            // tiles take their own height.
            if (horizontalTiles)
              controlsView
            else
              Flexible(child: controlsView),
          ],
        ),
      ),
    );
  }
}

class _PatientsCard extends StatelessWidget {
  const _PatientsCard({
    super.key,
    required this.snapshot,
    required this.table,
    required this.callbacks,
    required this.compact,
    required this.onSearchFocus,
  });

  final BoardSnapshot snapshot;
  final DeskTableState table;
  final QueueDeskCallbacks callbacks;

  /// Hides the title row to save height (the keyboard is open).
  final bool compact;
  final ValueChanged<bool> onSearchFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Offstage keeps the rows below in place, so the search box is not
          // rebuilt (and does not lose focus) when this row comes and goes.
          Offstage(
            offstage: compact,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.sm + Spacing.xs,
                Spacing.md,
                Spacing.sm,
              ),
              // Title and count on one side, Add buttons on the other; on a
              // narrow card the buttons drop to their own line.
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Spacing.sm,
                runSpacing: Spacing.xs,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.deskSessionTableTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        queueDeskFormatSerial(table.total, locale),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: Spacing.xs,
                    runSpacing: Spacing.xs,
                    children: [
                      FilledButton.icon(
                        onPressed: callbacks.onAdd,
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: Text(l10n.deskAddPatientShort),
                        style: _headStyle,
                      ),
                      OutlinedButton.icon(
                        onPressed: callbacks.onAddExisting,
                        icon: const Icon(Icons.person_outline, size: 18),
                        label: Text(l10n.deskAddExistingShort),
                        style: _headOutlinedStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: QueueDeskTableToolbar(
              onSearchFocus: onSearchFocus,
              compact: compact,
              state: table,
              queues: snapshot.queueControls,
              onSearch: callbacks.onSearch,
              onStatus: callbacks.onStatus,
              onQueue: callbacks.onQueue,
              onToggleNotPrinted: callbacks.onToggleNotPrinted,
              onSort: callbacks.onSort,
              onClear: callbacks.onClearFilters,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          const Divider(height: 1),
          Expanded(
            child: QueueDeskTokenTable(
              state: table,
              printerBusyTokenId: snapshot.printerBusyTokenId,
              onSort: callbacks.onSort,
              onLoadMore: callbacks.onLoadMore,
              onRetry: callbacks.onRetry,
              onClearFilters: callbacks.onClearFilters,
              onPrint: callbacks.onPrint,
              onReprint: callbacks.onReprint,
              onEditPatient: callbacks.onEditPatient,
              onCancel: callbacks.onCancel,
            ),
          ),
        ],
      ),
    );
  }

  static final _headStyle = FilledButton.styleFrom(
    minimumSize: const Size(0, 40),
    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
  );
  static final _headOutlinedStyle = OutlinedButton.styleFrom(
    minimumSize: const Size(0, 40),
    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
  );
}
