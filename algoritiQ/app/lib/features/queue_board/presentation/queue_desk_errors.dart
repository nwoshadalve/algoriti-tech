// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../../../l10n/app_localizations.dart';
import '../application/queue_board_service.dart';

String queueDeskErrorMessage(AppLocalizations l10n, QueueBoardRefused refused) {
  return switch (refused.problem) {
    QueueBoardProblem.sessionClosed => l10n.deskSessionClosedHint,
    QueueBoardProblem.unresolvedCalledToken => l10n.deskResolveCallFirst,
    QueueBoardProblem.noWaitingToken => l10n.deskNoWaiting,
    QueueBoardProblem.noCalledToken => l10n.deskNothingToRecall,
    QueueBoardProblem.duplicatePhoneNeedsConfirm =>
      l10n.deskErrorDuplicatePhone,
    QueueBoardProblem.patientHasActiveToken => l10n.deskErrorActiveToken,
    QueueBoardProblem.rangeExhausted => l10n.deskErrorRangeExhausted,
    QueueBoardProblem.validation => l10n.deskErrorValidation,
    QueueBoardProblem.forbidden => l10n.deskErrorForbidden,
    _ => l10n.deskErrorGeneric,
  };
}
