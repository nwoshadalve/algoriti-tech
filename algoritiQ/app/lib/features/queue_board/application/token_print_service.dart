// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:typed_data';

import '../../access/domain/account.dart';
import '../../clinic/domain/chamber.dart';
import '../../clinic/domain/clinic_repository.dart';
import '../../clinic/domain/doctor.dart';
import '../../connectivity/data/token_slip_renderer.dart';
import '../../connectivity/domain/printer.dart';
import '../../connectivity/domain/token_slip.dart';
import '../domain/board_models.dart';
import 'queue_board_service.dart';

/// How a print ended, for the message the receptionist sees.
enum TokenPrintResult { sent, failed, notConnected, unknown }

/// Prints a token slip and records how it went on the token. A print problem
/// never touches the token or its place in the queue; it only changes the
/// token's print status so the table can offer a reprint.
class TokenPrintService {
  TokenPrintService({
    required this.board,
    required this.clinic,
    required this.print,
    this.printTimeout = defaultPrintTimeout,
    Future<Uint8List> Function(TokenSlip slip)? render,
  }) : _render = render ?? const TokenSlipRenderer().render;

  final QueueBoardService board;
  final ClinicRepository clinic;
  final Future<PrintOutcome> Function(Uint8List job) print;
  final Future<Uint8List> Function(TokenSlip slip) _render;

  /// A printer that neither answers nor fails counts as unknown after this.
  static const defaultPrintTimeout = Duration(seconds: 30);

  final Duration printTimeout;

  /// Prints the slip of a token that was just issued; [attemptId] is the
  /// pending attempt created with it.
  Future<TokenPrintResult> printIssued(
    Account account,
    BoardTokenView token,
    String chamberId,
    String attemptId,
  ) => _run(account, token, chamberId, attemptId, isReprint: false);

  /// Prints an issued token that is not on paper yet, or once more: a new
  /// attempt. [isReprint] marks the slip REPRINT, for a token that already
  /// printed. Throws [QueueBoardRefused] when another print is running.
  Future<TokenPrintResult> printAgain(
    Account account,
    BoardTokenView token,
    String chamberId, {
    required bool isReprint,
  }) async {
    final attemptId = await board.reprint(account, token.id, '');
    return _run(account, token, chamberId, attemptId, isReprint: isReprint);
  }

  /// Sends a slip for an attempt that is already [PENDING] (issue or reprint).
  Future<TokenPrintResult> fulfillPrintAttempt(
    Account account,
    BoardTokenView token,
    String chamberId,
    String attemptId, {
    required bool isReprint,
  }) => _run(account, token, chamberId, attemptId, isReprint: isReprint);

  Future<TokenPrintResult> _run(
    Account account,
    BoardTokenView token,
    String chamberId,
    String attemptId, {
    required bool isReprint,
  }) async {
    final result = await _send(token, chamberId, isReprint: isReprint);
    final status = switch (result) {
      TokenPrintResult.sent => PrintAttemptStatus.sent,
      TokenPrintResult.unknown => PrintAttemptStatus.unknown,
      _ => PrintAttemptStatus.failed,
    };
    await board.recordPrintResult(account, token.id, attemptId, status);
    return result;
  }

  Future<TokenPrintResult> _send(
    BoardTokenView token,
    String chamberId, {
    required bool isReprint,
  }) async {
    try {
      final slip = await _slipFor(token, chamberId, isReprint: isReprint);
      if (slip == null) return TokenPrintResult.failed;
      final outcome = await print(await _render(slip)).timeout(printTimeout);
      return switch (outcome) {
        PrintOutcome.printed => TokenPrintResult.sent,
        PrintOutcome.notConnected => TokenPrintResult.notConnected,
        PrintOutcome.failed => TokenPrintResult.failed,
      };
    } on TimeoutException {
      return TokenPrintResult.unknown;
    } on Object {
      return TokenPrintResult.failed;
    }
  }

  Future<TokenSlip?> _slipFor(
    BoardTokenView token,
    String chamberId, {
    required bool isReprint,
  }) async {
    final chambers = await clinic.watchChambers().first;
    final doctors = await clinic.watchDoctors().first;
    Chamber? chamber;
    for (final c in chambers) {
      if (c.id == chamberId) chamber = c;
    }
    if (chamber == null) return null;
    Doctor? doctor;
    for (final d in doctors) {
      if (d.id == chamber.doctorId) doctor = d;
    }
    if (doctor == null) return null;
    return TokenSlip(
      chamberName: chamber.name,
      doctorName: doctor.name,
      queueType: _builtInType(token.queueTypeId),
      queueLabel: token.queueBengaliName,
      tokenNumber: token.serial,
      registrationId: token.clinicPatientId,
      issuedAt: token.issuedAt.toLocal(),
      isReprint: isReprint,
    );
  }

  /// The slip always prints the queue's Bengali name ([TokenSlip.queueLabel]);
  /// this only fills the required built-in type.
  QueueType _builtInType(String queueTypeId) => switch (queueTypeId) {
    'report' => QueueType.report,
    'dressing' => QueueType.dressing,
    _ => QueueType.regular,
  };
}
