import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/card_page.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/clinic_providers.dart';
import '../domain/chamber.dart';
import '../domain/setup_outcome.dart';
import 'chamber_form.dart';
import 'chamber_quota.dart';
import 'chamber_row.dart';
import 'setup_card.dart';
import 'setup_outcome_text.dart';
import 'step_actions.dart';

/// Setup step 2: add the chambers the doctor works in, up to the license.
class ChambersPage extends ConsumerStatefulWidget {
  const ChambersPage({
    super.key,
    required this.doctorId,
    required this.chambers,
  });

  /// The doctor the new chambers belong to.
  final String doctorId;
  final List<Chamber> chambers;

  @override
  ConsumerState<ChambersPage> createState() => _ChambersPageState();
}

class _ChambersPageState extends ConsumerState<ChambersPage> {
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _phone = TextEditingController();
  Chamber? _editing;
  SetupOutcome? _problem;
  bool _busy = false;
  bool _continuing = false;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _edit(Chamber chamber) {
    setState(() {
      _editing = chamber;
      _problem = null;
      _name.text = chamber.name;
      _location.text = chamber.location ?? '';
      _phone.text = chamber.phone ?? '';
    });
  }

  void _cancelEdit() {
    setState(() {
      _editing = null;
      _problem = null;
      _name.clear();
      _location.clear();
      _phone.clear();
    });
  }

  Future<void> _submit() async {
    final actions = ref.read(clinicActionsProvider);
    final editing = _editing;
    setState(() => _busy = true);
    final outcome = editing == null
        ? await actions.addChamber(
            doctorId: widget.doctorId,
            name: _name.text,
            location: _location.text,
            phone: _phone.text,
          )
        : await actions.updateChamber(
            editing,
            name: _name.text,
            location: _location.text,
            phone: _phone.text,
          );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _problem = outcome == SetupOutcome.saved ? null : outcome;
      if (outcome == SetupOutcome.saved) {
        _editing = null;
        _name.clear();
        _location.clear();
        _phone.clear();
      }
    });
  }

  Future<void> _continue() async {
    setState(() => _continuing = true);
    final outcome = await ref.read(clinicActionsProvider).confirmChambers();
    if (!mounted) return;
    // On success the gate moves to the ready step by itself.
    setState(() {
      _continuing = false;
      _problem = outcome == SetupOutcome.saved ? null : outcome;
    });
  }

  Future<void> _back() async {
    if (_busy || _continuing) return;
    final outcome = await ref.read(clinicActionsProvider).backToProfile();
    if (!mounted) return;
    // On success the gate shows the profile step by itself.
    if (outcome != SetupOutcome.saved) setState(() => _problem = outcome);
  }

  /// "Enter …" under each required field that is blank, after a failed save.
  String? _requiredError(TextEditingController controller, String message) =>
      _problem == SetupOutcome.fieldsMissing && controller.text.trim().isEmpty
      ? message
      : null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final limit = ref.watch(chamberLimitProvider);
    final chambers = widget.chambers;
    final isFull = chambers.length >= limit;
    final problem = _problem;

    final quota = ChamberQuota(count: chambers.length, limit: limit);
    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final chamber in chambers) ...[
          ChamberRow(
            chamber: chamber,
            onEdit: _busy ? null : () => _edit(chamber),
            editTooltip: l10n.editChamberTooltip(chamber.name),
          ),
          const SizedBox(height: Spacing.sm),
        ],
      ],
    );
    final form = isFull && _editing == null
        ? Text(l10n.chamberLimitReached(limit))
        : ChamberForm(
            name: _name,
            location: _location,
            phone: _phone,
            busy: _busy,
            isEditing: _editing != null,
            nameError: _requiredError(_name, l10n.chamberNameRequired),
            locationError: _requiredError(
              _location,
              l10n.chamberAddressRequired,
            ),
            phoneError: _requiredError(_phone, l10n.chamberPhoneRequired),
            onSubmit: _submit,
            onCancel: _cancelEdit,
          );
    final message = problem == null
        ? null
        : setupOutcomeText(l10n, problem, maxChambers: limit);
    final actions = StepActions(
      onBack: _back,
      primary: LoadingButton(
        label: l10n.continueButton,
        loadingLabel: l10n.saving,
        isLoading: _continuing,
        onPressed: _continue,
      ),
    );
    final error = Text(
      message ?? '',
      style: TextStyle(color: Theme.of(context).colorScheme.error),
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
          step: 1,
          title: l10n.chambersTitle,
          intro: l10n.chambersIntro(limit),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (SetupCard.isWide(constraints.maxWidth)) {
                // Saved chambers left, the form and actions right.
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          quota,
                          const SizedBox(height: Spacing.md),
                          list,
                        ],
                      ),
                    ),
                    const SizedBox(width: Spacing.lg),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          form,
                          if (message != null) ...[
                            const SizedBox(height: Spacing.sm),
                            error,
                          ],
                          const SizedBox(height: Spacing.md),
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
                  quota,
                  const SizedBox(height: Spacing.md),
                  list,
                  form,
                  if (message != null) ...[
                    const SizedBox(height: Spacing.md),
                    error,
                  ],
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
