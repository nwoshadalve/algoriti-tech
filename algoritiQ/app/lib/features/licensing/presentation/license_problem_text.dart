import '../../../l10n/app_localizations.dart';
import '../domain/license_state.dart';

String licenseProblemText(AppLocalizations l10n, LicenseProblem problem) =>
    switch (problem) {
      LicenseProblem.malformed => l10n.licenseErrorMalformed,
      LicenseProblem.unknownKey => l10n.licenseErrorUnknownKey,
      LicenseProblem.badSignature => l10n.licenseErrorBadSignature,
      LicenseProblem.wrongDevice => l10n.licenseErrorWrongDevice,
      LicenseProblem.expired => l10n.licenseErrorExpired,
    };
