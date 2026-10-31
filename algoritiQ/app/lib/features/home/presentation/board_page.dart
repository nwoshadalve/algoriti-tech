// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/server_controller.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/breakpoints.dart';
import '../../../core/widgets/health_status_row.dart';
import '../../../core/widgets/page_header.dart';
import '../../../l10n/app_localizations.dart';
import '../application/receptionist_work.dart';
import '../../access/application/tablet_session.dart';
import '../../access/domain/account.dart';
import '../../licensing/presentation/license_summary.dart';

/// Receptionist home: server health, account summary, and the queue board.
class BoardPage extends ConsumerWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(tabletSessionProvider);
    final account = session?.account;
    final server = ref.watch(serverControllerProvider);

    final name = _displayName(account);
    final serverMessage = switch (server) {
      ServerRunning() => l10n.boardServerOk,
      ServerStarting() => l10n.boardServerStarting,
      ServerFailed() => l10n.boardServerFailed,
    };
    final serverStatus = switch (server) {
      ServerRunning() => HealthStatus.ok,
      ServerStarting() => HealthStatus.pending,
      ServerFailed() => HealthStatus.error,
    };

    final work = ref.watch(receptionistWorkProvider);
    final workName = work is ReceptionistWorkReady ? work.selected.name : null;

    final twoUp = MediaQuery.sizeOf(context).width >= Breakpoints.compact;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxContent = constraints.maxWidth.clamp(0.0, 1152.0);
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.md,
            Spacing.md,
            Spacing.lg + MediaQuery.paddingOf(context).bottom,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    title: l10n.boardGreeting(name),
                    description: workName == null
                        ? l10n.boardIntro
                        : l10n.workScopeActive(workName),
                  ),
                  if (twoUp)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _InfoCard(
                            title: l10n.boardServerTitle,
                            child: HealthStatusRow(
                              status: serverStatus,
                              message: serverMessage,
                            ),
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: account == null
                              ? const SizedBox.shrink()
                              : _AccountCard(account: account),
                        ),
                      ],
                    )
                  else ...[
                    _InfoCard(
                      title: l10n.boardServerTitle,
                      child: HealthStatusRow(
                        status: serverStatus,
                        message: serverMessage,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    if (account != null) _AccountCard(account: account),
                  ],
                  const SizedBox(height: Spacing.lg),
                  _QueueBoardCard(
                    title: l10n.boardQueueTitle,
                    body: l10n.boardQueueSoon,
                  ),
                  const SizedBox(height: Spacing.lg),
                  const Center(child: LicenseSummary()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _displayName(Account? account) {
    if (account == null) return '';
    if (account.firstName.isNotEmpty) return account.firstName;
    if (account.displayName.isNotEmpty) return account.displayName;
    return account.username;
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md + Spacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final role = switch (account.role) {
      Role.admin => l10n.roleAdmin,
      Role.receptionist => l10n.roleReceptionist,
    };

    return _InfoCard(
      title: l10n.boardAccountTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AccountRow(label: l10n.fieldRole, value: role),
          _AccountRow(label: l10n.fieldUsername, value: account.username),
          _AccountRow(label: l10n.fieldEmail, value: account.email),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueBoardCard extends StatelessWidget {
  const _QueueBoardCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: scheme.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
