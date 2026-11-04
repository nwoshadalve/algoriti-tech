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
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/tablet_session.dart';
import '../application/queue_board_providers.dart';
import '../application/queue_board_service.dart';
import '../domain/board_models.dart';
import 'queue_desk_dialog_layout.dart';
import 'queue_desk_errors.dart';
import 'queue_desk_patient_edit_dialog.dart';
import 'queue_desk_patient_widgets.dart';
import 'queue_desk_queue_picker.dart';
import 'queue_desk_register_dialog.dart';

/// Shortest search that is worth running (counted in what the person sees as
/// characters, so a Bengali conjunct counts once).
const _minSearchLength = 2;
const _searchPause = Duration(milliseconds: 250);

/// Add an already registered patient to the session: search, pick, choose the
/// queue and fee, issue. Answers with the issued token, or null when closed.
/// "Register as new patient" carries what was typed into the new-patient popup.
Future<IssuedTokenResult?> showDeskExistingDialog({
  required BuildContext context,
  required String chamberId,
  required List<QueueTypeBoardControl> queueControls,
}) async {
  final outcome = await showDialog<Object>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        _ExistingDeskDialog(chamberId: chamberId, queueControls: queueControls),
  );
  if (outcome is _RegisterInstead) {
    if (!context.mounted) return null;
    final digits = RegExp(r'^[0-9+\s-]+$').hasMatch(outcome.query);
    return showDeskRegisterDialog(
      context: context,
      chamberId: chamberId,
      queueControls: queueControls,
      initialPhone: digits ? outcome.query : '',
      initialName: digits ? '' : outcome.query,
    );
  }
  return outcome is IssuedTokenResult ? outcome : null;
}

/// The popup was left through "Register as new patient".
final class _RegisterInstead {
  const _RegisterInstead(this.query);
  final String query;
}

class _ExistingDeskDialog extends ConsumerStatefulWidget {
  const _ExistingDeskDialog({
    required this.chamberId,
    required this.queueControls,
  });

  final String chamberId;
  final List<QueueTypeBoardControl> queueControls;

  @override
  ConsumerState<_ExistingDeskDialog> createState() =>
      _ExistingDeskDialogState();
}

class _ExistingDeskDialogState extends ConsumerState<_ExistingDeskDialog> {
  final _query = TextEditingController();
  final _fee = TextEditingController();
  Timer? _pause;
  var _searchSeq = 0;
  List<PatientSummary> _results = const [];
  var _searching = false;
  var _searchFailed = false;
  PatientSummary? _selected;
  String? _queueTypeId;
  var _issuing = false;
  var _submitted = false;

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
    _pause?.cancel();
    _query.dispose();
    _fee.dispose();
    super.dispose();
  }

  bool get _longEnough =>
      _query.text.trim().characters.length >= _minSearchLength;

  void _onQueryChanged() {
    _pause?.cancel();
    if (!_longEnough) {
      _searchSeq++;
      setState(() {
        _results = const [];
        _searching = false;
        _searchFailed = false;
      });
      return;
    }
    setState(() => _searching = true);
    _pause = Timer(_searchPause, () => unawaited(_search(_query.text.trim())));
  }

  Future<void> _search(String text) async {
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null) return;
    final seq = ++_searchSeq;
    try {
      final found = await ref
          .read(queueBoardServiceProvider)
          .searchPatients(account, text);
      // A slower answer for an older query must not replace a newer one.
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _results = found;
        _searching = false;
        _searchFailed = false;
      });
    } on Object {
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _results = const [];
        _searching = false;
        _searchFailed = true;
      });
    }
  }

  Future<void> _editSelected() async {
    final patient = _selected;
    if (patient == null) return;
    final saved = await showDeskPatientEditDialog(
      context: context,
      patient: patient,
    );
    if (saved != null && mounted) setState(() => _selected = saved);
  }

  Future<void> _issue() async {
    final account = ref.read(tabletSessionProvider)?.account;
    final patient = _selected;
    if (account == null || patient == null || _issuing) return;
    final l10n = AppLocalizations.of(context);
    final toast = ref.read(toastControllerProvider.notifier);
    final queueId = _queueTypeId;
    setState(() => _submitted = true);
    if (queueId == null) {
      toast.error(l10n.deskErrorValidation);
      return;
    }
    setState(() => _issuing = true);
    try {
      final issued = await ref
          .read(queueBoardServiceProvider)
          .issueToken(
            account,
            widget.chamberId,
            patient.id,
            queueId,
            feeBdt: queueDeskParseNumber(_fee.text),
            commandId: ref.read(idGeneratorProvider)(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(issued);
    } on QueueBoardRefused catch (e) {
      toast.error(queueDeskErrorMessage(l10n, e));
    } on Object {
      toast.error(l10n.deskErrorGeneric);
    } finally {
      if (mounted) setState(() => _issuing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final patient = _selected;
    if (patient == null) {
      return DeskFormDialog(
        title: l10n.deskExistingPatient,
        body: DeskSearchStep(
          query: _query,
          results: _results,
          searching: _searching,
          failed: _searchFailed,
          longEnough: _longEnough,
          onPick: (p) => setState(() => _selected = p),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_RegisterInstead(_query.text.trim())),
            child: Text(l10n.deskRegisterNew),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancelEditButton),
          ),
        ],
      );
    }
    return DeskFormDialog(
      title: l10n.deskIssueTokenTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DeskPatientCard(
            patient: patient,
            onEdit: _issuing ? null : () => unawaited(_editSelected()),
          ),
          deskFormFieldSpacer(),
          DeskQueuePicker(
            controls: widget.queueControls,
            selectedId: _queueTypeId,
            enabled: !_issuing,
            onSelected: (id) => setState(() => _queueTypeId = id),
            errorText: _submitted && _queueTypeId == null
                ? l10n.deskFieldRequired
                : null,
          ),
          deskFormFieldSpacer(),
          LabeledTextField(
            compact: true,
            label: l10n.deskFieldFee,
            controller: _fee,
            keyboardType: TextInputType.number,
            enabled: !_issuing,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _issuing ? null : () => setState(() => _selected = null),
          child: Text(l10n.deskChangePatient),
        ),
        LoadingButton(
          label: l10n.deskIssueTokenAction,
          isLoading: _issuing,
          loadingLabel: l10n.deskWorking,
          onPressed: _issuing ? null : () => unawaited(_issue()),
        ),
      ],
    );
  }
}
