// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/toast/toast_controller.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/tablet_session.dart';
import '../application/queue_board_providers.dart';
import '../application/queue_board_service.dart';
import '../application/queue_desk_table_controller.dart';
import '../domain/board_models.dart';
import 'queue_desk_dialogs.dart';
import 'queue_desk_errors.dart';
import 'queue_desk_session_open.dart';
import 'queue_desk_token_actions.dart';
import 'queue_desk_view.dart';

part 'queue_desk_panel_widgets.dart';

/// The native queue desk for one chamber: loads the board, wires every action
/// of [QueueDeskView] to the services and dialogs, and reports results through
/// the toaster. The patient table pages itself through
/// [queueDeskTableProvider].
class QueueDeskPanel extends ConsumerStatefulWidget {
  const QueueDeskPanel({super.key, required this.chamberId});

  final String chamberId;

  @override
  ConsumerState<QueueDeskPanel> createState() => _QueueDeskPanelState();
}

class _QueueDeskPanelState extends ConsumerState<QueueDeskPanel> {
  BoardSnapshot? _snapshot;
  var _loading = true;
  var _failed = false;
  var _busy = false;
  String? _busyQueueId;

  QueueDeskTableController get _table =>
      ref.read(queueDeskTableProvider(widget.chamberId).notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_refresh()));
  }

  /// Loads the board without its token list (the table pages its own) and
  /// reloads the table in place once the desk is already on screen.
  Future<void> _refresh() async {
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null) return;
    setState(() {
      _loading = _snapshot == null;
      _failed = false;
    });
    try {
      final board = await ref
          .read(queueBoardServiceProvider)
          .loadBoard(account, widget.chamberId, includeTokens: false);
      if (!mounted) return;
      ref
          .read(queueDeskSessionOpenProvider.notifier)
          .setOpen(board.sessionOpen);
      final firstLoad = _snapshot == null;
      setState(() {
        _snapshot = board;
        _loading = false;
        _failed = false;
      });
      if (!firstLoad && board.sessionOpen) await _table.reload();
    } on Object {
      if (!mounted) return;
      ref.read(queueDeskSessionOpenProvider.notifier).setOpen(false);
      setState(() {
        _loading = false;
        _failed = _snapshot == null;
      });
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    try {
      await action();
      await _refresh();
    } on QueueBoardRefused catch (e) {
      if (!mounted) return;
      ref
          .read(toastControllerProvider.notifier)
          .error(queueDeskErrorMessage(l10n, e));
    } on Object {
      if (!mounted) return;
      ref.read(toastControllerProvider.notifier).error(l10n.deskErrorGeneric);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _busyQueueId = null;
        });
      }
    }
  }

  QueueDeskTokenActions get _tokenActions => QueueDeskTokenActions(
    context: context,
    ref: ref,
    chamberId: widget.chamberId,
    refresh: _refresh,
  );

  Future<void> _openRegister() async {
    final snapshot = _snapshot;
    if (snapshot == null) return;
    final issued = await showDeskRegisterDialog(
      context: context,
      chamberId: widget.chamberId,
      queueControls: snapshot.queueControls,
    );
    if (issued != null && mounted) await _tokenActions.afterIssue(issued);
  }

  Future<void> _openExisting() async {
    final snapshot = _snapshot;
    if (snapshot == null) return;
    final issued = await showDeskExistingDialog(
      context: context,
      chamberId: widget.chamberId,
      queueControls: snapshot.queueControls,
    );
    if (issued != null && mounted) await _tokenActions.afterIssue(issued);
  }

  Future<void> _callNext(String queueTypeId) => _run(() async {
    setState(() => _busyQueueId = queueTypeId);
    final account = ref.read(tabletSessionProvider)!.account;
    final l10n = AppLocalizations.of(context);
    await ref
        .read(queueBoardServiceProvider)
        .callNext(account, widget.chamberId, queueTypeId);
    ref
        .read(toastControllerProvider.notifier)
        .success(l10n.deskCallNextSuccess);
  });

  Future<void> _recall(String queueTypeId) => _run(() async {
    setState(() => _busyQueueId = queueTypeId);
    final account = ref.read(tabletSessionProvider)!.account;
    final l10n = AppLocalizations.of(context);
    await ref
        .read(queueBoardServiceProvider)
        .recall(account, widget.chamberId, queueTypeId);
    ref.read(toastControllerProvider.notifier).success(l10n.deskRecallSent);
  });

  /// Marks a called patient entered or missed.
  Future<void> _resolveCalled(
    BoardTokenView called,
    Future<BoardTokenView> Function(QueueBoardService service, String tokenId)
    resolve,
  ) => _run(() async {
    await resolve(ref.read(queueBoardServiceProvider), called.id);
  });

  /// Asks a yes/no question about the session; true only on [confirmLabel].
  Future<bool> _confirm({
    required String title,
    required String body,
    required String cancelLabel,
    required String confirmLabel,
  }) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: title,
      body: Text(body),
      actions: [
        Builder(
          builder: (dialogContext) => TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
        ),
        Builder(
          builder: (dialogContext) => FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ),
      ],
    );
    return confirmed == true;
  }

  /// Asks first, so a stray tap does not open a session.
  Future<void> _startSession() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      title: l10n.deskStartSessionTitle,
      body: l10n.deskStartSessionBody,
      cancelLabel: l10n.cancelEditButton,
      confirmLabel: l10n.deskStartSession,
    );
    if (!confirmed || !mounted) return;
    await _run(() async {
      final account = ref.read(tabletSessionProvider)!.account;
      await ref
          .read(queueBoardServiceProvider)
          .startSession(account, widget.chamberId);
      if (!mounted) return;
      ref
          .read(toastControllerProvider.notifier)
          .success(l10n.deskSessionStarted);
    });
  }

  /// Asks first (it cannot be undone), saying how many are still waiting.
  Future<void> _endSession() async {
    final waiting = [
      for (final q
          in _snapshot?.queueControls ?? const <QueueTypeBoardControl>[])
        q.waitingCount,
    ].fold<int>(0, (a, b) => a + b);
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      title: l10n.deskEndSessionTitle,
      body: l10n.deskEndSessionBody(waiting),
      cancelLabel: l10n.deskEndSessionKeep,
      confirmLabel: l10n.deskEndSession,
    );
    if (!confirmed || !mounted) return;
    await _run(() async {
      final account = ref.read(tabletSessionProvider)!.account;
      await ref
          .read(queueBoardServiceProvider)
          .endSession(account, widget.chamberId);
      if (!mounted) return;
      ref.read(toastControllerProvider.notifier).success(l10n.deskSessionEnded);
    });
  }

  QueueDeskCallbacks _callbacks() {
    final account = ref.read(tabletSessionProvider)!.account;
    return QueueDeskCallbacks(
      onCall: (id) => unawaited(_callNext(id)),
      onRecall: (id) => unawaited(_recall(id)),
      onEntered: (called) => unawaited(
        _resolveCalled(called, (s, id) => s.markEntered(account, id)),
      ),
      onMissed: (called) => unawaited(
        _resolveCalled(called, (s, id) => s.markSkipped(account, id)),
      ),
      onCancelCalled: (called) => unawaited(_tokenActions.cancel(called)),
      onAdd: () => unawaited(_openRegister()),
      onAddExisting: () => unawaited(_openExisting()),
      onStatus: _table.setStatus,
      onQueue: _table.setQueue,
      onToggleNotPrinted: _table.toggleNotPrinted,
      onClearFilters: _table.clearFilters,
      onSort: _table.sortBy,
      onLoadMore: () => unawaited(_table.loadMore()),
      onRetry: () => unawaited(_table.load()),
      onPrint: (t) => unawaited(_tokenActions.reprint(t)),
      onReprint: (t) => unawaited(_tokenActions.reprint(t)),
      onEditPatient: (t) => unawaited(_tokenActions.editPatient(t)),
      onCancel: (t) => unawaited(_tokenActions.cancel(t)),
      onEndSession: () => unawaited(_endSession()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading && _snapshot == null) {
      return const Center(
        child: BrandLoader(semanticLabel: 'Loading queue desk'),
      );
    }
    final snapshot = _snapshot;
    if (_failed || snapshot == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.deskErrorGeneric, textAlign: TextAlign.center),
              const SizedBox(height: Spacing.md),
              FilledButton(
                onPressed: () => unawaited(_refresh()),
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
      );
    }
    if (!snapshot.sessionOpen) {
      return Align(
        alignment: Alignment.topCenter,
        child: _SessionClosedCard(
          busy: _busy,
          onStart: () => unawaited(_startSession()),
        ),
      );
    }
    return QueueDeskView(
      snapshot: snapshot,
      table: ref.watch(queueDeskTableProvider(widget.chamberId)),
      callbacks: _callbacks(),
      busyQueueId: _busyQueueId,
    );
  }
}
