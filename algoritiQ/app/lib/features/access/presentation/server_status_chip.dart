import 'package:flutter/material.dart';

import '../../../api/server_controller.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../l10n/app_localizations.dart';

/// "Server running" as a small pill: a coloured dot and a label (the label
/// carries the meaning, the colour only helps).
class ServerStatusChip extends StatelessWidget {
  const ServerStatusChip({super.key, required this.server});

  final ServerState server;

  static const _dotSize = 10.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = switch (server) {
      ServerStarting() => l10n.serverStarting,
      ServerRunning() => l10n.serverRunning,
      ServerFailed() => l10n.serverFailed,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(Spacing.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm + Spacing.xs,
          vertical: Spacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (server) {
              ServerStarting() => const BrandLoader(dotSize: 6),
              ServerRunning() => const _Dot(color: BrandColors.positive),
              ServerFailed() => Icon(
                Icons.error_outline_rounded,
                size: _dotSize + 8,
                color: scheme.error,
              ),
            },
            const SizedBox(width: Spacing.sm),
            Flexible(child: Text(label, style: theme.textTheme.labelLarge)),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: ServerStatusChip._dotSize,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
