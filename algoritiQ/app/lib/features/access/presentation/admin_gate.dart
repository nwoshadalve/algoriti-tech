import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/retry_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/access_providers.dart';
import 'admin_guide_page.dart';

/// Shows [child] once an admin exists; until then the guide that explains how
/// to register one from the web app.
class AdminGate extends ConsumerWidget {
  const AdminGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admins = ref.watch(adminCountProvider);
    return admins.when(
      // Resolved before the first frame at startup; this is only a blink.
      loading: () => const Scaffold(),
      error: (_, _) => RetryView(
        message: AppLocalizations.of(context).setupLoadFailed,
        onRetry: () => ref.invalidate(adminCountProvider),
      ),
      data: (count) => count > 0 ? child : const AdminGuidePage(),
    );
  }
}
