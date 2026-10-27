import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/api_host.dart';
import '../../../api/server_controller.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../core/widgets/card_page.dart';
import '../../../l10n/app_localizations.dart';
import 'address_panel.dart';
import 'claim_code_panel.dart';

/// Shown after activation until the first admin has registered on the web
/// app. Tells whoever holds the tablet how to hand over: open the address,
/// type the code, register.
class AdminGuidePage extends ConsumerWidget {
  const AdminGuidePage({super.key});

  /// Card width from which the two-column layout is used.
  static const _wideWidth = 640.0;

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
              padding: EdgeInsets.all(wide ? Spacing.md : Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(wide: wide, server: server),
                  if (!wide) ...[
                    const SizedBox(height: Spacing.sm),
                    Text(
                      l10n.adminGuideIntro,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.md),
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
  const _Header({required this.wide, required this.server});

  final bool wide;
  final ServerState server;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final title = Text(
      l10n.adminGuideTitle,
      style: wide ? theme.textTheme.titleLarge : theme.textTheme.headlineSmall,
    );
    final chip = _StatusChip(server: server);
    if (wide) {
      return Row(
        children: [
          Expanded(child: title),
          const SizedBox(width: Spacing.md),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.server});

  final ServerState server;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (server) {
      ServerStarting() => (l10n.serverStarting, scheme.onSurfaceVariant),
      ServerRunning() => (l10n.serverRunning, scheme.onSurface),
      ServerFailed() => (l10n.serverFailed, scheme.error),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        switch (server) {
          ServerStarting() => const BrandLoader(dotSize: 6),
          ServerRunning() => Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: color,
          ),
          ServerFailed() => Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: color,
          ),
        },
        const SizedBox(width: Spacing.sm),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: color),
          ),
        ),
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
    final theme = Theme.of(context);

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

        final address = _Step(
          title: l10n.guideStepOpen,
          child: AddressPanel(
            url: url,
            nameUrl: endpoint.nameUrl,
            qrSize: wide ? 104 : 140,
          ),
        );
        final code = _Step(
          title: l10n.guideStepCode,
          child: const ClaimCodePanel(),
        );
        final note = _CertificateNote(endpoint: endpoint);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: address),
                  const SizedBox(width: Spacing.lg),
                  Expanded(flex: 4, child: code),
                ],
              )
            else ...[
              address,
              const SizedBox(height: Spacing.lg),
              code,
            ],
            const SizedBox(height: Spacing.sm),
            Text(l10n.guideStepRegister, style: theme.textTheme.titleSmall),
            const SizedBox(height: Spacing.sm),
            note,
          ],
        );
    }
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: Spacing.sm),
        child,
      ],
    );
  }
}

class _CertificateNote extends StatelessWidget {
  const _CertificateNote({required this.endpoint});

  final ApiEndpoint endpoint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.certNote, style: muted),
        const SizedBox(height: Spacing.xs),
        Text(
          '${l10n.certFingerprintLabel}: ${endpoint.fingerprint}',
          style: muted?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
