// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../../../l10n/app_localizations.dart';
import '../domain/setup_outcome.dart';

/// Localized, actionable message for a failed setup action; null on success
/// or when the problem is shown on the fields themselves
/// ([SetupOutcome.fieldsMissing]).
String? setupOutcomeText(
  AppLocalizations l10n,
  SetupOutcome outcome, {
  required int maxChambers,
}) => switch (outcome) {
  SetupOutcome.saved || SetupOutcome.fieldsMissing => null,
  SetupOutcome.limitReached => l10n.chamberLimitReached(maxChambers),
  SetupOutcome.noChambers => l10n.addOneChamber,
  SetupOutcome.failed => l10n.setupSaveFailed,
};
