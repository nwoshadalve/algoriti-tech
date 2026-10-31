// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../l10n/app_localizations.dart';
import 'dashboard_user_menu.dart';

enum ReceptionistDestination { board, connectivity, settings }

/// Side navigation for the receptionist dashboard (drawer or fixed rail).
class ReceptionistSideNav extends StatelessWidget {
  const ReceptionistSideNav({
    super.key,
    required this.destination,
    required this.onSelectBoard,
    required this.onSelectConnectivity,
    required this.onSelectSettings,
    this.onCloseDrawer,
    this.showCloseButton = false,
  });

  final ReceptionistDestination destination;
  final VoidCallback onSelectBoard;
  final VoidCallback onSelectConnectivity;
  final VoidCallback onSelectSettings;
  final VoidCallback? onCloseDrawer;
  final bool showCloseButton;

  void _selectBoard() {
    onCloseDrawer?.call();
    onSelectBoard();
  }

  void _selectConnectivity() {
    onCloseDrawer?.call();
    onSelectConnectivity();
  }

  void _selectSettings() {
    onCloseDrawer?.call();
    onSelectSettings();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.xs,
                Spacing.sm,
                Spacing.sm,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: BrandLogo.wordmark(height: 28),
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      style: IconButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Radii.field),
                        ),
                      ),
                      onPressed: onCloseDrawer,
                      tooltip: l10n.navCloseMenu,
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.sm,
                  Spacing.sm,
                  Spacing.sm,
                  Spacing.xs,
                ),
                children: [
                  Semantics(
                    selected: destination == ReceptionistDestination.board,
                    button: true,
                    label: l10n.navBoard,
                    child: _NavTile(
                      icon: Icons.view_kanban_outlined,
                      label: l10n.navBoard,
                      selected: destination == ReceptionistDestination.board,
                      onTap: _selectBoard,
                    ),
                  ),
                  Semantics(
                    selected:
                        destination == ReceptionistDestination.connectivity,
                    button: true,
                    label: l10n.navConnectivity,
                    child: _NavTile(
                      icon: Icons.settings_input_antenna_rounded,
                      label: l10n.navConnectivity,
                      selected:
                          destination == ReceptionistDestination.connectivity,
                      onTap: _selectConnectivity,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.xs,
                Spacing.sm,
                Spacing.xs,
                Spacing.md,
              ),
              child: DashboardUserMenu(
                onCloseDrawer: onCloseDrawer,
                onOpenSettings: _selectSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? (isDark ? BrandColors.white : BrandColors.navy)
        : Colors.transparent;
    final fg = selected
        ? (isDark ? BrandColors.navy : BrandColors.white)
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75);

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.field),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.field),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm + Spacing.xs,
              vertical: Spacing.sm + 2,
            ),
            child: Row(
              children: [
                Icon(icon, color: fg, size: 22),
                const SizedBox(width: Spacing.sm + Spacing.xs),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
