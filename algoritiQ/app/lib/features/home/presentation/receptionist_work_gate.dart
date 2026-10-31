// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../core/widgets/card_page.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/tablet_session.dart';
import '../../access/domain/account.dart';
import '../../access/application/user_management_service.dart';
import '../application/receptionist_work.dart';
import 'work_scope_select_page.dart';

/// After sign-in, receptionists pick a chamber (or doctor) before the board.
class ReceptionistWorkGate extends ConsumerStatefulWidget {
  const ReceptionistWorkGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReceptionistWorkGate> createState() =>
      _ReceptionistWorkGateState();
}

class _ReceptionistWorkGateState extends ConsumerState<ReceptionistWorkGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  void _sync() {
    final work = ref.read(receptionistWorkProvider);
    // Already picked for this sign-in (widget tests seed a ready scope too).
    if (work is ReceptionistWorkReady) return;
    ref
        .read(receptionistWorkProvider.notifier)
        .syncSession(ref.read(tabletSessionProvider));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(tabletSessionProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ref.read(receptionistWorkProvider.notifier).syncSession(next);
      });
    });

    final session = ref.watch(tabletSessionProvider);
    if (session == null || session.account.role != Role.receptionist) {
      return widget.child;
    }

    final work = ref.watch(receptionistWorkProvider);
    return switch (work) {
      null || ReceptionistWorkLoading() => const Scaffold(
        body: Center(child: BrandLoader()),
      ),
      ReceptionistWorkUnassigned() => const _UnassignedScopePage(),
      ReceptionistWorkChoose(:final options, :final assignmentTarget) =>
        WorkScopeSelectPage(
          options: options,
          assignmentTarget: assignmentTarget,
          onSelected: ref.read(receptionistWorkProvider.notifier).select,
        ),
      ReceptionistWorkReady() => widget.child,
    };
  }
}

class _UnassignedScopePage extends StatelessWidget {
  const _UnassignedScopePage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return CardPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.workScopeTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.workScopeEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
