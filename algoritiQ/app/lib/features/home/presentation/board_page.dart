// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/tablet_session.dart';
import '../../access/domain/account.dart';
import '../application/receptionist_work.dart';
import '../../queue_board/presentation/queue_desk_panel.dart';
import '../../queue_board/presentation/queue_desk_session_open.dart';

/// Receptionist queue desk (native counter UI from mock screen 10).
class BoardPage extends ConsumerWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(tabletSessionProvider);
    final account = session?.account;
    final work = ref.watch(receptionistWorkProvider);
    final sessionOpen = ref.watch(queueDeskSessionOpenProvider);

    final pad = EdgeInsets.fromLTRB(
      Spacing.md,
      sessionOpen ? Spacing.xs : Spacing.md,
      Spacing.md,
      Spacing.xs + MediaQuery.paddingOf(context).bottom,
    );

    if (work is! ReceptionistWorkReady) {
      return SingleChildScrollView(
        padding: pad,
        child: switch (work) {
          ReceptionistWorkUnassigned() => Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Text(l10n.workScopeEmpty),
            ),
          ),
          ReceptionistWorkChoose() => Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Text(l10n.workScopeIntroChamber),
            ),
          ),
          _ => const Center(child: BrandLoader(semanticLabel: '')),
        },
      );
    }

    final name = _displayName(account);
    final description = l10n.workScopeActive(work.selected.name);

    return Padding(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!sessionOpen) ...[
            PageHeader(
              title: l10n.boardGreeting(name),
              description: description,
            ),
            const SizedBox(height: Spacing.md),
          ],
          Expanded(
            child: QueueDeskPanel(
              key: ValueKey(work.selected.id),
              chamberId: work.selected.id,
            ),
          ),
        ],
      ),
    );
  }

  static String _displayName(Account? account) {
    if (account == null) return '';
    if (account.firstName.isNotEmpty) return account.firstName;
    if (account.displayName.isNotEmpty) return account.displayName;
    return account.username;
  }
}
