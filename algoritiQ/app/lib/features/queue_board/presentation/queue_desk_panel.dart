// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/breakpoints.dart';
import '../../../core/toast/toast_controller.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/tablet_session.dart';
import '../application/queue_board_providers.dart';
import '../application/queue_board_service.dart';
import '../domain/board_models.dart';
import 'queue_desk_dialogs.dart';
import 'queue_desk_errors.dart';
import 'queue_desk_format.dart';
import 'queue_desk_session_open.dart';

part 'queue_desk_panel_widgets.dart';

/// Native queue desk (mock screen 10): left ⅓ queue control, right ⅔ session table.
class QueueDeskPanel extends ConsumerStatefulWidget {
  const QueueDeskPanel({
    super.key,
    required this.chamberId,

    /// Three equal queue columns in **portrait** on the native counter desk only.
    this.portraitQueueColumns = false,
  });

  final String chamberId;
  final bool portraitQueueColumns;

  @override
  ConsumerState<QueueDeskPanel> createState() => _QueueDeskPanelState();
}

class _QueueDeskPanelState extends ConsumerState<QueueDeskPanel> {
  BoardSnapshot? _snapshot;
  var _loading = true;
  var _failed = false;
  var _busy = false;
  String? _busyQueueId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_refresh()));
  }

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
          .loadBoard(account, widget.chamberId);
      if (!mounted) return;
      ref
          .read(queueDeskSessionOpenProvider.notifier)
          .setOpen(board.sessionOpen);
      setState(() {
        _snapshot = board;
        _loading = false;
        _failed = false;
      });
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

  void _openRegister() {
    final snapshot = _snapshot;
    if (snapshot == null) return;
    unawaited(
      showDeskRegisterDialog(
        context: context,
        ref: ref,
        chamberId: widget.chamberId,
        queueControls: snapshot.queueControls,
        onDone: () => unawaited(_refresh()),
      ),
    );
  }

  void _openExisting() {
    final snapshot = _snapshot;
    if (snapshot == null) return;
    unawaited(
      showDeskExistingDialog(
        context: context,
        ref: ref,
        chamberId: widget.chamberId,
        queueControls: snapshot.queueControls,
        onDone: () => unawaited(_refresh()),
      ),
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
    if (_failed && _snapshot == null) {
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
    final snapshot = _snapshot;
    if (snapshot == null) return const SizedBox.shrink();

    if (!snapshot.sessionOpen) {
      return Align(
        alignment: Alignment.topCenter,
        child: _SessionClosedCard(
          busy: _busy,
          onStart: () => _run(() async {
            final account = ref.read(tabletSessionProvider)!.account;
            await ref
                .read(queueBoardServiceProvider)
                .startSession(account, widget.chamberId);
            if (!mounted) return;
            ref
                .read(toastControllerProvider.notifier)
                .success(l10n.deskSessionStarted);
          }),
        ),
      );
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isPortrait = orientation == Orientation.portrait;
            final compact = isPortrait;
            final sideBySide =
                !isPortrait && constraints.maxWidth >= Breakpoints.compact;
            final queuesInRow = widget.portraitQueueColumns && isPortrait;
            final left = _LeftColumn(
              compact: compact,
              queuesInRow: queuesInRow,
              landscapeDesk: sideBySide,
              snapshot: snapshot,
              busy: _busy,
              busyQueueId: _busyQueueId,
              onEntered: (id) => _run(() async {
                final account = ref.read(tabletSessionProvider)!.account;
                await ref
                    .read(queueBoardServiceProvider)
                    .markEntered(account, id);
              }),
              onSkipped: (id) => _run(() async {
                final account = ref.read(tabletSessionProvider)!.account;
                await ref
                    .read(queueBoardServiceProvider)
                    .markSkipped(account, id);
              }),
              onCallNext: (queueTypeId) => _run(() async {
                setState(() => _busyQueueId = queueTypeId);
                final account = ref.read(tabletSessionProvider)!.account;
                await ref
                    .read(queueBoardServiceProvider)
                    .callNext(account, widget.chamberId, queueTypeId);
                ref
                    .read(toastControllerProvider.notifier)
                    .success(l10n.deskCallNextSuccess);
              }),
              onRecall: (queueTypeId) => _run(() async {
                setState(() => _busyQueueId = queueTypeId);
                final account = ref.read(tabletSessionProvider)!.account;
                await ref
                    .read(queueBoardServiceProvider)
                    .recall(account, widget.chamberId, queueTypeId);
                ref
                    .read(toastControllerProvider.notifier)
                    .success(l10n.deskRecallSent);
              }),
            );
            final right = _SessionTableCard(
              compact: compact,
              landscapeDesk: sideBySide,
              portraitDesk: isPortrait,
              snapshot: snapshot,
              onAddNew: _openRegister,
              onAddExisting: _openExisting,
            );

            if (!sideBySide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 2, child: left),
                  SizedBox(height: compact ? Spacing.xs : Spacing.sm),
                  Expanded(child: right),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 1, child: left),
                const SizedBox(width: Spacing.sm),
                Expanded(flex: 2, child: right),
              ],
            );
          },
        );
      },
    );
  }
}
