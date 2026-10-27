import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/card_page.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/readiness_controller.dart';
import '../domain/readiness_item.dart';
import 'readiness_action_button.dart';
import 'readiness_row.dart';

/// Guides the user through the Android settings that keep the local API
/// available: background running, notifications, auto-start after a restart,
/// and the screen lock. Each row explains why and opens the right page.
class ReadinessPage extends ConsumerWidget {
  const ReadinessPage({super.key, required this.report});

  final ReadinessReport report;

  static const _wideWidth = 640.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(readinessControllerProvider.notifier);

    final checks = [
      for (final item in report.items) _row(context, controller, item),
    ];
    final button = LoadingButton(
      label: l10n.continueButton,
      onPressed: report.requiredDone ? controller.acknowledge : null,
    );

    return CardPage(
      wide: true,
      child: Card(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= _wideWidth;
            final title = Text(
              l10n.readinessTitle,
              maxLines: wide ? 1 : null,
              overflow: wide ? TextOverflow.ellipsis : null,
              style: wide
                  ? theme.textTheme.titleLarge
                  : theme.textTheme.headlineSmall,
            );
            return Padding(
              padding: EdgeInsets.all(wide ? Spacing.md : Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: title),
                        const SizedBox(width: Spacing.md),
                        SizedBox(width: 180, child: button),
                      ],
                    )
                  else ...[
                    title,
                    const SizedBox(height: Spacing.sm),
                    Text(
                      l10n.readinessIntro,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  SizedBox(height: wide ? Spacing.sm : Spacing.md),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _Column(checks.sublist(0, 2))),
                        const SizedBox(width: Spacing.md),
                        Expanded(child: _Column(checks.sublist(2))),
                      ],
                    )
                  else
                    _Column(checks),
                  if (!wide) ...[const SizedBox(height: Spacing.md), button],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    ReadinessController controller,
    ReadinessItem item,
  ) {
    final l10n = AppLocalizations.of(context);

    Widget? action;
    if (!item.isDone) {
      switch (item.kind) {
        case ReadinessKind.background:
          action = ReadinessActionButton(
            tooltip: l10n.readinessAllow,
            icon: Icons.battery_charging_full_rounded,
            onPressed: controller.allowBackground,
          );
        case ReadinessKind.notifications:
          action = ReadinessActionButton(
            tooltip: l10n.readinessAllow,
            icon: Icons.notifications_outlined,
            onPressed: controller.allowNotifications,
          );
        case ReadinessKind.autoStart:
          action = ReadinessActionButton(
            tooltip: l10n.readinessOpenSettings,
            icon: Icons.settings_outlined,
            onPressed: controller.openAutoStartSettings,
          );
      }
    }

    switch (item.kind) {
      case ReadinessKind.background:
        return ReadinessRow(
          item: item,
          title: l10n.readinessBackgroundTitle,
          body: l10n.readinessBackgroundBody,
          action: action,
        );
      case ReadinessKind.notifications:
        return ReadinessRow(
          item: item,
          title: l10n.readinessNotificationsTitle,
          body: l10n.readinessNotificationsBody,
          action: action,
        );
      case ReadinessKind.autoStart:
        return ReadinessRow(
          item: item,
          title: l10n.readinessAutoStartTitle,
          body: l10n.readinessAutoStartBody,
          action: action,
        );
    }
  }
}

class _Column extends StatelessWidget {
  const _Column(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) const SizedBox(height: Spacing.sm),
          child,
        ],
      ],
    );
  }
}
