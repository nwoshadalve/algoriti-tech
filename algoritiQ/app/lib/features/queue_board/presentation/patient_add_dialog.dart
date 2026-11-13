// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/id_generator.dart';
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
import 'queue_desk_errors.dart';
import 'queue_desk_format.dart';
import 'queue_desk_patient_fields.dart';

/// Adds a patient from the patient list, without a token. Answers with the
/// saved patient, or null when closed without saving (what was typed stays as
/// a draft).
Future<PatientSummary?> showPatientAddDialog({
  required BuildContext context,
  required String chamberId,
}) {
  return showDialog<PatientSummary>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PatientAddDialog(chamberId: chamberId),
  );
}

class _PatientAddDialog extends ConsumerStatefulWidget {
  const _PatientAddDialog({required this.chamberId});

  final String chamberId;

  @override
  ConsumerState<_PatientAddDialog> createState() => _PatientAddDialogState();
}

class _PatientAddDialogState extends ConsumerState<_PatientAddDialog> {
  static const draftKey = 'page-new';

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _age = TextEditingController();
  PatientGender? _gender;
  var _hasPaperFile = false;
  var _busy = false;
  var _submitted = false;
  var _duplicateConfirm = false;
  var _restored = false;
  late final PatientDraftSync _draft;

  PatientDraft _snapshot() => PatientDraft(
    name: _name.text,
    phone: _phone.text,
    age: _age.text,
    gender: _gender,
    hasPaperFile: _hasPaperFile,
  );

  void _apply(PatientDraft d) {
    _name.text = d.name;
    _phone.text = d.phone;
    _age.text = d.age;
    _gender = d.gender;
    _hasPaperFile = d.hasPaperFile;
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
      _duplicateConfirm = false;
    });
    _draft.discard();
  }

  @override
  void initState() {
    super.initState();
    _draft = PatientDraftSync(
      store: ref.read(patientDraftsProvider.notifier),
      key: draftKey,
      baseline: _snapshot(),
      snapshot: _snapshot,
    );
    final saved = _draft.restore();
    if (saved != null) {
      _apply(saved);
      _restored = true;
    }
    for (final c in [_name, _phone, _age]) {
      c.addListener(_changed);
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _age]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null || _busy) return;
    final l10n = AppLocalizations.of(context);
    final toast = ref.read(toastControllerProvider.notifier);
    setState(() => _submitted = true);
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      toast.error(l10n.deskErrorValidation);
      return;
    }
    setState(() => _busy = true);
    try {
      final saved = await ref
          .read(queueBoardServiceProvider)
          .registerPatient(
            account,
            PatientInput(
              name: _name.text.trim(),
              phone: _phone.text.trim(),
              gender: _gender,
              approximateAgeYears: queueDeskParseNumber(_age.text),
              hasPaperFile: _hasPaperFile,
              confirmDuplicatePhone: _duplicateConfirm,
            ),
            chamberId: widget.chamberId,
            commandId: ref.read(idGeneratorProvider)(),
          );
      toast.success(l10n.patientsSaved);
      _draft.discard();
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } on QueueBoardRefused catch (e) {
      if (e.problem == QueueBoardProblem.duplicatePhoneNeedsConfirm) {
        setState(() => _duplicateConfirm = true);
      }
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
      title: l10n.patientsAddTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PatientDraftNotice(
            visible: !_draft.snapshot().sameAs(_draft.baseline),
            restored: _restored,
            onDiscard: _discardDraft,
            enabled: !_busy,
          ),
          if (_duplicateConfirm)
            Padding(
              padding: const EdgeInsets.only(bottom: deskFormFieldGap),
              child: Text(
                l10n.deskDuplicatePhoneConfirm,
                style: deskFormBodyStyle(context),
              ),
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
          CheckboxListTile(
            value: _hasPaperFile,
            onChanged: _busy
                ? null
                : (v) {
                    setState(() => _hasPaperFile = v ?? false);
                    _changed();
                  },
            title: Text(
              l10n.deskFieldPaperFile,
              style: deskFormBodyStyle(context),
            ),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancelEditButton),
        ),
        LoadingButton(
          label: _duplicateConfirm
              ? l10n.deskRegisterSave
              : l10n.patientsAddSave,
          isLoading: _busy,
          loadingLabel: l10n.deskWorking,
          onPressed: _busy ? null : () => unawaited(_save()),
        ),
      ],
    );
  }
}
