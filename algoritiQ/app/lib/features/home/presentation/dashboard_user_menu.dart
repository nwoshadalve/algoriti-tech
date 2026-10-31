// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../application/receptionist_work.dart';
import '../../access/application/tablet_session.dart';
import '../../access/domain/account.dart';

/// Signed-in person at the bottom of the sidebar (Settings and Sign out).
class DashboardUserMenu extends ConsumerStatefulWidget {
  const DashboardUserMenu({
    super.key,
    this.onCloseDrawer,
    required this.onOpenSettings,
  });

  final VoidCallback? onCloseDrawer;
  final VoidCallback onOpenSettings;

  @override
  ConsumerState<DashboardUserMenu> createState() => _DashboardUserMenuState();
}

class _DashboardUserMenuState extends ConsumerState<DashboardUserMenu> {
  var _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    await ref.read(tabletSessionProvider.notifier).signOut();
    if (mounted) setState(() => _signingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(tabletSessionProvider);
    final account = session?.account;
    if (account == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final name = _personName(account);
    final role = switch (account.role) {
      Role.admin => l10n.roleAdmin,
      Role.receptionist => l10n.roleReceptionist,
    };

    final canChangeScope = ref
        .read(receptionistWorkProvider.notifier)
        .canChangeWorkScope;

    return MenuAnchor(
      alignmentOffset: const Offset(0, -Spacing.sm),
      crossAxisUnconstrained: false,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surface),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        elevation: const WidgetStatePropertyAll(8),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(Spacing.xs)),
      ),
      menuChildren: [
        if (canChangeScope)
          MenuItemButton(
            leadingIcon: const Icon(Icons.swap_horiz_rounded, size: 20),
            onPressed: () {
              widget.onCloseDrawer?.call();
              ref.read(receptionistWorkProvider.notifier).reopenChoice();
            },
            child: Text(l10n.navChangeWorkScope),
          ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.settings_outlined, size: 20),
          onPressed: () {
            widget.onCloseDrawer?.call();
            widget.onOpenSettings();
          },
          child: Text(l10n.navSettings),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.logout_rounded, size: 20),
          onPressed: _signingOut ? null : _signOut,
          child: Text(_signingOut ? l10n.signingOut : l10n.signOut),
        ),
      ],
      builder: (context, controller, child) {
        return Semantics(
          button: true,
          label: l10n.userMenuLabel,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.sm,
                ),
                child: Row(
                  children: [
                    UserAvatar(account: account),
                    const SizedBox(width: Spacing.sm + Spacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            role,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.unfold_more_rounded,
                      color: scheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static String _personName(Account account) {
    final parts = [
      account.firstName.trim(),
      account.lastName.trim(),
    ].where((part) => part.isNotEmpty);
    if (parts.isNotEmpty) return parts.join(' ');
    if (account.displayName.isNotEmpty) return account.displayName;
    return account.username;
  }
}
