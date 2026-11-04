// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/toast/toast_controller.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/tablet_session.dart';
import '../application/queue_board_providers.dart';
import '../application/queue_board_service.dart';
import '../application/token_print_service.dart';
import '../domain/board_models.dart';
import 'queue_desk_errors.dart';
import 'queue_desk_format.dart';
import 'queue_desk_patient_edit_dialog.dart';

/// What the receptionist can do with a token after it is issued: print it,
/// fix the patient's details, cancel it. Each one reports through the toaster
/// and asks the desk to [refresh] so the table shows the new state.
class QueueDeskTokenActions {
  const QueueDeskTokenActions({
    required this.context,
    required this.ref,
    required this.chamberId,
    required this.refresh,
  });

  final BuildContext context;
  final WidgetRef ref;
  final String chamberId;
  final Future<void> Function() refresh;

  ToastController get _toast => ref.read(toastControllerProvider.notifier);

  /// A token was just issued: show it in the table first, then try the
  /// printer. A printer problem is reported but never undoes the token.
  Future<void> afterIssue(IssuedTokenResult issued) async {
    final l10n = AppLocalizations.of(context);
    final account = ref.read(tabletSessionProvider)?.account;
    await refresh();
    if (account == null) return;
    final result = await ref
        .read(tokenPrintServiceProvider)
        .printIssued(account, issued.token, chamberId, issued.printAttemptId);
    // The receptionist may have left the desk while the slip was printing.
    if (!context.mounted) return;
    switch (result) {
      case TokenPrintResult.sent:
        _toast.success(l10n.deskPatientAddedPrinted);
      case TokenPrintResult.unknown:
        _toast.error(l10n.deskIssuedPrintUnknown);
      case TokenPrintResult.failed || TokenPrintResult.notConnected:
        _toast.error(l10n.deskIssuedNotPrinted);
    }
    await refresh();
  }

  /// Asks, then prints the token again.
  Future<void> reprint(BoardTokenView token) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null) return;
    // Only a slip that already came out is a REPRINT; the first successful
    // print of a token is just a print.
    final isReprint = token.latestPrintStatus == 'SENT';
    final serial = queueDeskFormatSerial(token.serial, locale);
    final confirmed = await _confirm(
      title: isReprint ? l10n.deskReprintTitle : l10n.deskPrintConfirmTitle,
      body: isReprint
          ? l10n.deskReprintBody(serial)
          : l10n.deskPrintConfirmBody(serial),
      keep: l10n.cancelEditButton,
      action: l10n.deskReprintConfirm,
    );
    if (!confirmed) return;
    try {
      final service = ref.read(tokenPrintServiceProvider);
      final pending = service.printAgain(
        account,
        token,
        chamberId,
        isReprint: isReprint,
      );
      // A refusal is awaited below; until then it must not count as unhandled.
      pending.ignore();
      await refresh();
      final result = await pending;
      if (!context.mounted) return;
      switch (result) {
        case TokenPrintResult.sent:
          _toast.success(l10n.deskPrintSent);
        case TokenPrintResult.unknown:
          _toast.error(l10n.deskIssuedPrintUnknown);
        case TokenPrintResult.failed || TokenPrintResult.notConnected:
          _toast.error(l10n.deskPrintFailed);
      }
    } on QueueBoardRefused catch (e) {
      if (!context.mounted) return;
      _toast.error(queueDeskErrorMessage(l10n, e));
    } on Object {
      if (!context.mounted) return;
      _toast.error(l10n.deskErrorGeneric);
    }
    if (!context.mounted) return;
    await refresh();
  }

  Future<void> editPatient(BoardTokenView token) async {
    final l10n = AppLocalizations.of(context);
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null) return;
    try {
      final patient = await ref
          .read(queueBoardServiceProvider)
          .getPatient(account, token.patientId);
      if (!context.mounted) return;
      final saved = await showDeskPatientEditDialog(
        context: context,
        patient: patient,
      );
      if (saved != null && context.mounted) await refresh();
    } on Object {
      if (!context.mounted) return;
      _toast.error(l10n.deskErrorGeneric);
    }
  }

  /// Asks, then cancels the token; its serial is not used again.
  Future<void> cancel(BoardTokenView token) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final account = ref.read(tabletSessionProvider)?.account;
    if (account == null) return;
    final confirmed = await _confirm(
      title: l10n.deskCancelTokenTitle,
      body: l10n.deskCancelTokenBody(
        queueDeskFormatSerial(token.serial, locale),
        token.patientBengaliName,
      ),
      keep: l10n.deskCancelTokenKeep,
      action: l10n.deskCancelTokenTitle,
    );
    if (!confirmed) return;
    try {
      await ref
          .read(queueBoardServiceProvider)
          .cancelToken(account, token.id, '');
      if (!context.mounted) return;
      _toast.success(l10n.deskTokenCancelled);
      await refresh();
    } on QueueBoardRefused catch (e) {
      if (!context.mounted) return;
      _toast.error(queueDeskErrorMessage(l10n, e));
    } on Object {
      if (!context.mounted) return;
      _toast.error(l10n.deskErrorGeneric);
    }
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String keep,
    required String action,
  }) async {
    final confirmed = await showAppDialog<bool>(
      context: context,
      title: title,
      body: Text(body),
      actions: [
        Builder(
          builder: (dialogContext) => TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(keep),
          ),
        ),
        Builder(
          builder: (dialogContext) => FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(action),
          ),
        ),
      ],
    );
    return confirmed ?? false;
  }
}
