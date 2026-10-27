// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get activationTitle => 'Activate this device';

  @override
  String get activationIntro =>
      'Send this device code to your provider to get an activation key.';

  @override
  String get deviceCodeLabel => 'Device code';

  @override
  String get copyDeviceCode => 'Copy';

  @override
  String get deviceCodeCopied => 'Device code copied';

  @override
  String get activationKeyLabel => 'Activation key';

  @override
  String get activationKeyHint => 'Paste or type the key';

  @override
  String get activateButton => 'Activate';

  @override
  String get licenseErrorMalformed =>
      'This doesn\'t look like an activation key. Check it and try again.';

  @override
  String get licenseErrorUnknownKey =>
      'This version of the app doesn\'t recognise this key.';

  @override
  String get licenseErrorBadSignature => 'This key is not valid.';

  @override
  String get licenseErrorWrongDevice =>
      'This key was issued for a different device.';

  @override
  String get licenseErrorExpired =>
      'Your license has expired. Enter a renewed key to continue.';

  @override
  String get deviceUnavailable => 'Couldn\'t read this device\'s identity.';

  @override
  String get retryButton => 'Try again';

  @override
  String licenseSummaryDoctor(int chambers) {
    String _temp0 = intl.Intl.pluralLogic(
      chambers,
      locale: localeName,
      other: 'chambers',
      one: 'chamber',
    );
    return 'Doctor license · up to $chambers $_temp0';
  }

  @override
  String licenseSummaryChamber(int doctors) {
    String _temp0 = intl.Intl.pluralLogic(
      doctors,
      locale: localeName,
      other: 'doctors',
      one: 'doctor',
    );
    return 'Chamber license · up to $doctors $_temp0';
  }

  @override
  String licenseValidUntil(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Valid until $dateString';
  }

  @override
  String get licenseNoExpiry => 'No expiry';

  @override
  String get licenseGraceNotice =>
      'License expired. Enter a renewed key soon to avoid interruption.';

  @override
  String get activationStepCopy => 'Copy code';

  @override
  String get activationStepGet => 'Get key';

  @override
  String get activationStepEnter => 'Enter key';

  @override
  String get stepDone => 'done';

  @override
  String get stepCurrent => 'current step';

  @override
  String get activationFooter =>
      'Your license is tied to this device and works offline.';

  @override
  String get activating => 'Activating…';

  @override
  String get languageLabel => 'Language';

  @override
  String get pasteKey => 'Paste key';

  @override
  String get setupStepProfile => 'Your profile';

  @override
  String get setupStepChambers => 'Chambers';

  @override
  String get setupStepReady => 'Ready';

  @override
  String get continueButton => 'Continue';

  @override
  String get saving => 'Saving…';

  @override
  String get setupSaveFailed => 'Couldn\'t save. Try again.';

  @override
  String get setupLoadFailed => 'Couldn\'t load your setup.';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get profileIntro => 'This is shown on the TV and on tokens.';

  @override
  String get doctorNameLabel => 'Full name, with title';

  @override
  String get specialtyLabel => 'Specialty and areas of expertise';

  @override
  String get doctorNameRequired => 'Enter your name.';

  @override
  String get chambersTitle => 'Add your chambers';

  @override
  String chambersIntro(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'chambers',
      one: 'chamber',
    );
    return 'Your license covers up to $max $_temp0. You can change these later in settings.';
  }

  @override
  String chamberQuota(int count, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'chambers',
      one: 'chamber',
    );
    return '$count of $max $_temp0';
  }

  @override
  String get chamberNameLabel => 'Chamber name';

  @override
  String get chamberLocationLabel => 'Address';

  @override
  String get addChamberButton => 'Add chamber';

  @override
  String get saveChamberButton => 'Save chamber';

  @override
  String get cancelEditButton => 'Cancel';

  @override
  String editChamberTooltip(String name) {
    return 'Edit $name';
  }

  @override
  String get chamberNameRequired => 'Enter a chamber name.';

  @override
  String chamberLimitReached(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'chambers',
      one: 'chamber',
    );
    return 'Your license covers $max $_temp0, and you\'ve added them all.';
  }

  @override
  String get addOneChamber => 'Add at least one chamber to continue.';

  @override
  String get readyTitle => 'You\'re all set';

  @override
  String get readyIntro =>
      'Your profile and chambers are saved. You can change them later in settings.';

  @override
  String get startButton => 'Start';

  @override
  String get degreesLabel => 'Degrees';

  @override
  String get addDegreeButton => 'Add degree';

  @override
  String removeDegreeTooltip(String degree) {
    return 'Remove $degree';
  }

  @override
  String get designationLabel => 'Designation';

  @override
  String get workplaceLabel => 'Hospital or institution (optional)';

  @override
  String get registrationLabel =>
      'Medical council registration number (optional)';

  @override
  String get photoLabel => 'Photo (optional)';

  @override
  String get addPhotoButton => 'Add photo';

  @override
  String get changePhotoButton => 'Change photo';

  @override
  String get removePhotoButton => 'Remove photo';

  @override
  String get photoFromGallery => 'Choose from gallery';

  @override
  String get photoFromCamera => 'Take a photo';

  @override
  String get photoFailed => 'Couldn\'t use that photo. Try another.';

  @override
  String get chamberPhoneLabel => 'Serial or contact number';

  @override
  String get chamberAddressRequired => 'Enter the chamber address.';

  @override
  String get chamberPhoneRequired => 'Enter a phone number.';

  @override
  String get backButton => 'Back';

  @override
  String get designationRequired => 'Enter your designation.';

  @override
  String get specialtyRequired => 'Enter your specialty.';

  @override
  String get degreesRequired => 'Add at least one degree.';

  @override
  String get adminGuideTitle => 'Create the admin account';

  @override
  String get adminGuideIntro =>
      'Someone you trust sets up the clinic from a laptop or phone on the same Wi-Fi.';

  @override
  String get guideStepOpen => 'Open this address';

  @override
  String get guideStepCode => 'Enter this code when asked';

  @override
  String get guideStepRegister => 'Register the admin, then sign in';

  @override
  String get guideScanHint => 'Or scan with a phone camera';

  @override
  String get guideAddressByIp => 'Or by IP address';

  @override
  String get copyAddressTooltip => 'Copy address';

  @override
  String get addressCopied => 'Address copied';

  @override
  String codeExpiresIn(String time) {
    return 'Expires in $time';
  }

  @override
  String get newCodeButton => 'New code';

  @override
  String get serverStarting => 'Starting the server…';

  @override
  String get serverRunning => 'Server running';

  @override
  String get serverNoNetwork =>
      'Connect this tablet to the clinic Wi-Fi to continue.';

  @override
  String get serverFailed => 'The server could not start.';

  @override
  String get certNote =>
      'Your browser will say the connection is not private. That is expected: the tablet uses its own certificate. Check the fingerprint, then continue.';

  @override
  String get certFingerprintLabel => 'Certificate fingerprint';

  @override
  String get readinessTitle => 'Keep the tablet ready';

  @override
  String get readinessIntro =>
      'So the queue stays reachable for patients, the TV and the web app, even with the screen locked or after a restart.';

  @override
  String get readinessBackgroundTitle => 'Run in the background';

  @override
  String get readinessBackgroundBody =>
      'Stops Android from pausing the server to save battery.';

  @override
  String get readinessNotificationsTitle => 'Show the running notice';

  @override
  String get readinessNotificationsBody =>
      'A small notice tells Android this app must keep running.';

  @override
  String get readinessAutoStartTitle => 'Start after a restart';

  @override
  String get readinessAutoStartBody =>
      'Restart the tablet once to check. This is ticked when the server starts by itself after the restart. If it stays unticked, tap the settings icon, allow AlgoritiQ to start automatically (App launch), and restart again.';

  @override
  String get readinessServiceTitle => 'Background service';

  @override
  String get readinessServiceDone => 'Running.';

  @override
  String get readinessServiceNeeded => 'Not running yet.';

  @override
  String get readinessAllow => 'Allow';

  @override
  String get readinessOpenSettings => 'Open settings';

  @override
  String get readinessConfirm => 'I\'ve done this';

  @override
  String get readinessRequired => 'Required';

  @override
  String get readinessContinueAnyway => 'Continue anyway';

  @override
  String get readinessStateDone => 'Done';

  @override
  String get readinessStateNeeded => 'Needs attention';

  @override
  String get readinessStateUnconfirmed => 'Not confirmed';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInIntro =>
      'Use the username and password of your admin account.';

  @override
  String get signInUsernameLabel => 'Username';

  @override
  String get signInPasswordLabel => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signInBusy => 'Signing in…';

  @override
  String get signInForgot => 'Forgot password?';

  @override
  String get signInFieldsRequired => 'Enter your username and password.';

  @override
  String get signInWrong => 'Wrong username or password.';

  @override
  String signInWait(int seconds) {
    return 'Too many attempts. Try again in $seconds seconds.';
  }

  @override
  String get showPasswordTooltip => 'Show password';

  @override
  String get hidePasswordTooltip => 'Hide password';

  @override
  String get signOutTooltip => 'Sign out';

  @override
  String get resetTitle => 'Reset your password';

  @override
  String get resetIntro =>
      'Enter the username of the admin account whose password you forgot.';

  @override
  String get resetKeyLabel => 'Activation key';

  @override
  String get resetKeyHint =>
      'The full key this tablet was activated with. Ask the clinic owner or the vendor. Spaces and dashes are optional.';

  @override
  String get resetNewPasswordLabel => 'New password';

  @override
  String get resetConfirmLabel => 'Confirm new password';

  @override
  String get resetPasswordHint =>
      'At least 10 characters. Must not include your username.';

  @override
  String get resetButton => 'Reset password';

  @override
  String get resetBusy => 'Resetting…';

  @override
  String get resetBack => 'Back to sign in';

  @override
  String get resetDone => 'Password changed. Sign in with your new password.';

  @override
  String get resetRefused =>
      'The activation key or the username is not correct.';

  @override
  String get resetNeedUsername => 'Enter your username.';

  @override
  String get resetNeedKey => 'Enter the activation key.';

  @override
  String get passwordNeeded => 'Choose a password.';

  @override
  String get passwordTooShort => 'Use at least 10 characters.';

  @override
  String get passwordTooLong => 'Use at most 128 characters.';

  @override
  String get passwordHasUsername => 'Password must not contain your username.';

  @override
  String get passwordsDiffer => 'Passwords do not match.';

  @override
  String resetStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get resetStepUsername => 'Enter your username';

  @override
  String get resetStepKey => 'Enter the activation key';

  @override
  String get resetStepPassword => 'Choose a new password';

  @override
  String get resetKeyTitle => 'Confirm it is you';

  @override
  String get resetKeyIntro =>
      'Enter the key this tablet was activated with. Ask the clinic owner or the vendor if you do not have it.';

  @override
  String get resetPasswordTitle => 'Choose a new password';

  @override
  String resetPasswordIntro(String username) {
    return 'The key was accepted. Choose a new password for $username.';
  }

  @override
  String get resetContinue => 'Continue';

  @override
  String get resetChecking => 'Checking the key…';

  @override
  String get resetPrevious => 'Back';

  @override
  String get resetExpired =>
      'This reset has expired. Enter the activation key again.';
}
