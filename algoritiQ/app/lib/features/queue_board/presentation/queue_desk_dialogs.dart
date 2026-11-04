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
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/tablet_session.dart';
import '../application/queue_board_providers.dart';
import '../application/queue_board_service.dart';
import '../domain/board_models.dart';
import 'queue_desk_dialog_layout.dart';
import 'queue_desk_errors.dart';
import 'queue_desk_format.dart';

Future<void> showDeskRegisterDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String chamberId,
  required List<QueueTypeBoardControl> queueControls,
  String initialPhone = '',
  required VoidCallback onDone,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _RegisterDeskDialog(
      chamberId: chamberId,
      queueControls: queueControls,
      initialPhone: initialPhone,
      onDone: onDone,
    ),
  );
}

Future<void> showDeskExistingDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String chamberId,
  required List<QueueTypeBoardControl> queueControls,
  required VoidCallback onDone,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _ExistingDeskDialog(
      chamberId: chamberId,
      queueControls: queueControls,
      onDone: onDone,
      onRegister: (phone) {
        Navigator.of(dialogContext).pop();
        unawaited(
          showDeskRegisterDialog(
            context: context,
            ref: ref,
            chamberId: chamberId,
            queueControls: queueControls,
            initialPhone: phone,
            onDone: onDone,
          ),
        );
      },
    ),
  );
}

class _RegisterDeskDialog extends ConsumerStatefulWidget {
  const _RegisterDeskDialog({
    required this.chamberId,
    required this.queueControls,
    required this.initialPhone,
    required this.onDone,
  });

  final String chamberId;
  final List<QueueTypeBoardControl> queueControls;
  final String initialPhone;
  final VoidCallback onDone;

  @override
  ConsumerState<_RegisterDeskDialog> createState() =>
      _RegisterDeskDialogState();
}

class _RegisterDeskDialogState extends ConsumerState<_RegisterDeskDialog> {
  late final TextEditingController _bengaliName;
  late final TextEditingController _englishName;
  late final TextEditingController _phone;
  late final TextEditingController _age;
  late final TextEditingController _fee;
  PatientGender? _gender;
  String? _queueTypeId;
  var _hasPaperFile = false;
  var _busy = false;
  var _duplicateConfirm = false;

  @override
  void initState() {
    super.initState();
    _bengaliName = TextEditingController();
    _englishName = TextEditingController();
    _phone = TextEditingController(text: widget.initialPhone);
    _age = TextEditingController();
    _fee = TextEditingController();
    if (widget.queueControls.length == 1) {
      _queueTypeId = widget.queueControls.first.queueTypeId;
    }
  }

  @override
  void dispose() {
    _bengaliName.dispose();
    _englishName.dispose();
    _phone.dispose();
    _age.dispose();
    _fee.dispose();
    super.dispose();
  }

  String? get _selectedQueueId => widget.queueControls.length == 1
      ? widget.queueControls.first.queueTypeId
      : _queueTypeId;

  Future<void> _submit() async {
    final account = ref.read(tabletSessionProvider)?.account;
    final queueId = _selectedQueueId;
    if (account == null ||
        _busy ||
        queueId == null ||
        queueId.isEmpty ||
        _bengaliName.text.trim().isEmpty ||
        _phone.text.trim().isEmpty) {
      return;
    }
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    final toast = ref.read(toastControllerProvider.notifier);
    final service = ref.read(queueBoardServiceProvider);
    final newId = ref.read(idGeneratorProvider);
    final ageNum = int.tryParse(_age.text.trim());
    final feeNum = int.tryParse(_fee.text.trim());
    try {
      final patient = await service.registerPatient(
        account,
        PatientInput(
          bengaliName: _bengaliName.text.trim(),
          phone: _phone.text.trim(),
          englishName: _englishName.text.trim().isEmpty
              ? null
              : _englishName.text.trim(),
          gender: _gender,
          approximateAgeYears: ageNum,
          hasPaperFile: _hasPaperFile,
          confirmDuplicatePhone: _duplicateConfirm,
        ),
        commandId: newId(),
        chamberId: widget.chamberId,
      );
      final preview = await service.previewIssue(
        account,
        widget.chamberId,
        patient.id,
        queueId,
        feeBdt: feeNum,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await _showIssueConfirm(
        context: context,
        ref: ref,
        chamberId: widget.chamberId,
        preview: preview,
        onDone: widget.onDone,
      );
    } on QueueBoardRefused catch (e) {
      if (e.problem == QueueBoardProblem.duplicatePhoneNeedsConfirm) {
        setState(() => _duplicateConfirm = true);
        toast.error(l10n.deskErrorDuplicatePhone);
      } else {
        toast.error(queueDeskErrorMessage(l10n, e));
      }
    } on Object {
      toast.error(l10n.deskErrorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    return DeskFormDialog(
      title: l10n.deskRegisterTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_duplicateConfirm)
            Padding(
              padding: const EdgeInsets.only(bottom: deskFormFieldGap),
              child: Text(
                l10n.deskDuplicatePhoneConfirm,
                style: deskFormBodyStyle(context),
              ),
            ),
          deskFormRow([
            LabeledTextField(
              compact: true,
              label: '${l10n.deskFieldBengaliName} *',
              controller: _bengaliName,
              enabled: !_busy,
            ),
            LabeledTextField(
              compact: true,
              label: l10n.deskFieldEnglishName,
              controller: _englishName,
              enabled: !_busy,
            ),
          ]),
          deskFormFieldSpacer(),
          if (widget.queueControls.length > 1)
            deskFormRow([
              LabeledTextField(
                compact: true,
                label: '${l10n.fieldPhone} *',
                controller: _phone,
                keyboardType: TextInputType.phone,
                enabled: !_busy,
              ),
              DeskLabeledDropdown<String>(
                label: '${l10n.deskFieldQueue} *',
                enabled: !_busy,
                value: _queueTypeId,
                onSelected: (v) => setState(() => _queueTypeId = v),
                entries: [
                  for (final q in widget.queueControls)
                    DropdownMenuEntry(
                      value: q.queueTypeId,
                      label: queueDeskQueueName(locale, q),
                    ),
                ],
              ),
            ])
          else
            LabeledTextField(
              compact: true,
              label: '${l10n.fieldPhone} *',
              controller: _phone,
              keyboardType: TextInputType.phone,
              enabled: !_busy,
            ),
          deskFormFieldSpacer(),
          deskFormRow([
            LabeledTextField(
              compact: true,
              label: l10n.deskFieldAge,
              controller: _age,
              keyboardType: TextInputType.number,
              enabled: !_busy,
            ),
            DeskLabeledDropdown<PatientGender?>(
              label: l10n.deskFieldGender,
              enabled: !_busy,
              value: _gender,
              onSelected: (v) => setState(() => _gender = v),
              entries: [
                DropdownMenuEntry(value: null, label: l10n.deskGenderUnset),
                DropdownMenuEntry(
                  value: PatientGender.male,
                  label: l10n.deskGenderMale,
                ),
                DropdownMenuEntry(
                  value: PatientGender.female,
                  label: l10n.deskGenderFemale,
                ),
                DropdownMenuEntry(
                  value: PatientGender.other,
                  label: l10n.deskGenderOther,
                ),
                DropdownMenuEntry(
                  value: PatientGender.notStated,
                  label: l10n.deskGenderNotStated,
                ),
              ],
            ),
          ]),
          deskFormFieldSpacer(),
          LabeledTextField(
            compact: true,
            label: l10n.deskFieldFee,
            controller: _fee,
            keyboardType: TextInputType.number,
            enabled: !_busy,
          ),
          deskFormFieldSpacer(),
          CheckboxListTile(
            value: _hasPaperFile,
            onChanged: _busy
                ? null
                : (v) => setState(() => _hasPaperFile = v ?? false),
            title: Text(
              l10n.deskFieldPaperFile,
              style: deskFormBodyStyle(context),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
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

class _ExistingDeskDialog extends ConsumerStatefulWidget {
  const _ExistingDeskDialog({
    required this.chamberId,
    required this.queueControls,
    required this.onDone,
    required this.onRegister,
  });

  final String chamberId;
  final List<QueueTypeBoardControl> queueControls;
  final VoidCallback onDone;
  final ValueChanged<String> onRegister;

  @override
  ConsumerState<_ExistingDeskDialog> createState() =>
      _ExistingDeskDialogState();
}

class _ExistingDeskDialogState extends ConsumerState<_ExistingDeskDialog> {
  final _query = TextEditingController();
  Timer? _debounce;
  List<PatientSummary> _results = [];
  PatientSummary? _selected;
  String? _queueTypeId;
  final _fee = TextEditingController();
  var _searching = false;
  var _previewBusy = false;

  @override
  void initState() {
    super.initState();
    if (widget.queueControls.length == 1) {
      _queueTypeId = widget.queueControls.first.queueTypeId;
    }
    _query.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _fee.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_search(_query.text));
    });
  }

  Future<void> _search(String text) async {
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null || text.trim().length < 2) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final patients = await ref
          .read(queueBoardServiceProvider)
          .searchPatients(account, text.trim());
      if (!mounted) return;
      setState(() => _results = patients);
    } on QueueBoardRefused catch (e) {
      ref
          .read(toastControllerProvider.notifier)
          .error(queueDeskErrorMessage(AppLocalizations.of(context), e));
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  String? get _queueId => widget.queueControls.length == 1
      ? widget.queueControls.first.queueTypeId
      : _queueTypeId;

  Future<void> _previewIssue() async {
    final account = ref.read(tabletSessionProvider)?.account;
    final patient = _selected;
    final queueId = _queueId;
    if (account == null ||
        patient == null ||
        queueId == null ||
        queueId.isEmpty ||
        _previewBusy) {
      return;
    }
    setState(() => _previewBusy = true);
    final l10n = AppLocalizations.of(context);
    final feeNum = int.tryParse(_fee.text.trim());
    try {
      final preview = await ref
          .read(queueBoardServiceProvider)
          .previewIssue(
            account,
            widget.chamberId,
            patient.id,
            queueId,
            feeBdt: feeNum,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      await _showIssueConfirm(
        context: context,
        ref: ref,
        chamberId: widget.chamberId,
        preview: preview,
        onDone: widget.onDone,
      );
    } on QueueBoardRefused catch (e) {
      ref
          .read(toastControllerProvider.notifier)
          .error(queueDeskErrorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _previewBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final selected = _selected;
    return DeskFormDialog(
      title: l10n.deskExistingPatient,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledTextField(
            compact: true,
            label: l10n.deskSearchLabel,
            controller: _query,
            autocorrect: false,
          ),
          if (_searching)
            Padding(
              padding: const EdgeInsets.only(top: deskFormFieldGap),
              child: Text(l10n.deskSearching, style: deskFormBodyStyle(context)),
            ),
          if (_results.isNotEmpty) ...[
            deskFormFieldSpacer(),
            SizedBox(
              height: 140,
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final p = _results[index];
                  final isSelected = selected?.id == p.id;
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    selected: isSelected,
                    title: Text(
                      p.bengaliName,
                      style: deskFormBodyStyle(context),
                    ),
                    subtitle: Text(
                      '${p.clinicPatientId}${p.ageLabel != null ? ' · ${p.ageLabel}' : ''}',
                      style: deskFormBodyStyle(context),
                    ),
                    onTap: () => setState(() => _selected = p),
                  );
                },
              ),
            ),
          ],
          if (_query.text.trim().length >= 2 && !_searching && _results.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: deskFormFieldGap),
              child: Text(l10n.deskSearchEmpty, style: deskFormBodyStyle(context)),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => widget.onRegister(_query.text.trim()),
              child: Text(l10n.deskRegisterNew),
            ),
          ),
          if (selected case final patient?) ...[
            const Divider(height: 1),
            deskFormFieldSpacer(),
            Text(
              l10n.deskIssueFor(patient.bengaliName),
              style: deskFormBodyStyle(context)?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            deskFormFieldSpacer(),
            if (widget.queueControls.length > 1)
              DeskLabeledDropdown<String>(
                label: '${l10n.deskFieldQueue} *',
                value: _queueTypeId,
                onSelected: (v) => setState(() => _queueTypeId = v),
                entries: [
                  for (final q in widget.queueControls)
                    DropdownMenuEntry(
                      value: q.queueTypeId,
                      label: queueDeskQueueName(locale, q),
                    ),
                ],
              )
            else if (widget.queueControls.isNotEmpty)
              Text(
                queueDeskQueueName(locale, widget.queueControls.first),
                style: deskFormBodyStyle(context),
              ),
            deskFormFieldSpacer(),
            LabeledTextField(
              compact: true,
              label: l10n.deskFieldFee,
              controller: _fee,
              keyboardType: TextInputType.number,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelEditButton),
        ),
        if (selected != null)
          LoadingButton(
            label: l10n.deskIssuePreview,
            isLoading: _previewBusy,
            loadingLabel: l10n.deskWorking,
            onPressed: _previewBusy ? null : () => unawaited(_previewIssue()),
          ),
      ],
    );
  }
}

Future<void> _showIssueConfirm({
  required BuildContext context,
  required WidgetRef ref,
  required String chamberId,
  required IssuePreview preview,
  required VoidCallback onDone,
}) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context);
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => DeskFormDialog(
      title: l10n.deskIssueConfirmTitle,
      body: Builder(
        builder: (context) {
          final line = deskFormBodyStyle(context);
          final serialStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.deskFieldPatient}: ${preview.patient.bengaliName}',
                style: line,
              ),
              Text(preview.patient.clinicPatientId, style: line),
              Text(
                '${l10n.deskFieldChamber}: ${preview.chamberName}',
                style: line,
              ),
              Text(
                '${l10n.deskFieldQueue}: ${queueDeskPreviewQueueName(locale, preview)}',
                style: line,
              ),
              deskFormFieldSpacer(),
              Text(
                '${l10n.deskFieldPreviewSerial}: ${queueDeskFormatSerial(preview.previewSerial, locale)}',
                style: serialStyle,
              ),
              if (preview.feeBdt != null)
                Text('${l10n.deskFieldFee}: ${preview.feeBdt}', style: line),
            ],
          );
        },
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.deskIssueBack),
        ),
        _IssueConfirmButton(
          chamberId: chamberId,
          preview: preview,
          onDone: () {
            Navigator.of(dialogContext).pop();
            onDone();
          },
        ),
      ],
    ),
  );
}

class _IssueConfirmButton extends ConsumerStatefulWidget {
  const _IssueConfirmButton({
    required this.chamberId,
    required this.preview,
    required this.onDone,
  });

  final String chamberId;
  final IssuePreview preview;
  final VoidCallback onDone;

  @override
  ConsumerState<_IssueConfirmButton> createState() =>
      _IssueConfirmButtonState();
}

class _IssueConfirmButtonState extends ConsumerState<_IssueConfirmButton> {
  var _busy = false;

  Future<void> _confirm() async {
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null || _busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    final newId = ref.read(idGeneratorProvider);
    try {
      await ref
          .read(queueBoardServiceProvider)
          .issueToken(
            account,
            widget.chamberId,
            widget.preview.patient.id,
            widget.preview.queueTypeId,
            feeBdt: widget.preview.feeBdt,
            commandId: newId(),
          );
      ref.read(toastControllerProvider.notifier).success(l10n.deskIssueSuccess);
      widget.onDone();
    } on QueueBoardRefused catch (e) {
      ref
          .read(toastControllerProvider.notifier)
          .error(queueDeskErrorMessage(l10n, e));
    } on Object {
      ref.read(toastControllerProvider.notifier).error(l10n.deskErrorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LoadingButton(
      label: l10n.deskIssueConfirmPrint,
      isLoading: _busy,
      loadingLabel: l10n.deskWorking,
      onPressed: () => unawaited(_confirm()),
    );
  }
}
