// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/toast/toast_controller.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/tablet_session.dart';
import '../application/patient_drafts.dart';
import '../application/queue_board_providers.dart';
import '../application/queue_board_service.dart';
import '../domain/board_models.dart';
import 'patient_draft_notice.dart';
import 'queue_desk_dialog_layout.dart';
import 'queue_desk_fee_field.dart';
import 'queue_desk_errors.dart';
import 'queue_desk_format.dart';
import 'queue_desk_patient_fields.dart';

/// Edit a patient's name, phone, age and gender. When it is opened for a
/// [token] of the open session, the fee on that token can be edited too.
/// Answers with the saved patient, or null when closed without saving.
Future<PatientSummary?> showDeskPatientEditDialog({
  required BuildContext context,
  required PatientSummary patient,
  BoardTokenView? token,
}) {
  return showDialog<PatientSummary>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PatientEditDialog(patient: patient, token: token),
  );
}

class _PatientEditDialog extends ConsumerStatefulWidget {
  const _PatientEditDialog({required this.patient, this.token});

  final PatientSummary patient;
  final BoardTokenView? token;

  @override
  ConsumerState<_PatientEditDialog> createState() => _PatientEditDialogState();
}

class _PatientEditDialogState extends ConsumerState<_PatientEditDialog> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _age;
  late final TextEditingController _fee;
  PatientGender? _gender;
  var _isFree = false;
  var _busy = false;
  var _submitted = false;
  var _restored = false;
  late final PatientDraftSync _draft;

  PatientDraft _snapshot() => PatientDraft(
    name: _name.text,
    phone: _phone.text,
    age: _age.text,
    gender: _gender,
    fee: _fee.text,
    isFree: _isFree,
  );

  void _apply(PatientDraft d) {
    _name.text = d.name;
    _phone.text = d.phone;
    _age.text = d.age;
    _fee.text = d.fee;
    _gender = d.gender;
    _isFree = d.isFree;
  }

  void _changed() {
    _draft.persist();
    if (mounted) setState(() {});
  }

  void _discardDraft() {
    setState(() {
      _apply(_draft.baseline);
      _restored = false;
      _submitted = false;
    });
    _draft.discard();
  }

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _name = TextEditingController(text: p.name);
    _phone = TextEditingController(
      text: queueDeskDisplayPhone(p.phoneNormalized),
    );
    _age = TextEditingController(
      text: (p.ageLabel ?? '').replaceAll(RegExp('[^0-9]'), ''),
    );
    _fee = TextEditingController(text: widget.token?.feeBdt?.toString() ?? '');
    _isFree = widget.token?.isFree ?? false;
    _gender = p.gender;
    _draft = PatientDraftSync(
      store: ref.read(patientDraftsProvider.notifier),
      key: 'edit:${p.id}',
      baseline: _snapshot(),
      snapshot: _snapshot,
    );
    final saved = _draft.restore();
    if (saved != null) {
      _apply(saved);
      _restored = true;
    }
    for (final c in [_name, _phone, _age, _fee]) {
      c.addListener(_changed);
    }
    for (final c in [_name, _phone]) {
      c.addListener(() {
        if (_submitted && mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _age, _fee]) {
      c.dispose();
    }
    super.dispose();
  }

  /// A fee that is typed but is not a whole number.
  bool get _feeInvalid =>
      widget.token != null &&
      !_isFree &&
      _fee.text.trim().isNotEmpty &&
      queueDeskParseNumber(_fee.text) == null;

  Future<void> _save() async {
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null || _busy) return;
    final l10n = AppLocalizations.of(context);
    final toast = ref.read(toastControllerProvider.notifier);
    setState(() => _submitted = true);
    if (_name.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _feeInvalid) {
      toast.error(l10n.deskErrorValidation);
      return;
    }
    setState(() => _busy = true);
    try {
      final saved = await ref
          .read(queueBoardServiceProvider)
          .updatePatient(
            account,
            widget.patient.id,
            PatientInput(
              name: _name.text.trim(),
              phone: _phone.text.trim(),
              gender: _gender,
              approximateAgeYears: queueDeskParseNumber(_age.text),
            ),
            // Only when opened for a token: an empty fee clears it.
            fee: widget.token == null
                ? null
                : TokenFeeChange(
                    tokenId: widget.token!.id,
                    feeBdt: _isFree ? null : queueDeskParseNumber(_fee.text),
                    isFree: _isFree,
                  ),
          );
      toast.success(l10n.deskPatientUpdated);
      _draft.discard();
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } on QueueBoardRefused catch (e) {
      toast.error(queueDeskErrorMessage(l10n, e));
    } on Object {
      toast.error(l10n.deskErrorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DeskFormDialog(
      title: l10n.deskEditPatientTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PatientDraftNotice(
            visible: !_draft.snapshot().sameAs(_draft.baseline),
            restored: _restored,
            onDiscard: _discardDraft,
            enabled: !_busy,
          ),
          DeskPatientFields(
            name: _name,
            phone: _phone,
            age: _age,
            gender: _gender,
            onGender: (v) {
              setState(() => _gender = v);
              _changed();
            },
            enabled: !_busy,
            showErrors: _submitted,
          ),
          // The fee belongs to the visit, so it can be changed only while the
          // patient is in the open session.
          if (widget.token != null) ...[
            deskFormFieldSpacer(),
            DeskFeeField(
              controller: _fee,
              enabled: !_busy,
              errorText: _submitted && _feeInvalid
                  ? l10n.deskFieldRequired
                  : null,
              free: _isFree,
              onFreeChanged: (on) {
                setState(() => _isFree = on);
                _changed();
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelEditButton),
        ),
        LoadingButton(
          label: l10n.deskEditPatientSave,
          isLoading: _busy,
          loadingLabel: l10n.deskWorking,
          onPressed: _busy ? null : () => unawaited(_save()),
        ),
      ],
    );
  }
}
