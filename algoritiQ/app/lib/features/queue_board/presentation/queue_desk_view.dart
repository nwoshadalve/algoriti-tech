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
import 'queue_desk_lanes.dart';
import 'queue_desk_session_table.dart';
import 'queue_desk_table_toolbar.dart';

/// Below this width the Add buttons drop to their own line under the tabs.
const _tabRowMinWidth = 560.0;

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
  final ValueChanged<BoardTokenView> onEntered;
  final ValueChanged<BoardTokenView> onMissed;
  final ValueChanged<BoardTokenView> onCancelCalled;
  final VoidCallback onAdd;
  final VoidCallback onAddExisting;
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

/// The open-session desk on one screen with two tabs, so each part gets the
/// whole screen instead of sharing it: **Calling** (one card per queue with its
/// Call button and the patient it is calling) and **Patients** (the session
/// table). The Add buttons stay in view on both tabs. Only the table's rows, or
/// a list of more queues than fit, scroll.
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
  /// 0 is Calling, 1 is Patients; the desk opens on Calling.
  var _tab = 0;

  BoardSnapshot get snapshot => widget.snapshot;
  DeskTableState get table => widget.table;
  QueueDeskCallbacks get callbacks => widget.callbacks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TabRow(
          selected: _tab,
          onSelect: (tab) => setState(() => _tab = tab),
          calling: snapshot.calledTokens.length,
          patients: table.total,
          onAdd: callbacks.onAdd,
          onAddExisting: callbacks.onAddExisting,
        ),
        const SizedBox(height: Spacing.sm),
        Expanded(
          child: _tab == 0
              ? DeskQueueLanes(
                  controls: snapshot.queueControls,
                  called: snapshot.calledTokens,
                  busyQueueId: widget.busyQueueId,
                  onCall: callbacks.onCall,
                  onRecall: callbacks.onRecall,
                  onEntered: callbacks.onEntered,
                  onMissed: callbacks.onMissed,
                  onCancel: callbacks.onCancelCalled,
                  onEndSession: callbacks.onEndSession,
                )
              : _PatientsCard(
                  snapshot: snapshot,
                  table: table,
                  callbacks: callbacks,
                ),
        ),
      ],
    );
  }
}

/// The two tabs with how many calls and patients each holds, and the Add
/// buttons. A narrow pane puts the buttons on a second line.
class _TabRow extends StatelessWidget {
  const _TabRow({
    required this.selected,
    required this.onSelect,
    required this.calling,
    required this.patients,
    required this.onAdd,
    required this.onAddExisting,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final int calling;
  final int patients;
  final VoidCallback onAdd;
  final VoidCallback onAddExisting;

  static final _buttonSize = const Size(0, 44);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final tabs = SegmentedButton<int>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(minimumSize: _buttonSize),
      segments: [
        ButtonSegment(
          value: 0,
          label: Text(
            '${l10n.deskTabCalling} ${queueDeskFormatSerial(calling, locale)}',
          ),
        ),
        ButtonSegment(
          value: 1,
          label: Text(
            '${l10n.deskTabPatients} ${queueDeskFormatSerial(patients, locale)}',
          ),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (value) => onSelect(value.first),
    );
    final add = Wrap(
      spacing: Spacing.xs,
      runSpacing: Spacing.xs,
      children: [
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.person_add_outlined, size: 18),
          label: Text(l10n.deskAddPatientShort),
          style: FilledButton.styleFrom(minimumSize: _buttonSize),
        ),
        OutlinedButton.icon(
          onPressed: onAddExisting,
          icon: const Icon(Icons.person_outline, size: 18),
          label: Text(l10n.deskAddExistingShort),
          style: OutlinedButton.styleFrom(minimumSize: _buttonSize),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _tabRowMinWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tabs,
              const SizedBox(height: Spacing.xs),
              add,
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: tabs,
              ),
            ),
            add,
          ],
        );
      },
    );
  }
}

/// The session table: its filters and sort above, the rows below.
class _PatientsCard extends StatelessWidget {
  const _PatientsCard({
    required this.snapshot,
    required this.table,
    required this.callbacks,
  });

  final BoardSnapshot snapshot;
  final DeskTableState table;
  final QueueDeskCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.md,
              Spacing.sm,
            ),
            child: QueueDeskTableToolbar(
              state: table,
              queues: snapshot.queueControls,
              onStatus: callbacks.onStatus,
              onQueue: callbacks.onQueue,
              onToggleNotPrinted: callbacks.onToggleNotPrinted,
              onSort: callbacks.onSort,
              onClear: callbacks.onClearFilters,
            ),
          ),
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
}
