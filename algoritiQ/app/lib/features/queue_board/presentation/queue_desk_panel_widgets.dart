// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
part of 'queue_desk_panel.dart';

/// Shown instead of the desk while no session is open.
class _SessionClosedCard extends StatelessWidget {
  const _SessionClosedCard({required this.busy, required this.onStart});

  final bool busy;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.deskSessionClosedTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.sm),
            Text(l10n.deskSessionClosedHint),
            const SizedBox(height: Spacing.md),
            LoadingButton(
              label: l10n.deskStartSession,
              isLoading: busy,
              loadingLabel: l10n.deskWorking,
              onPressed: busy ? null : onStart,
            ),
          ],
        ),
      ),
    );
  }
}
