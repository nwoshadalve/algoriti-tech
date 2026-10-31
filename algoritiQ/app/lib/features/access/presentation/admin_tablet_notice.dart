// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/server_controller.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/card_page.dart';
import '../../../l10n/app_localizations.dart';
import '../application/tablet_session.dart';
import 'address_panel.dart';

/// Shown to an admin who signs in on the tablet: the tablet only has the
/// receptionist screen for now, so the admin is pointed to the web app. OK
/// signs out, which brings the sign-in screen back (closing the app does the
/// same).
class AdminTabletNotice extends ConsumerWidget {
  const AdminTabletNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final server = ref.watch(serverControllerProvider);
    final wide = CardPage.isTwoColumn(context);
    final endpoint = server is ServerRunning ? server.endpoint : null;
    final url = endpoint?.url;

    return CardPage(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(wide ? Spacing.md : Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.adminNoticeTitle, style: theme.textTheme.headlineSmall),
              const SizedBox(height: Spacing.sm),
              Text(l10n.adminNoticeBody, style: theme.textTheme.bodyMedium),
              if (url != null) ...[
                const SizedBox(height: Spacing.md),
                AddressPanel(
                  url: url,
                  nameUrl: endpoint?.nameUrl,
                  sideBySide: wide,
                ),
              ],
              const SizedBox(height: Spacing.md),
              Text(
                l10n.adminNoticeSignOut,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: ref.read(tabletSessionProvider.notifier).signOut,
                child: Text(l10n.adminNoticeOk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
