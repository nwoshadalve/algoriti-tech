import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/card_page.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/clinic_providers.dart';
import '../domain/chamber.dart';
import '../domain/doctor.dart';
import '../domain/setup_outcome.dart';
import 'chamber_row.dart';
import 'doctor_summary.dart';
import 'setup_card.dart';
import 'step_actions.dart';

/// Setup step 3: a summary, then on to the app.
class ReadyPage extends ConsumerStatefulWidget {
  const ReadyPage({super.key, required this.doctor, required this.chambers});

  final Doctor? doctor;
  final List<Chamber> chambers;

  @override
  ConsumerState<ReadyPage> createState() => _ReadyPageState();
}

class _ReadyPageState extends ConsumerState<ReadyPage> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _start() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    final outcome = await ref.read(clinicActionsProvider).finish();
    if (!mounted) return;
    // On success the gate opens the app by itself.
    setState(() {
      _busy = false;
      _failed = outcome != SetupOutcome.saved;
    });
  }

  Future<void> _back() async {
    if (_busy) return;
    final outcome = await ref.read(clinicActionsProvider).backToChambers();
    if (!mounted) return;
    // On success the gate shows the chambers step by itself.
    if (outcome != SetupOutcome.saved) setState(() => _failed = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = Theme.of(context).colorScheme.error;
    final doctor = widget.doctor;

    final summary = doctor == null ? null : DoctorSummary(doctor: doctor);
    final compactSummary = doctor == null
        ? null
        : DoctorSummary(doctor: doctor, compact: true);
    final chambers = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final chamber in widget.chambers) ...[
          ChamberRow(chamber: chamber),
          const SizedBox(height: Spacing.sm),
        ],
      ],
    );
    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_failed) ...[
          Text(l10n.setupSaveFailed, style: TextStyle(color: error)),
          const SizedBox(height: Spacing.sm),
        ],
        StepActions(
          onBack: _back,
          primary: LoadingButton(
            label: l10n.startButton,
            loadingLabel: l10n.saving,
            isLoading: _busy,
            onPressed: _start,
          ),
        ),
      ],
    );

    // The system back gesture goes to the previous step instead of leaving.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: CardPage(
        wide: true,
        child: SetupCard(
          step: 3,
          title: l10n.readyTitle,
          intro: l10n.readyIntro,
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (SetupCard.isWide(constraints.maxWidth)) {
                // The doctor card left; chambers and the actions right.
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: compactSummary ?? const SizedBox.shrink(),
                    ),
                    const SizedBox(width: Spacing.lg),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          chambers,
                          const SizedBox(height: Spacing.sm),
                          actions,
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ?summary,
                  const SizedBox(height: Spacing.md),
                  chambers,
                  const SizedBox(height: Spacing.lg),
                  actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
