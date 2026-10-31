// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/breakpoints.dart';
import '../../../core/toast/toast_controller.dart';
import '../../../core/widgets/theme_toggle.dart';
import '../../../l10n/app_localizations.dart';
import '../../connectivity/application/printer_controller.dart';
import '../../connectivity/domain/printer.dart';
import '../../connectivity/presentation/connectivity_page.dart';
import '../../settings/presentation/settings_page.dart';
import 'board_page.dart';
import 'receptionist_side_nav.dart';
import 'work_scope_context_header.dart';

/// Signed-in receptionist chrome: fixed side nav on wide screens, drawer below.
class ReceptionistShell extends ConsumerStatefulWidget {
  const ReceptionistShell({super.key});

  @override
  ConsumerState<ReceptionistShell> createState() => _ReceptionistShellState();
}

class _ReceptionistShellState extends ConsumerState<ReceptionistShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _destination = ReceptionistDestination.board;
  var _drawerOpen = false;

  void _goTo(ReceptionistDestination destination) {
    setState(() => _destination = destination);
  }

  void _openBoard() => _goTo(ReceptionistDestination.board);

  void _openConnectivity() => _goTo(ReceptionistDestination.connectivity);

  void _openSettings() => _goTo(ReceptionistDestination.settings);

  Widget _mainContent() {
    return switch (_destination) {
      ReceptionistDestination.board => const BoardPage(),
      ReceptionistDestination.connectivity => const ConnectivityPage(),
      ReceptionistDestination.settings => const SettingsPage(),
    };
  }

  Widget _topBar({
    VoidCallback? onOpenNav,
    required bool showCompactWorkScope,
    required bool showLogo,
  }) {
    final l10n = AppLocalizations.of(context);
    return DashboardTopBar(
      onOpenNav: onOpenNav,
      navExpanded: _drawerOpen,
      navTooltip: _drawerOpen ? l10n.navCloseMenu : l10n.navOpenMenu,
      showLogo: showLogo,
      workScopeSlot: showCompactWorkScope
          ? const WorkScopeContextHeader(compact: true)
          : null,
    );
  }

  Widget _topBarStrip({required Widget child}) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          child: child,
        ),
      ),
    );
  }

  /// Tells the receptionist when the printer link changes, on any page. The
  /// printer controller lives as long as this shell, so it reconnects on its own.
  void _tellPrinterChanges(PrinterLink? before, PrinterLink now) {
    final l10n = AppLocalizations.of(context);
    final toaster = ref.read(toastControllerProvider.notifier);
    if (now == PrinterLink.connected && before != null) {
      toaster.success(l10n.printerToastConnected);
    } else if (before == PrinterLink.connected &&
        now == PrinterLink.disconnected) {
      toaster.error(l10n.printerToastLost);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      printerControllerProvider.select((s) => s.link),
      _tellPrinterChanges,
    );
    final width = MediaQuery.sizeOf(context).width;
    final wideNav = width >= Breakpoints.dashboardNav;
    final pageBg = Theme.of(context).scaffoldBackgroundColor;
    final scheme = Theme.of(context).colorScheme;

    final sideNav = ReceptionistSideNav(
      destination: _destination,
      onSelectBoard: _openBoard,
      onSelectConnectivity: _openConnectivity,
      onSelectSettings: _openSettings,
    );

    if (wideNav) {
      return Scaffold(
        backgroundColor: pageBg,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 256,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(
                    right: BorderSide(color: scheme.outlineVariant),
                  ),
                ),
                child: sideNav,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _topBarStrip(
                    child: _topBar(
                      showCompactWorkScope: false,
                      showLogo: false,
                    ),
                  ),
                  Expanded(child: _mainContent()),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: pageBg,
      onDrawerChanged: (opened) => setState(() => _drawerOpen = opened),
      drawer: Drawer(
        width: (width * 0.85).clamp(0, 288),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: ReceptionistSideNav(
          destination: _destination,
          // The nav closes the drawer itself before calling these.
          onSelectBoard: _openBoard,
          onSelectConnectivity: _openConnectivity,
          onSelectSettings: _openSettings,
          showCloseButton: true,
          onCloseDrawer: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _topBarStrip(
            child: _topBar(
              onOpenNav: () {
                final scaffold = _scaffoldKey.currentState;
                if (scaffold?.isDrawerOpen ?? false) {
                  scaffold!.closeDrawer();
                } else {
                  scaffold?.openDrawer();
                }
              },
              showCompactWorkScope: true,
              showLogo: true,
            ),
          ),
          Expanded(child: _mainContent()),
        ],
      ),
    );
  }
}
