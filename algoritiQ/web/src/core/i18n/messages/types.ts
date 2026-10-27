export type MessageKey = keyof Messages

export type Messages = {
  languageLabel: string
  themeLight: string
  themeDark: string
  loadingLabel: string

  setupTitle: string
  setupIntro: string
  activationTitle: string
  activationIntro: string
  activationContinue: string
  fieldActivationCode: string
  fieldActivationCodeHint: string
  errorActivationCodeRequired: string
  errorActivationCodeInvalid: string

  setupProgressLabel: string
  setupProgressStep: string

  registerTitle: string
  registerIntro: string
  asideStepOpen: string
  asideStepCode: string
  asideStepRegister: string
  registerFormHeading: string
  changeActivationCode: string
  registerSubmit: string
  registerSubmitting: string

  fieldUsername: string
  fieldUsernameHint: string
  fieldDisplayName: string
  fieldDisplayNameHint: string
  fieldPassword: string
  fieldPasswordHint: string
  fieldConfirmPassword: string
  showPassword: string
  hidePassword: string

  errorUsernameRequired: string
  errorUsernameInvalid: string
  errorDisplayNameTooLong: string
  errorPasswordRequired: string
  errorPasswordTooShort: string
  errorPasswordTooLong: string
  errorPasswordContainsUsername: string
  errorConfirmPasswordRequired: string
  errorConfirmPasswordMismatch: string

  errorClaimCodeInvalid: string
  errorClaimCodeInvalidWithAttempts: string
  errorClaimCodeExpired: string
  errorClaimCodeLocked: string
  errorAdminAlreadyRegistered: string
  errorUsernameInvalidApi: string
  errorPasswordTooShortApi: string
  errorPasswordTooLongApi: string
  errorPasswordContainsUsernameApi: string
  errorInvalidRequest: string
  errorNetwork: string
  errorGeneric: string
  errorStatusCheck: string


  welcomeTitle: string
  welcomeIntro: string
  loginTitle: string
  loginIntro: string
  loginSubmit: string
  loginSubmitting: string
  forgotPasswordLink: string
  noticePasswordReset: string
  errorLoginRequired: string
  errorInvalidCredentials: string
  errorTooManyAttempts: string
  forgotTitle: string
  fieldActivationKey: string
  fieldActivationKeyHint: string
  errorActivationKeyRequired: string
  fieldNewPassword: string
  fieldConfirmNewPassword: string
  resetSubmit: string
  resetSubmitting: string
  backToSignIn: string
  errorResetRefused: string
  goToSignIn: string
  homeWelcome: string
  homeSignedInAs: string
  homeComingSoon: string
  signOut: string
  signingOut: string

  resetAsideTitle: string
  resetAsideIntro: string
  resetProgressLabel: string
  resetStepUsername: string
  resetStepKey: string
  resetStepPassword: string
  resetUsernameIntro: string
  resetKeyTitle: string
  resetKeyIntro: string
  resetPasswordTitle: string
  resetPasswordIntro: string
  continueButton: string
  checkingKey: string
  backButton: string
  errorResetExpired: string

  successTitle: string
  successBody: string

  privacyNote: string
}

export type Locale = 'en' | 'bn'
