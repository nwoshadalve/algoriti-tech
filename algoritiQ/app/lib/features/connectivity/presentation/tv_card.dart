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
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/application/receptionist_work.dart';
import '../../tv_link/application/tv_link_providers.dart';
import '../application/tv_test_service.dart';
import 'connectivity_card.dart';

/// The waiting-room TV of the chosen chamber: paired or not, connected or
/// not, and what staff can do about it (pair, test the screen, test the
/// sound, unpair). Connected means the TV itself is answering the tablet, not
/// that something is listening.
class TvCard extends ConsumerStatefulWidget {
  const TvCard({super.key});

  @override
  ConsumerState<TvCard> createState() => _TvCardState();
}

class _TvCardState extends ConsumerState<TvCard> {
  var _busy = false;

  Future<bool> _confirm({
    required String title,
    required String body,
    required String action,
  }) async {
    final l10n = AppLocalizations.of(context);
    final sure = await showAppDialog<bool>(
      context: context,
      title: title,
      body: Text(body),
      actions: [
        Builder(
          builder: (dialogContext) => OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelEditButton),
          ),
        ),
        Builder(
          builder: (dialogContext) => FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(action),
          ),
        ),
      ],
    );
    return sure == true && mounted;
  }

  Future<void> _test({
    required Future<TvTestOutcome> Function() run,
    required String title,
    required String body,
    required String action,
  }) async {
    final l10n = AppLocalizations.of(context);
    final toaster = ref.read(toastControllerProvider.notifier);
    if (!await _confirm(title: title, body: body, action: action)) return;
    setState(() => _busy = true);
    try {
      switch (await run()) {
        case TvTestOutcome.shown:
          toaster.success(l10n.tvToastTestScreenOk);
        case TvTestOutcome.played:
          toaster.success(l10n.tvToastTestSoundOk);
        case TvTestOutcome.soundFailed:
          toaster.error(l10n.tvToastSoundFailed);
        case TvTestOutcome.noReply:
          toaster.error(l10n.tvToastNoReply);
        case TvTestOutcome.notConnected:
          toaster.error(l10n.tvToastNotConnected);
        case TvTestOutcome.noDetails:
          toaster.error(l10n.tvToastNoDetails);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final work = ref.watch(receptionistWorkProvider);
    final chamberId = work is ReceptionistWorkReady ? work.selected.id : null;
    final connected =
        chamberId != null &&
        (ref.watch(tvConnectedProvider(chamberId)).value ?? false);

    return ConnectivityCard(
      icon: Icons.tv_rounded,
      title: l10n.tvTitle,
      statusLabel: connected
          ? l10n.tvStatusConnected
          : l10n.tvStatusNotConnected,
      tone: connected ? ConnectivityTone.good : ConnectivityTone.problem,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConnectivityBody(
            connected ? l10n.tvBodyConnected : l10n.tvBodyNotConnected,
          ),
          if (connected) ...[
            const SizedBox(height: Spacing.md),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: [
                LoadingButton(
                  label: l10n.tvActionTestScreen,
                  isLoading: _busy,
                  onPressed: () => unawaited(
                    _test(
                      run: ref.read(tvTestServiceProvider).testDisplay,
                      title: l10n.tvTestScreenConfirmTitle,
                      body: l10n.tvTestScreenConfirmBody,
                      action: l10n.tvTestScreenConfirmAction,
                    ),
                  ),
                ),
                LoadingButton(
                  label: l10n.tvActionTestSound,
                  isLoading: _busy,
                  onPressed: () => unawaited(
                    _test(
                      run: ref.read(tvTestServiceProvider).testSound,
                      title: l10n.tvTestSoundConfirmTitle,
                      body: l10n.tvTestSoundConfirmBody,
                      action: l10n.tvTestSoundConfirmAction,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
