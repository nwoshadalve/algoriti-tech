import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/license_controller.dart';
import '../domain/license_state.dart';
import 'activation_key_field.dart';
import 'activation_steps.dart';
import 'device_code_row.dart';
import 'license_problem_text.dart';

/// The activation form: device code, key entry and the Activate button.
class ActivationCard extends ConsumerStatefulWidget {
  const ActivationCard({
    super.key,
    required this.state,
    this.twoColumn = false,
  });

  final Unlicensed state;

  /// Lay out as two columns (wide landscape screens).
  final bool twoColumn;

  @override
  ConsumerState<ActivationCard> createState() => _ActivationCardState();
}

class _ActivationCardState extends ConsumerState<ActivationCard> {
  final _keyController = TextEditingController();
  LicenseProblem? _problem;
  bool _busy = false;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _problem = widget.state.problem;
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    setState(() => _busy = true);
    final problem = await ref
        .read(licenseControllerProvider.notifier)
        .activate(_keyController.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _problem = problem;
    });
  }

  Future<void> _copyDeviceCode() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(
      ClipboardData(text: widget.state.deviceCode.toString()),
    );
    if (!mounted) return;
    setState(() => _copied = true);
    messenger.showSnackBar(SnackBar(content: Text(l10n.deviceCodeCopied)));
  }

  @override
  Widget build(BuildContext context) {
    const intro = _Intro();
    final device = _DeviceSection(
      keyController: _keyController,
      copied: _copied,
      deviceCode: widget.state.deviceCode.toString(),
      onCopy: _copyDeviceCode,
    );
    final form = _KeyForm(
      controller: _keyController,
      busy: _busy,
      problem: _problem,
      onActivate: _activate,
    );
    const gap = SizedBox(height: Spacing.lg);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: widget.twoColumn
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [intro, gap, device],
                    ),
                  ),
                  const SizedBox(width: Spacing.xl),
                  Expanded(child: form),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [intro, gap, device, gap, form],
              ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.activationTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.activationIntro,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DeviceSection extends StatelessWidget {
  const _DeviceSection({
    required this.keyController,
    required this.copied,
    required this.deviceCode,
    required this.onCopy,
  });

  final TextEditingController keyController;
  final bool copied;
  final String deviceCode;
  final VoidCallback onCopy;

  ActivationStep _stepFor(String key) {
    if (key.trim().isNotEmpty) return ActivationStep.enterKey;
    return copied ? ActivationStep.getKey : ActivationStep.copyCode;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder(
          valueListenable: keyController,
          builder: (context, value, _) =>
              ActivationStepper(current: _stepFor(value.text)),
        ),
        const SizedBox(height: Spacing.lg),
        DeviceCodeRow(
          label: l10n.deviceCodeLabel,
          code: deviceCode,
          copyLabel: l10n.copyDeviceCode,
          onCopy: onCopy,
        ),
      ],
    );
  }
}

class _KeyForm extends StatelessWidget {
  const _KeyForm({
    required this.controller,
    required this.busy,
    required this.problem,
    required this.onActivate,
  });

  final TextEditingController controller;
  final bool busy;
  final LicenseProblem? problem;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final problem = this.problem;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActivationKeyField(
          controller: controller,
          enabled: !busy,
          onSubmitted: onActivate,
        ),
        if (problem != null) ...[
          const SizedBox(height: Spacing.md),
          _ProblemMessage(text: licenseProblemText(l10n, problem)),
        ],
        const SizedBox(height: Spacing.lg),
        LoadingButton(
          label: l10n.activateButton,
          loadingLabel: l10n.activating,
          isLoading: busy,
          onPressed: onActivate,
        ),
      ],
    );
  }
}

class _ProblemMessage extends StatelessWidget {
  const _ProblemMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 20, color: color),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
