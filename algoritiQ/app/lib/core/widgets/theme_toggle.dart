// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_controller.dart';
import 'brand_logo.dart';
import 'dashboard_nav_menu_button.dart';
import 'language_switcher.dart';

/// Light / dark toggle (matches the web dashboard control).
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = isDark ? l10n.themeLight : l10n.themeDark;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: scheme.surface,
        shape: CircleBorder(side: BorderSide(color: scheme.outline)),
        elevation: 1,
        shadowColor: scheme.shadow.withValues(alpha: 0.12),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => ref
              .read(themeControllerProvider.notifier)
              .toggleLightDark(context),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Language and theme controls for the dashboard top bar.
class DashboardToolbar extends StatelessWidget {
  const DashboardToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LanguageSwitcher(),
        SizedBox(width: Spacing.sm),
        ThemeToggle(),
      ],
    );
  }
}

/// Signed-in dashboard header: wordmark on the left, language and theme on the right.
///
/// When [onOpenNav] is set (narrow layouts), a menu control sits before the logo.
class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    super.key,
    this.onOpenNav,
    this.navExpanded = false,
    this.navTooltip,
    this.workScopeSlot,
    this.showLogo = true,
  });

  final VoidCallback? onOpenNav;
  final bool navExpanded;
  final String? navTooltip;

  /// Chamber or doctor name when the drawer is hidden (narrow layout).
  final Widget? workScopeSlot;

  /// False when the fixed sidebar already shows the wordmark.
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final openNav = onOpenNav;
    final scope = workScopeSlot;

    return Row(
      children: [
        if (openNav != null) ...[
          DashboardNavMenuButton(
            onPressed: openNav,
            expanded: navExpanded,
            tooltip: navTooltip ?? l10n.navOpenMenu,
          ),
          const SizedBox(width: Spacing.xs),
        ],
        if (showLogo)
          const Flexible(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: BrandLogo.wordmark(height: 28),
            ),
          )
        else
          const Spacer(),
        if (scope != null) ...[
          const SizedBox(width: Spacing.sm),
          Expanded(flex: 3, child: scope),
        ],
        const DashboardToolbar(),
      ],
    );
  }
}
