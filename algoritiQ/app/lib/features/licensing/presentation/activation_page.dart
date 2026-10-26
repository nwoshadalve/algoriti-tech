import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/breakpoints.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/license_state.dart';
import 'activation_card.dart';

/// Shown until a valid license for this device is entered.
///
/// One centred card in portrait and landscape, on any screen size. Scrolls
/// when the keyboard or a large text size leaves too little room.
class ActivationPage extends StatelessWidget {
  const ActivationPage({super.key, required this.state});

  final Unlicensed state;

  static const _cardMaxWidth = 440.0;
  static const _twoColumnMaxWidth = 880.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < Breakpoints.compact;
    final twoColumn =
        size.width >= Breakpoints.twoColumn && size.width > size.height;
    final gutter = compact ? Spacing.md : Spacing.lg;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.all(gutter),
            child: ConstrainedBox(
              // Fill the screen so the card sits centred; scroll when it can't.
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 2 * gutter,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _Header(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: twoColumn
                            ? _twoColumnMaxWidth
                            : _cardMaxWidth,
                      ),
                      child: ActivationCard(state: state, twoColumn: twoColumn),
                    ),
                  ),
                  const _Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    // Wraps instead of overflowing at large text sizes on narrow screens.
    return const Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Spacing.md,
      runSpacing: Spacing.sm,
      children: [BrandLogo.wordmark(height: 32), LanguageSwitcher()],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline_rounded, size: 16, color: color),
        const SizedBox(width: Spacing.sm),
        Flexible(
          child: Text(
            AppLocalizations.of(context).activationFooter,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
