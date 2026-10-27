import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../theme/app_spacing.dart';

/// Bengali / English toggle, sized to sit beside the logo in a top bar.
/// Language names are shown in their own language on purpose, so a user can
/// always find theirs.
///
/// The pill is 32 dp tall; each segment's touch area is 48 dp.
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  static const _options = [
    _Option(Locale('bn'), 'বাংলা', 'বাংলা'),
    _Option(Locale('en'), 'EN', 'English'),
  ];

  static const _pillHeight = 32.0;
  static const _touchHeight = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final current = Localizations.localeOf(context).languageCode;

    return Semantics(
      container: true,
      label: AppLocalizations.of(context).languageLabel,
      child: SizedBox(
        height: _touchHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The visible track, centred inside the taller touch area.
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  height: _pillHeight,
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(_pillHeight / 2),
                    ),
                  ),
                ),
              ),
            ),
            Row(
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
          ],
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: option.spokenName,
      excludeSemantics: true,
      // The 48 dp touch area is the outer detector; the ripple, hover and
      // focus effects belong to the 32 dp pill the user actually sees.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: selected ? null : onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: LanguageSwitcher._touchHeight,
            minHeight: LanguageSwitcher._touchHeight,
          ),
          child: Center(
            child: Material(
              color: selected ? scheme.primary : Colors.transparent,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: selected ? null : onTap,
                child: SizedBox(
                  height: LanguageSwitcher._pillHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    child: Center(
                      child: Text(
                        option.text,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: selected
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
