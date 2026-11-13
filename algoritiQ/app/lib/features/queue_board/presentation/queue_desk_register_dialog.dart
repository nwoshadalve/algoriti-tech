// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'queue_desk_format.dart';

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
import 'queue_desk_fee_field.dart';
import 'queue_desk_errors.dart';
import 'queue_desk_patient_fields.dart';
import 'queue_desk_queue_picker.dart';

/// New patient popup. Saving puts the patient straight into today's session
/// with a token, whether or not the slip prints; the issued token is the
/// popup's result.
Future<IssuedTokenResult?> showDeskRegisterDialog({
  required BuildContext context,
  required String chamberId,
  required List<QueueTypeBoardControl> queueControls,
  String initialPhone = '',
  String initialName = '',
}) {
  return showDialog<IssuedTokenResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _RegisterDeskDialog(
      chamberId: chamberId,
      queueControls: queueControls,
      initialPhone: initialPhone,
      initialName: initialName,
    ),
  );
}

class _RegisterDeskDialog extends ConsumerStatefulWidget {
  const _RegisterDeskDialog({
    required this.chamberId,
    required this.queueControls,
    required this.initialPhone,
    required this.initialName,
  });

  final String chamberId;
  final List<QueueTypeBoardControl> queueControls;
  final String initialPhone;
  final String initialName;

  @override
  ConsumerState<_RegisterDeskDialog> createState() =>
      _RegisterDeskDialogState();
}

class _RegisterDeskDialogState extends ConsumerState<_RegisterDeskDialog> {
  final _name = TextEditingController();
  late final TextEditingController _phone;
  final _age = TextEditingController();
  final _fee = TextEditingController();
  PatientGender? _gender;
  String? _queueTypeId;
  var _hasPaperFile = false;
  var _isFree = false;
  var _busy = false;
  var _duplicateConfirm = false;
  var _submitted = false;
  var _restored = false;
  late final PatientDraftSync _draft;

  PatientDraft _snapshot() => PatientDraft(
    name: _name.text,
    phone: _phone.text,
    age: _age.text,
    gender: _gender,
    hasPaperFile: _hasPaperFile,
    queueTypeId: _queueTypeId,
    fee: _fee.text,
    isFree: _isFree,
  );

  void _apply(PatientDraft d) {
    _name.text = d.name;
    _phone.text = d.phone;
    _age.text = d.age;
    _fee.text = d.fee;
    _isFree = d.isFree;
    _gender = d.gender;
    _hasPaperFile = d.hasPaperFile;
    _queueTypeId = d.queueTypeId;
  }

  void _changed() {
    _draft.persist();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: widget.initialPhone);
    _name.text = widget.initialName;
    if (widget.queueControls.length == 1) {
      _queueTypeId = widget.queueControls.first.queueTypeId;
    }
    for (final c in [_name, _phone]) {
      c.addListener(_clearErrorsAsTyped);
    }
    _draft = PatientDraftSync(
      store: ref.read(patientDraftsProvider.notifier),
      key: 'desk-new:${widget.chamberId}',
      baseline: _snapshot(),
      snapshot: _snapshot,
    );
    // A draft comes back unless the desk opened this form for a typed search.
    final saved = _draft.restore();
    if (saved != null &&
        widget.initialPhone.isEmpty &&
        widget.initialName.isEmpty) {
      _apply(saved);
      _restored = true;
    }
    for (final c in [_name, _phone, _age, _fee]) {
      c.addListener(_changed);
    }
  }

  void _discardDraft() {
    final base = _draft.baseline;
    setState(() {
      _apply(base);
      _restored = false;
      _submitted = false;
    });
    _draft.discard();
  }

  /// Once errors are showing, they follow what the receptionist types.
  void _clearErrorsAsTyped() {
    if (_submitted && mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _age, _fee]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      _phone.text.trim().isNotEmpty &&
      _queueTypeId != null;

  Future<void> _submit() async {
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null || _busy) return;
    final l10n = AppLocalizations.of(context);
    final toast = ref.read(toastControllerProvider.notifier);
    setState(() => _submitted = true);
    if (!_valid) {
      toast.error(l10n.deskErrorValidation);
      return;
    }
    setState(() => _busy = true);
    final newId = ref.read(idGeneratorProvider);
    try {
      final issued = await ref
          .read(queueBoardServiceProvider)
          .registerAndIssue(
            account,
            PatientInput(
              name: _name.text.trim(),
              phone: _phone.text.trim(),
              gender: _gender,
              approximateAgeYears: queueDeskParseNumber(_age.text),
              hasPaperFile: _hasPaperFile,
              confirmDuplicatePhone: _duplicateConfirm,
            ),
            _queueTypeId!,
            chamberId: widget.chamberId,
            commandId: newId(),
            feeBdt: _isFree ? null : queueDeskParseNumber(_fee.text),
            isFree: _isFree,
          );
      _draft.discard();
      if (!mounted) return;
      Navigator.of(context).pop(issued);
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
      title: l10n.deskRegisterTitle,
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
          deskFormFieldSpacer(),
          DeskQueuePicker(
            controls: widget.queueControls,
            selectedId: _queueTypeId,
            enabled: !_busy,
            onSelected: (id) {
              setState(() => _queueTypeId = id);
              _changed();
            },
            errorText: _submitted && _queueTypeId == null
                ? l10n.deskFieldRequired
                : null,
          ),
          deskFormFieldSpacer(),
          DeskFeeField(
            controller: _fee,
            enabled: !_busy,
            free: _isFree,
            onFreeChanged: (on) {
              setState(() => _isFree = on);
              _changed();
            },
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
              : l10n.deskSaveAndIssue,
          isLoading: _busy,
          loadingLabel: l10n.deskWorking,
          onPressed: _busy ? null : () => unawaited(_submit()),
        ),
      ],
    );
  }
}
