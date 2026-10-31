// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/toast/toast_controller.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/printer_controller.dart';
import '../application/test_token_service.dart';
import '../domain/printer.dart';
import 'connectivity_card.dart';
import 'printer_picker_sheet.dart';

/// The printer: whether it is connected, and what the receptionist can do.
class PrinterCard extends ConsumerWidget {
  const PrinterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(printerControllerProvider);
    final theme = Theme.of(context);

    final (label, tone) = _headline(l10n, state);

    return ConnectivityCard(
      icon: Icons.print_outlined,
      title: l10n.printerTitle,
      statusLabel: label,
      tone: tone,
      child: !state.loaded
          ? const SizedBox(height: Spacing.lg)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _body(l10n, state),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (state.link == PrinterLink.disconnected &&
                    state.nextTryAt != null)
                  _RetryCountdown(until: state.nextTryAt!),
                if (state.saved != null) ...[
                  const SizedBox(height: Spacing.sm),
                  Text(
                    state.saved!.name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: Spacing.md),
                _Actions(state: state),
              ],
            ),
    );
  }

  (String, ConnectivityTone) _headline(
    AppLocalizations l10n,
    PrinterState state,
  ) {
    if (state.link == PrinterLink.blocked) {
      return (
        switch (state.access) {
          BluetoothAccess.off => l10n.printerStatusBtOff,
          BluetoothAccess.denied => l10n.printerStatusBtDenied,
          _ => l10n.printerStatusBtMissing,
        },
        ConnectivityTone.problem,
      );
    }
    return switch (state.link) {
      PrinterLink.connected => (
        l10n.printerStatusConnected,
        ConnectivityTone.good,
      ),
      PrinterLink.connecting => (
        l10n.printerStatusConnecting,
        ConnectivityTone.waiting,
      ),
      PrinterLink.disconnected => (
        l10n.printerStatusDisconnected,
        ConnectivityTone.problem,
      ),
      _ => (l10n.printerStatusNotPaired, ConnectivityTone.waiting),
    };
  }

  String _body(AppLocalizations l10n, PrinterState state) {
    if (state.link == PrinterLink.blocked) {
      return switch (state.access) {
        BluetoothAccess.off => l10n.printerBodyBtOff,
        BluetoothAccess.denied => l10n.printerBodyBtDenied,
        _ => l10n.printerBodyBtMissing,
      };
    }
    return switch (state.link) {
      PrinterLink.connected => l10n.printerBodyConnected,
      PrinterLink.notPaired => l10n.printerBodyNotPaired,
      _ => l10n.printerBodyDisconnected,
    };
  }
}

/// "Trying again in 12 s", counting down on its own.
class _RetryCountdown extends StatefulWidget {
  const _RetryCountdown({required this.until});

  final DateTime until;

  @override
  State<_RetryCountdown> createState() => _RetryCountdownState();
}

class _RetryCountdownState extends State<_RetryCountdown> {
  late final Stream<int> _tick = Stream.periodic(
    const Duration(seconds: 1),
    (i) => i,
  );

  int get _seconds {
    final left = widget.until.difference(DateTime.now()).inSeconds;
    return left < 0 ? 0 : left + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: StreamBuilder<int>(
        stream: _tick,
        builder: (context, _) => Text(
          AppLocalizations.of(context).printerRetryIn(_seconds),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.state});

  final PrinterState state;

  Future<void> _retry(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final toaster = ref.read(toastControllerProvider.notifier);
    final outcome = await ref
        .read(printerControllerProvider.notifier)
        .retryNow();
    if (outcome == ConnectOutcome.failed) {
      toaster.error(l10n.printerToastConnectFailed);
    }
  }

  /// Asks first, then prints a sample token.
  Future<void> _test(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final toaster = ref.read(toastControllerProvider.notifier);
    final service = ref.read(testTokenServiceProvider);

    final sure = await showAppDialog<bool>(
      context: context,
      title: l10n.printerTestConfirmTitle,
      body: Text(l10n.printerTestConfirmBody),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelEditButton),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.printerTestConfirmAction),
        ),
      ],
    );
    if (sure != true) return;

    switch (await service.run()) {
      case TestTokenOutcome.printed:
        toaster.success(l10n.printerToastTestOk);
      case TestTokenOutcome.failed:
        toaster.error(l10n.printerToastTestFailed);
      case TestTokenOutcome.notConnected:
        toaster.error(l10n.printerToastTestFailed);
      case TestTokenOutcome.noDetails:
        toaster.error(l10n.printerToastNoDetails);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(printerControllerProvider.notifier);

    final primary = switch (state.link) {
      PrinterLink.blocked when state.access == BluetoothAccess.off =>
        LoadingButton(
          label: l10n.printerActionTurnOn,
          onPressed: controller.turnBluetoothOn,
        ),
      PrinterLink.blocked when state.access == BluetoothAccess.denied =>
        LoadingButton(
          label: l10n.printerActionAllow,
          onPressed: controller.allowBluetooth,
        ),
      PrinterLink.blocked => null,
      PrinterLink.notPaired => LoadingButton(
        label: l10n.printerActionChoose,
        onPressed: () => showPrinterPicker(context),
      ),
      PrinterLink.connected => LoadingButton(
        label: l10n.printerActionTest,
        isLoading: state.working,
        onPressed: () => _test(context, ref),
      ),
      _ => LoadingButton(
        label: l10n.printerActionRetry,
        isLoading: state.link == PrinterLink.connecting,
        onPressed: () => _retry(context, ref),
      ),
    };

    return Align(alignment: AlignmentDirectional.centerStart, child: primary);
  }
}
