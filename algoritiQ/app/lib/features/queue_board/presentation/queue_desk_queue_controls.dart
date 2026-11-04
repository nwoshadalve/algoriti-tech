// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/board_models.dart';
import 'queue_desk_format.dart';

/// Tiles per line when the queues are laid out across a wide pane.
const _maxTilesPerLine = 4;

/// Call and Recall for every queue. [horizontalTiles] lays them out across a
/// wide pane (portrait); otherwise they are slim rows in a narrow strip
/// (landscape) that scrolls only when there are too many to fit. Nothing has a
/// fixed height, so one queue or six both fit.
class DeskQueueControls extends StatelessWidget {
  const DeskQueueControls({
    super.key,
    required this.controls,
    required this.horizontalTiles,
    required this.busyQueueId,
    required this.onCall,
    required this.onRecall,
  });

  final List<QueueTypeBoardControl> controls;
  final bool horizontalTiles;

  /// The queue whose Call is being carried out.
  final String? busyQueueId;
  final ValueChanged<String> onCall;
  final ValueChanged<String> onRecall;

  @override
  Widget build(BuildContext context) {
    if (!horizontalTiles) {
      return ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: controls.length,
        separatorBuilder: (_, _) => const SizedBox(height: Spacing.xs),
        itemBuilder: (_, i) => _QueueBox(
          control: controls[i],
          busy: controls[i].queueTypeId == busyQueueId,
          onCall: onCall,
          onRecall: onRecall,
          row: true,
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final perLine = controls.length.clamp(1, _maxTilesPerLine);
        final width =
            (constraints.maxWidth - Spacing.sm * (perLine - 1)) / perLine;
        return Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (final control in controls)
              SizedBox(
                width: width,
                child: _QueueBox(
                  control: control,
                  busy: control.queueTypeId == busyQueueId,
                  onCall: onCall,
                  onRecall: onRecall,
                  row: false,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// One queue: its name and how many wait, then Call and Recall.
class _QueueBox extends StatelessWidget {
  const _QueueBox({
    required this.control,
    required this.busy,
    required this.onCall,
    required this.onRecall,
    required this.row,
  });

  final QueueTypeBoardControl control;
  final bool busy;
  final ValueChanged<String> onCall;
  final ValueChanged<String> onRecall;

  /// Name and buttons side by side (a row) or the buttons under the name.
  final bool row;

  /// A button label that shrinks a little instead of breaking in two when the
  /// tile is narrow (three queues across a portrait screen).
  static Widget _label(String text) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, maxLines: 1, softWrap: false),
  );

  static const _size = Size(0, 36);
  static const _padding = EdgeInsets.symmetric(horizontal: Spacing.md);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final id = control.queueTypeId;
    final label = Column(
      crossAxisAlignment: row
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          queueDeskQueueName(locale, control),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          l10n.deskWaitingCount(control.waitingCount),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
    final call = FilledButton(
      onPressed: control.canCallNext && !busy ? () => onCall(id) : null,
      style: FilledButton.styleFrom(minimumSize: _size, padding: _padding),
      child: busy
          ? BrandLoader(
              color: theme.colorScheme.onPrimary,
              semanticLabel: l10n.deskWorking,
            )
          : _label(l10n.deskCallBtn),
    );
    final recall = OutlinedButton(
      onPressed: control.canRecall ? () => onRecall(id) : null,
      style: OutlinedButton.styleFrom(minimumSize: _size, padding: _padding),
      child: _label(l10n.deskRecallBtn),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(Radii.field),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs + 2,
        ),
        child: row
            ? Row(
                children: [
                  Expanded(child: label),
                  const SizedBox(width: Spacing.sm),
                  call,
                  const SizedBox(width: Spacing.xs),
                  recall,
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  label,
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      Expanded(child: call),
                      const SizedBox(width: Spacing.xs),
                      Expanded(child: recall),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
