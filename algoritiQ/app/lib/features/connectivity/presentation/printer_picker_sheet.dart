// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/toast/toast_controller.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../application/printer_controller.dart';
import '../domain/printer.dart';

/// Widest the picker gets on a tablet; it is a bottom sheet on a phone.
const _sheetMaxWidth = 560.0;

Future<void> showPrinterPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: _sheetMaxWidth),
    builder: (_) => const _PrinterPicker(),
  );
}

class _PrinterPicker extends ConsumerStatefulWidget {
  const _PrinterPicker();

  @override
  ConsumerState<_PrinterPicker> createState() => _PrinterPickerState();
}

class _PrinterPickerState extends ConsumerState<_PrinterPicker> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.read(printerControllerProvider.notifier).scan();
    });
  }

  Future<void> _choose(PrinterDevice device) async {
    final l10n = AppLocalizations.of(context);
    final toaster = ref.read(toastControllerProvider.notifier);
    final navigator = Navigator.of(context);
    final outcome = await ref
        .read(printerControllerProvider.notifier)
        .choose(device);
    switch (outcome) {
      case ChooseOutcome.connected:
        toaster.success(l10n.printerToastConnected);
        navigator.pop();
      case ChooseOutcome.rejected:
        toaster.error(l10n.printerToastRejected);
      case ChooseOutcome.failed:
        toaster.error(l10n.printerToastChooseFailed);
        navigator.pop();
      case ChooseOutcome.bluetoothOff || ChooseOutcome.denied:
        navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(printerControllerProvider);
    final controller = ref.read(printerControllerProvider.notifier);
    final saved = state.saved;

    return PopScope(
      onPopInvokedWithResult: (_, _) => controller.stopScan(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md + Spacing.xs,
            0,
            Spacing.md + Spacing.xs,
            Spacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.printerPickerTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.printerPickerBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Flexible(
                child: state.found.isEmpty
                    ? _Empty(scanning: state.scanning)
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          for (final device in state.found)
                            _DeviceTile(
                              key: ValueKey(device.address),
                              device: device,
                              current: device == saved,
                              enabled: !state.working,
                              onTap: () => _choose(device),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                l10n.printerPickerPairHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: state.working
                    ? const BrandLoader()
                    : OutlinedButton(
                        onPressed: state.scanning ? null : controller.scan,
                        child: Text(
                          state.scanning
                              ? l10n.printerPickerScanning
                              : l10n.printerPickerScanAgain,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.scanning});

  final bool scanning;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
      child: Center(
        child: scanning
            ? BrandLoader(semanticLabel: l10n.printerPickerScanning)
            : Text(l10n.printerPickerEmpty),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    super.key,
    required this.device,
    required this.current,
    required this.enabled,
    required this.onTap,
  });

  final PrinterDevice device;
  final bool current;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(Radii.field),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.field),
              border: Border.all(
                color: current ? scheme.primary : scheme.outlineVariant,
                width: current ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm + Spacing.xs,
            ),
            child: Row(
              children: [
                Icon(Icons.print_outlined, color: scheme.primary),
                const SizedBox(width: Spacing.sm + Spacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        device.address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (current) Icon(Icons.check_rounded, color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
