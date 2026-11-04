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
import '../application/queue_board_providers.dart';
import '../application/queue_board_service.dart';
import '../domain/board_models.dart';
import 'queue_desk_dialog_layout.dart';
import 'queue_desk_errors.dart';
import 'queue_desk_format.dart';
import 'queue_desk_patient_fields.dart';

/// Edit a patient's name, phone, age and gender. Answers with the saved
/// patient, or null when closed without saving.
Future<PatientSummary?> showDeskPatientEditDialog({
  required BuildContext context,
  required PatientSummary patient,
}) {
  return showDialog<PatientSummary>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PatientEditDialog(patient: patient),
  );
}

class _PatientEditDialog extends ConsumerStatefulWidget {
  const _PatientEditDialog({required this.patient});

  final PatientSummary patient;

  @override
  ConsumerState<_PatientEditDialog> createState() => _PatientEditDialogState();
}

class _PatientEditDialogState extends ConsumerState<_PatientEditDialog> {
  late final TextEditingController _bengaliName;
  late final TextEditingController _englishName;
  late final TextEditingController _phone;
  late final TextEditingController _age;
  PatientGender? _gender;
  var _busy = false;
  var _submitted = false;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _bengaliName = TextEditingController(text: p.bengaliName);
    _englishName = TextEditingController(text: p.englishName);
    _phone = TextEditingController(
      text: queueDeskDisplayPhone(p.phoneNormalized),
    );
    _age = TextEditingController(
      text: (p.ageLabel ?? '').replaceAll(RegExp('[^0-9]'), ''),
    );
    _gender = p.gender;
    for (final c in [_bengaliName, _phone]) {
      c.addListener(() {
        if (_submitted && mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_bengaliName, _englishName, _phone, _age]) {
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
    if (_bengaliName.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      toast.error(l10n.deskErrorValidation);
      return;
    }
    setState(() => _busy = true);
    final english = _englishName.text.trim();
    try {
      final saved = await ref
          .read(queueBoardServiceProvider)
          .updatePatient(
            account,
            widget.patient.id,
            PatientInput(
              bengaliName: _bengaliName.text.trim(),
              phone: _phone.text.trim(),
              englishName: english.isEmpty ? null : english,
              gender: _gender,
              approximateAgeYears: queueDeskParseNumber(_age.text),
            ),
          );
      toast.success(l10n.deskPatientUpdated);
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
      body: DeskPatientFields(
        bengaliName: _bengaliName,
        englishName: _englishName,
        phone: _phone,
        age: _age,
        gender: _gender,
        onGender: (v) => setState(() => _gender = v),
        enabled: !_busy,
        showErrors: _submitted,
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
