import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/server_controller.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/card_page.dart';
import '../../../l10n/app_localizations.dart';
import 'address_panel.dart';
import 'certificate_note.dart';
import 'claim_code_panel.dart';
import 'guide_step.dart';
import 'server_status_chip.dart';

/// Shown after activation until the first admin has registered on the web
/// app. Tells whoever holds the tablet how to hand over: open the address,
/// type the code, register. Three numbered steps; side by side on wide
/// screens (address and code in a row, the certificate note below), stacked
/// on narrow ones.
class AdminGuidePage extends ConsumerWidget {
  const AdminGuidePage({super.key});

  /// Card width from which the two-column layout is used.
  static const _wideWidth = 640.0;

  /// Card width from which the status pill sits beside the title, and the
  /// largest text scale at which there is room for both.
  static const _inlineHeaderWidth = 400.0;
  static const _inlineHeaderMaxTextScale = 1.3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final server = ref.watch(serverControllerProvider);

    return CardPage(
      wide: true,
      child: Card(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= _wideWidth;
            return Padding(
              padding: EdgeInsets.all(
                wide ? Spacing.sm + Spacing.xs : Spacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    wide: wide,
                    inline:
                        wide ||
                        (constraints.maxWidth >= _inlineHeaderWidth &&
                            MediaQuery.textScalerOf(context).scale(1) <=
                                _inlineHeaderMaxTextScale),
                    server: server,
                  ),
                  if (!wide) ...[
                    const SizedBox(height: Spacing.sm),
                    Text(
                      l10n.adminGuideIntro,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.sm),
                  _Body(wide: wide, server: server),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.wide,
    required this.inline,
    required this.server,
  });

  final bool wide;

  /// The status pill beside the title (otherwise below it).
  final bool inline;
  final ServerState server;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = Text(
      AppLocalizations.of(context).adminGuideTitle,
      // A little smaller on the narrow card, so the title and the status pill
      // share one line in English and Bengali.
      style: wide ? theme.textTheme.titleLarge : theme.textTheme.titleMedium,
    );
    final chip = ServerStatusChip(server: server);
    if (inline) {
      return Row(
        children: [
          Expanded(child: title),
          const SizedBox(width: Spacing.sm),
          chip,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: Spacing.sm),
        chip,
      ],
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.wide, required this.server});

  final bool wide;
  final ServerState server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    switch (server) {
      case ServerStarting():
        return const SizedBox(height: Spacing.xl);
      case ServerFailed():
        return Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: ref.read(serverControllerProvider.notifier).retry,
            child: Text(l10n.retryButton),
          ),
        );
      case ServerRunning(:final endpoint):
        final url = endpoint.url;
        if (url == null) return Text(l10n.serverNoNetwork);

        final address = GuideStep(
          number: 1,
          compact: true,
          title: l10n.guideStepOpen,
          child: AddressPanel(
            url: url,
            nameUrl: endpoint.nameUrl,
            sideBySide: wide,
          ),
        );
        final code = GuideStep(
          number: 2,
          compact: true,
          title: l10n.guideStepCode,
          child: const ClaimCodePanel(compact: true),
        );
        final register = GuideStep(
          number: 3,
          compact: true,
          title: l10n.guideStepRegister,
          child: CertificateNote(fingerprint: endpoint.fingerprint, wide: wide),
        );
        final gap = SizedBox(
          width: wide ? Spacing.sm + Spacing.xs : Spacing.md,
          height: Spacing.sm,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 6, child: address),
                    gap,
                    Expanded(flex: 4, child: code),
                  ],
                ),
              )
            else ...[
              address,
              gap,
              code,
            ],
            gap,
            register,
          ],
        );
    }
  }
}
