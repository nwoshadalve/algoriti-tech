import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/tablet_session.dart';

/// Ends the tablet's sign-in; the sign-in screen comes back.
class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: ref.read(tabletSessionProvider.notifier).signOut,
      tooltip: AppLocalizations.of(context).signOutTooltip,
      icon: const Icon(Icons.logout_rounded),
    );
  }
}
