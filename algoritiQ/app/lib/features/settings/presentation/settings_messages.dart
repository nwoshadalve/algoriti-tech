// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../../../l10n/app_localizations.dart';
import '../../access/domain/access_policy.dart';
import '../../access/application/access_service.dart';

String profileProblemMessage(AppLocalizations l10n, ProfileProblem problem) =>
    switch (problem) {
      ProfileProblem.firstNameMissing => l10n.settingsFirstNameRequired,
      ProfileProblem.nameTooLong => l10n.settingsNameTooLong,
      ProfileProblem.emailInvalid => l10n.settingsEmailInvalid,
      ProfileProblem.emailTaken => l10n.settingsEmailTaken,
      ProfileProblem.phoneInvalid => l10n.settingsPhoneInvalid,
    };

String credentialProblemMessage(
  AppLocalizations l10n,
  CredentialProblem problem,
) => switch (problem) {
  CredentialProblem.passwordTooShort => l10n.passwordTooShort,
  CredentialProblem.passwordTooLong => l10n.passwordTooLong,
  CredentialProblem.passwordContainsUsername => l10n.passwordHasUsername,
  _ => l10n.passwordNeeded,
};

String pinProblemMessage(AppLocalizations l10n, PinProblem problem) =>
    switch (problem) {
      PinProblem.format => l10n.pinFormatInvalid,
      PinProblem.weak => l10n.pinWeak,
    };

String changePasswordMessage(AppLocalizations l10n, ChangePasswordResult r) =>
    switch (r) {
      CurrentPasswordWrong() => l10n.passwordCurrentWrong,
      NewPasswordSame() => l10n.passwordNewSame,
      ChangeThrottled(:final retryAfter) => l10n.signInWait(
        retryAfter.inSeconds + 1,
      ),
      NewPasswordRefused(:final problem) => credentialProblemMessage(
        l10n,
        problem,
      ),
      PasswordChanged() => l10n.passwordChanged,
    };

String setPinMessage(AppLocalizations l10n, SetPinResult r) => switch (r) {
  PinPasswordWrong() => l10n.pinPasswordWrong,
  PinRefused(:final problem) => pinProblemMessage(l10n, problem),
  PinSetThrottled(:final retryAfter) => l10n.signInWait(
    retryAfter.inSeconds + 1,
  ),
  PinSet() => l10n.pinSetDone,
};
