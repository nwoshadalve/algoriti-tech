import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../theme/app_spacing.dart';

/// Bengali / English toggle. Language names are shown in their own language
/// on purpose, so a user can always find theirs.
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  static const _options = [
    _Option(Locale('bn'), 'বাংলা', 'বাংলা'),
    _Option(Locale('en'), 'EN', 'English'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final current = Localizations.localeOf(context).languageCode;

    return Semantics(
      container: true,
      label: AppLocalizations.of(context).languageLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(Spacing.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xs / 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in _options)
                _Segment(
                  option: option,
                  selected: option.locale.languageCode == current,
                  onTap: () => ref
                      .read(localeControllerProvider.notifier)
                      .select(option.locale),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option {
  const _Option(this.locale, this.text, this.spokenName);

  final Locale locale;
  final String text;
  final String spokenName;
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _Option option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: option.spokenName,
      excludeSemantics: true,
      child: Material(
        color: selected ? scheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(Spacing.xl),
        child: InkWell(
          borderRadius: BorderRadius.circular(Spacing.xl),
          onTap: selected ? null : onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 44),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: Text(
                  option.text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
