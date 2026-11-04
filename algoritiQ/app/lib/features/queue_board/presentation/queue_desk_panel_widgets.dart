// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
part of 'queue_desk_panel.dart';

enum _DeskActionSize { portrait, landscape, standard }

ButtonStyle _deskFilledStyle(
  BuildContext context, {
  required _DeskActionSize size,
}) {
  final (minH, padH, padV, fontSize) = switch (size) {
    _DeskActionSize.portrait => (22.0, 6.0, 0.0, 9.0),
    _DeskActionSize.landscape => (28.0, 8.0, 0.0, 11.0),
    _DeskActionSize.standard => (44.0, 14.0, 8.0, 13.0),
  };
  return FilledButton.styleFrom(
    minimumSize: Size(0, minH),
    padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
    textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

ButtonStyle _deskOutlinedStyle(
  BuildContext context, {
  required _DeskActionSize size,
}) {
  final (minH, padH, padV, fontSize) = switch (size) {
    _DeskActionSize.portrait => (22.0, 6.0, 0.0, 9.0),
    _DeskActionSize.landscape => (28.0, 8.0, 0.0, 11.0),
    _DeskActionSize.standard => (44.0, 14.0, 8.0, 13.0),
  };
  return OutlinedButton.styleFrom(
    minimumSize: Size(0, minH),
    padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
    textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

ButtonStyle _deskFilledStyleLegacy(
  BuildContext context, {
  required bool compact,
}) {
  return _deskFilledStyle(
    context,
    size: compact ? _DeskActionSize.portrait : _DeskActionSize.standard,
  );
}

ButtonStyle _deskOutlinedStyleLegacy(
  BuildContext context, {
  required bool compact,
}) {
  return _deskOutlinedStyle(
    context,
    size: compact ? _DeskActionSize.portrait : _DeskActionSize.standard,
  );
}

class _DeskSectionTitle extends StatelessWidget {
  const _DeskSectionTitle(this.text, {this.compact = false});

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: compact ? 0.8 : 1.2,
        fontSize: compact ? 10 : null,
      ),
    );
  }
}

class _DeskHeadButton extends StatelessWidget {
  const _DeskHeadButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = primary ? Colors.white : scheme.onSurface;
    final bg = primary ? BrandColors.coralAction : scheme.surface;
    final iconBox = compact ? 18.0 : 28.0;
    final iconSize = compact ? 14.0 : 20.0;
    final fontSize = compact ? 9.0 : 13.0;
    final minHeight = compact ? 26.0 : 36.0;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(Radii.field),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(Radii.field),
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: EdgeInsets.fromLTRB(
            compact ? 6 : 10,
            compact ? 4 : 6,
            compact ? 8 : 14,
            compact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.field),
            border: Border.all(
              color: primary ? Colors.transparent : scheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: primary
                      ? Colors.white.withValues(alpha: 0.22)
                      : scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: iconSize, color: fg),
              ),
              SizedBox(width: compact ? 4 : 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _LeftColumn extends StatelessWidget {
  const _LeftColumn({
    required this.compact,
    required this.queuesInRow,
    required this.landscapeDesk,
    required this.snapshot,
    required this.busy,
    required this.busyQueueId,
    required this.onCallNext,
    required this.onRecall,
    required this.onEntered,
    required this.onSkipped,
  });

  final bool compact;
  final bool queuesInRow;
  final bool landscapeDesk;
  final BoardSnapshot snapshot;
  final bool busy;
  final String? busyQueueId;
  final ValueChanged<String> onCallNext;
  final ValueChanged<String> onRecall;
  final ValueChanged<String> onEntered;
  final ValueChanged<String> onSkipped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pad = (compact || queuesInRow) ? Spacing.sm : Spacing.md;
    final queueTitle = _DeskSectionTitle(
      l10n.deskQueueControlsTitle,
      compact: compact || queuesInRow,
    );
    final blockedBanner = snapshot.calledToken != null
        ? Padding(
            padding: EdgeInsets.only(top: compact ? Spacing.xs : Spacing.sm),
            child: Text(
              l10n.deskCallBlocked(
                queueDeskFormatSerial(
                  snapshot.calledToken!.serial,
                  Localizations.localeOf(context),
                ),
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: compact ? 10 : null,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          )
        : null;

    Widget queueList({required bool scrollable}) {
      final rows = <Widget>[
        for (var i = 0; i < snapshot.queueControls.length; i++) ...[
          if (i > 0)
            SizedBox(
              height: landscapeDesk ? Spacing.sm : (compact ? 6 : Spacing.sm),
            ),
          _QueueControlRow(
            landscapeDesk: landscapeDesk,
            control: snapshot.queueControls[i],
            busy: busy,
            loading: busyQueueId == snapshot.queueControls[i].queueTypeId,
            onCallNext: () => onCallNext(snapshot.queueControls[i].queueTypeId),
            onRecall: () => onRecall(snapshot.queueControls[i].queueTypeId),
          ),
        ],
      ];
      final column = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: rows,
      );
      if (!scrollable) return column;
      return SingleChildScrollView(child: column);
    }

    final queuesCardColumns = Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: Spacing.sm,
              ),
              child: _DeskSectionTitle(
                l10n.deskQueueControlsTitle,
                compact: true,
              ),
            ),
            if (blockedBanner != null) blockedBanner,
            SizedBox(height: compact ? Spacing.xs : Spacing.sm),
            _QueueControlsRow(
              controls: snapshot.queueControls,
              busy: busy,
              busyQueueId: busyQueueId,
              onCallNext: onCallNext,
              onRecall: onRecall,
            ),
          ],
        ),
      ),
    );

    if (landscapeDesk && !queuesInRow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CurrentCallCard(
            compact: true,
            called: snapshot.calledToken,
            onEntered: onEntered,
            onSkipped: onSkipped,
            busy: busy,
          ),
          const SizedBox(height: Spacing.sm),
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.sm,
                  Spacing.md,
                  Spacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xs,
                        vertical: Spacing.sm,
                      ),
                      child: _DeskSectionTitle(
                        l10n.deskQueueControlsTitle,
                        compact: false,
                      ),
                    ),
                    if (blockedBanner != null) blockedBanner,
                    const SizedBox(height: Spacing.sm),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            vertical: Spacing.sm,
                          ),
                          child: queueList(scrollable: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (queuesInRow) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CurrentCallCard(
            compact: true,
            called: snapshot.calledToken,
            onEntered: onEntered,
            onSkipped: onSkipped,
            busy: busy,
          ),
          const SizedBox(height: Spacing.xs),
          queuesCardColumns,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CurrentCallCard(
          compact: compact,
          called: snapshot.calledToken,
          onEntered: onEntered,
          onSkipped: onSkipped,
          busy: busy,
        ),
        SizedBox(height: compact ? Spacing.xs : Spacing.sm),
        Expanded(
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  queueTitle,
                  if (blockedBanner != null) blockedBanner,
                  SizedBox(height: compact ? Spacing.xs : Spacing.sm),
                  Expanded(child: queueList(scrollable: true)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrentCallCard extends StatelessWidget {
  const _CurrentCallCard({
    required this.compact,
    required this.called,
    required this.onEntered,
    required this.onSkipped,
    required this.busy,
  });

  final bool compact;
  final BoardTokenView? called;
  final ValueChanged<String> onEntered;
  final ValueChanged<String> onSkipped;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final pad = compact ? Spacing.sm : Spacing.md;
    if (called == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: pad,
            vertical: compact ? Spacing.sm : Spacing.lg,
          ),
          child: Center(
            child: Text(
              l10n.deskCurrentCallEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: compact ? 11 : 14),
            ),
          ),
        ),
      );
    }
    final metaStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(fontSize: compact ? 11 : null);
    return Card(
      color: BrandColors.coralAction.withValues(alpha: 0.08),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DeskSectionTitle(l10n.deskCurrentCallTitle, compact: compact),
            SizedBox(height: compact ? Spacing.xs : Spacing.sm),
            Text(
              queueDeskFormatSerial(called!.serial, locale),
              style:
                  (compact
                          ? Theme.of(context).textTheme.headlineMedium
                          : Theme.of(context).textTheme.displaySmall)
                      ?.copyWith(
                        color: BrandColors.coralAction,
                        fontWeight: FontWeight.w700,
                      ),
            ),
            Text(called!.patientBengaliName, style: metaStyle),
            Text(called!.clinicPatientId, style: metaStyle),
            Text(queueDeskQueueNameForToken(locale, called!), style: metaStyle),
            SizedBox(height: compact ? Spacing.xs : Spacing.sm),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                FilledButton(
                  style: _deskFilledStyleLegacy(context, compact: compact),
                  onPressed: busy ? null : () => onEntered(called!.id),
                  child: Text(l10n.deskPatientEntered),
                ),
                OutlinedButton(
                  style: _deskOutlinedStyleLegacy(context, compact: compact),
                  onPressed: busy ? null : () => onSkipped(called!.id),
                  child: Text(l10n.deskPatientMissed),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueControlsRow extends StatelessWidget {
  const _QueueControlsRow({
    required this.controls,
    required this.busy,
    required this.busyQueueId,
    required this.onCallNext,
    required this.onRecall,
  });

  final List<QueueTypeBoardControl> controls;
  final bool busy;
  final String? busyQueueId;
  final ValueChanged<String> onCallNext;
  final ValueChanged<String> onRecall;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < controls.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: _QueueControlTile(
              control: controls[i],
              busy: busy,
              loading: busyQueueId == controls[i].queueTypeId,
              onCallNext: () => onCallNext(controls[i].queueTypeId),
              onRecall: () => onRecall(controls[i].queueTypeId),
            ),
          ),
        ],
      ],
    );
  }
}

class _QueueControlTile extends StatelessWidget {
  const _QueueControlTile({
    required this.control,
    required this.busy,
    required this.loading,
    required this.onCallNext,
    required this.onRecall,
  });

  final QueueTypeBoardControl control;
  final bool busy;
  final bool loading;
  final VoidCallback onCallNext;
  final VoidCallback onRecall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final name = queueDeskQueueName(locale, control);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(Radii.field),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.deskWaitingCount(control.waitingCount),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: _deskFilledStyle(context, size: _DeskActionSize.landscape),
            onPressed: !control.canCallNext || busy || loading
                ? null
                : onCallNext,
            child: loading && busy
                ? const Text('…', style: TextStyle(fontSize: 11))
                : Text(l10n.deskCallBtn),
          ),
          const SizedBox(height: 4),
          OutlinedButton(
            style: _deskOutlinedStyle(context, size: _DeskActionSize.landscape),
            onPressed: !control.canRecall || busy || loading ? null : onRecall,
            child: Text(l10n.deskRecallBtn),
          ),
        ],
      ),
    );
  }
}

/// Portrait queue row (mock: label left, small stacked actions right).
class _QueueControlRow extends StatelessWidget {
  const _QueueControlRow({
    required this.landscapeDesk,
    required this.control,
    required this.busy,
    required this.loading,
    required this.onCallNext,
    required this.onRecall,
  });

  final bool landscapeDesk;
  final QueueTypeBoardControl control;
  final bool busy;
  final bool loading;
  final VoidCallback onCallNext;
  final VoidCallback onRecall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final name = queueDeskQueueName(locale, control);
    final scheme = Theme.of(context).colorScheme;

    const actionWidth = 76.0;
    final actionSize = _DeskActionSize.landscape;

    final callBtn = SizedBox(
      width: actionWidth,
      child: FilledButton(
        style: _deskFilledStyle(context, size: actionSize),
        onPressed: !control.canCallNext || busy || loading ? null : onCallNext,
        child: loading && busy
            ? const Text('…', style: TextStyle(fontSize: 11))
            : Text(
                l10n.deskCallBtn,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
    final recallBtn = SizedBox(
      width: actionWidth,
      child: OutlinedButton(
        style: _deskOutlinedStyle(context, size: actionSize),
        onPressed: !control.canRecall || busy || loading ? null : onRecall,
        child: Text(
          l10n.deskRecallBtn,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: landscapeDesk ? Spacing.md : 6,
        vertical: landscapeDesk ? Spacing.md : 4,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(Radii.field),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: landscapeDesk ? Spacing.md : 6,
                left: landscapeDesk ? Spacing.xs : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    maxLines: landscapeDesk ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: landscapeDesk ? 13 : 12,
                    ),
                  ),
                  SizedBox(height: landscapeDesk ? 4 : 0),
                  Text(
                    l10n.deskWaitingCount(control.waitingCount),
                    style: TextStyle(
                      fontSize: landscapeDesk ? 11 : 10,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              callBtn,
              SizedBox(height: landscapeDesk ? 4 : 3),
              recallBtn,
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionTableCard extends StatelessWidget {
  const _SessionTableCard({
    required this.compact,
    required this.landscapeDesk,
    required this.portraitDesk,
    required this.snapshot,
    required this.onAddNew,
    required this.onAddExisting,
  });

  final bool compact;
  final bool landscapeDesk;
  final bool portraitDesk;
  final BoardSnapshot snapshot;
  final VoidCallback onAddNew;
  final VoidCallback onAddExisting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();
    final deskHeader = landscapeDesk || portraitDesk;
    final header = deskHeader
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs,
                    vertical: Spacing.sm,
                  ),
                  child: _DeskSectionTitle(
                    l10n.deskSessionTableTitle,
                    compact: portraitDesk,
                  ),
                ),
              ),
              _DeskHeadButton(
                compact: true,
                primary: true,
                icon: Icons.person_add_outlined,
                label: l10n.deskAddPatientShort,
                onPressed: onAddNew,
              ),
              const SizedBox(width: Spacing.xs),
              _DeskHeadButton(
                compact: true,
                icon: Icons.person_outline,
                label: l10n.deskAddExistingShort,
                onPressed: onAddExisting,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DeskSectionTitle(l10n.deskSessionTableTitle, compact: true),
              const SizedBox(height: Spacing.xs),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                alignment: WrapAlignment.end,
                children: [
                  _DeskHeadButton(
                    compact: true,
                    primary: true,
                    icon: Icons.person_add_outlined,
                    label: l10n.deskAddPatientShort,
                    onPressed: onAddNew,
                  ),
                  _DeskHeadButton(
                    compact: true,
                    icon: Icons.person_outline,
                    label: l10n.deskAddExistingShort,
                    onPressed: onAddExisting,
                  ),
                ],
              ),
            ],
          );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: deskHeader ? Spacing.md : Spacing.sm,
                vertical: deskHeader ? Spacing.md : Spacing.xs,
              ),
              child: header,
            ),
            const Divider(height: 1),
            Expanded(
              child: snapshot.tokens.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(
                          landscapeDesk ? Spacing.lg : Spacing.md,
                        ),
                        child: Text(
                          l10n.deskSessionEmpty,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: landscapeDesk ? 14 : (compact ? 12 : 14),
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: landscapeDesk ? Spacing.md : 0,
                        vertical: landscapeDesk
                            ? Spacing.sm
                            : (compact ? Spacing.xs : Spacing.sm),
                      ),
                      itemCount: snapshot.tokens.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final row = snapshot.tokens[index];
                        return _DeskSessionTokenRow(
                          compact: compact,
                          landscapeDesk: landscapeDesk,
                          row: row,
                          locale: locale,
                          now: now,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeskSessionTokenRow extends StatelessWidget {
  const _DeskSessionTokenRow({
    required this.compact,
    required this.landscapeDesk,
    required this.row,
    required this.locale,
    required this.now,
  });

  final bool compact;
  final bool landscapeDesk;
  final BoardTokenView row;
  final Locale locale;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final waiting = queueDeskWaitingMinutes(
      row.issuedAt.toLocal(),
      now,
      locale,
    );
    final serialStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: compact ? 13 : 15,
    );
    final metaStyle = TextStyle(
      fontSize: compact ? 11 : 13,
      color: scheme.onSurfaceVariant,
    );
    final waitStyle = TextStyle(
      fontSize: compact ? 10 : 12,
      color: scheme.onSurfaceVariant,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: landscapeDesk
            ? Spacing.xs
            : (compact ? Spacing.sm : Spacing.md),
        vertical: landscapeDesk ? Spacing.sm : (compact ? 6 : Spacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  queueDeskFormatSerial(row.serial, locale),
                  style: serialStyle,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Text(waiting, style: waitStyle),
            ],
          ),
          SizedBox(height: compact ? 2 : Spacing.xs),
          Text(
            '${row.patientBengaliName} · ${row.clinicPatientId}',
            style: metaStyle,
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
