import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// Activation key entry.
///
/// Starts as one line and grows with the key (keys are long). Line breaks and
/// spaces from a pasted message are dropped (the key decoder ignores them
/// anyway). The keyboard's Done key activates; a Paste button saves typing.
class ActivationKeyField extends StatelessWidget {
  const ActivationKeyField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.activationKeyLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        TextField(
          controller: controller,
          enabled: enabled,
          minLines: 1,
          maxLines: 4,
          // A single-line keyboard type keeps a Done key instead of Enter.
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmitted(),
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          style: theme.textTheme.titleMedium?.copyWith(
            letterSpacing: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          decoration: InputDecoration(
            hintText: l10n.activationKeyHint,
            suffixIcon: _PasteButton(controller: controller, enabled: enabled),
          ),
        ),
      ],
    );
  }
}

class _PasteButton extends StatelessWidget {
  const _PasteButton({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.replaceAll(RegExp(r'\s'), '');
    if (text == null || text.isEmpty) return;
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      onPressed: enabled ? _paste : null,
      tooltip: l10n.pasteKey,
      icon: const Icon(Icons.content_paste_rounded),
    );
  }
}
