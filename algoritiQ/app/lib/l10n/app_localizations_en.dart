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
  String get readinessBluetoothTitle => 'Allow Bluetooth';

  @override
  String get readinessBluetoothBody =>
      'Lets the app see whether Bluetooth is on or off and ask to turn it on when needed for printing.';

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
  String get clinicDataTitle => 'Clinic data';

  @override
  String get clinicDataIntro =>
      'Start fresh on this tablet, or bring back a zip you saved from Backup in the web app.';

  @override
  String get clinicDataStartNew => 'Start new';

  @override
  String get clinicDataRestore => 'Restore from backup';

  @override
  String get clinicDataRestoreHint =>
      'Choose the zip file you downloaded from Backup on another session.';

  @override
  String get clinicDataRestoreBusy => 'Restoring…';

  @override
  String get clinicDataRestoreFailed =>
      'Could not restore this backup. Check the file and try again.';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInIntro =>
      'Use the username or email and the password of your admin account.';

  @override
  String get signInIdentifierLabel => 'Username or email';

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
  String get signInRemember => 'Remember me on this tablet';

  @override
  String get signInRememberHint =>
      'Stay signed in for 30 days. Use only on your own device.';

  @override
  String pinLoginTitle(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get pinLoginIntro => 'Enter your PIN to sign in on this tablet.';

  @override
  String get fieldPin => 'PIN';

  @override
  String get pinUsePassword => 'Use password instead';

  @override
  String get pinUsePin => 'Use PIN instead';

  @override
  String pinWrong(int count) {
    return 'That PIN is not correct. $count tries left.';
  }

  @override
  String get pinLocked => 'Too many wrong PINs. Sign in with your password.';

  @override
  String get pinRequired => 'Enter your 6-digit PIN.';

  @override
  String get adminNoticeTitle => 'Admin sign-in is on the web';

  @override
  String get adminNoticeBody =>
      'This tablet only has the receptionist screen for now. To manage the clinic as an admin, open the address below in a web browser on your phone or laptop and sign in there. Admin sign-in on the tablet may come in a later update.';

  @override
  String get adminNoticeSignOut =>
      'Press OK to go back to the sign-in screen. You are also signed out when this app is closed.';

  @override
  String get adminNoticeOk => 'OK';

  @override
  String get signInFieldsRequired =>
      'Enter your username or email and your password.';

  @override
  String get signInWrong => 'Wrong username, email or password.';

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
      'At least 8 characters. Must not include your username.';

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
  String get passwordTooShort => 'Use at least 8 characters.';

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

  @override
  String get navPrimaryLabel => 'Dashboard sections';

  @override
  String get navBoard => 'Board';

  @override
  String get navCloseMenu => 'Close menu';

  @override
  String get navOpenMenu => 'Open menu';

  @override
  String boardGreeting(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get workScopeTitle => 'Where are you working?';

  @override
  String get workScopeIntroChamber =>
      'Choose a chamber to open the board and patient queue.';

  @override
  String get workScopeIntroDoctor =>
      'Choose a doctor to open the board and patient queue.';

  @override
  String get workScopeEmpty =>
      'You are not assigned to any chamber yet. Ask your administrator to assign you.';

  @override
  String workScopeActive(String name) {
    return 'Working at $name. Run the counter from here.';
  }

  @override
  String get workScopeSidebarLabel => 'Working at';

  @override
  String get navChangeWorkScope => 'Change chamber';

  @override
  String get boardIntro =>
      'Run the counter from here. Live queue tools will appear on this board.';

  @override
  String get boardServerTitle => 'Clinic server';

  @override
  String get boardServerOk =>
      'This tablet is serving the web app and other devices.';

  @override
  String get boardServerStarting => 'Starting the clinic server…';

  @override
  String get boardServerFailed =>
      'The clinic server could not start. Check readiness settings or restart the app.';

  @override
  String get boardAccountTitle => 'Your account';

  @override
  String get fieldRole => 'Role';

  @override
  String get fieldUsername => 'Username';

  @override
  String get fieldEmail => 'Email';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleReceptionist => 'Receptionist';

  @override
  String get boardQueueTitle => 'Patient queue';

  @override
  String get boardQueueSoon =>
      'Live queue tools will appear here once they are ready.';

  @override
  String get themeLight => 'Switch to light theme';

  @override
  String get themeDark => 'Switch to dark theme';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsIntro =>
      'Your profile photo, name, password, and PIN for this device.';

  @override
  String get userMenuLabel => 'Account menu';

  @override
  String get signOut => 'Sign out';

  @override
  String get signingOut => 'Signing out…';

  @override
  String get fieldFirstName => 'First name';

  @override
  String get fieldLastName => 'Last name';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get settingsPhotoTitle => 'Profile photo';

  @override
  String get settingsPhotoHelp =>
      'JPEG, PNG or WebP. The picture is stored on this tablet.';

  @override
  String get settingsProfileTitle => 'Personal information';

  @override
  String get settingsProfileIntro => 'Your name and contact details.';

  @override
  String get settingsSave => 'Save changes';

  @override
  String get settingsSaving => 'Saving…';

  @override
  String get settingsSaved => 'Your changes were saved.';

  @override
  String get settingsUsernameNote => 'Your username cannot be changed.';

  @override
  String get settingsFixFields => 'Fix the highlighted fields.';

  @override
  String get settingsFirstNameRequired => 'Enter your first name.';

  @override
  String get settingsNameTooLong => 'Use shorter names.';

  @override
  String get settingsEmailInvalid => 'Enter a valid email address.';

  @override
  String get settingsEmailTaken => 'That email is already in use.';

  @override
  String get settingsPhoneInvalid => 'Enter a valid phone number.';

  @override
  String get settingsPhotoSaved => 'Photo updated.';

  @override
  String get settingsPhotoRemoved => 'Photo removed.';

  @override
  String get settingsPhotoFailed => 'The photo could not be saved. Try again.';

  @override
  String get securityCardTitle => 'Password and PIN';

  @override
  String get securityCardIntro =>
      'Change your password or set a quick sign-in PIN on this tablet. Changing your password removes every PIN.';

  @override
  String get passwordCardTitle => 'Password';

  @override
  String get passwordCardIntro =>
      'Choose a new password. Your other sign-ins will end.';

  @override
  String get passwordChangeButton => 'Change password';

  @override
  String get passwordModalTitle => 'Change your password';

  @override
  String get passwordCurrentLabel => 'Current password';

  @override
  String get passwordNewLabel => 'New password';

  @override
  String get passwordConfirmLabel => 'Confirm new password';

  @override
  String get passwordChanged =>
      'Password changed. Your other sign-ins were ended.';

  @override
  String get passwordCurrentWrong => 'Current password is not correct.';

  @override
  String get passwordNewSame => 'Choose a different password.';

  @override
  String get pinCardTitle => 'Quick sign-in PIN';

  @override
  String get pinCardIntro =>
      'Sign in on this tablet with a 6-digit PIN instead of your password.';

  @override
  String get pinNone => 'No PIN is set on this tablet yet.';

  @override
  String get pinThisTablet => 'This tablet';

  @override
  String get pinSetButton => 'Set PIN for this tablet';

  @override
  String get pinChangeButton => 'Change PIN';

  @override
  String get pinRemove => 'Remove';

  @override
  String get pinRemoved => 'PIN removed.';

  @override
  String get pinSetDone => 'PIN saved for this tablet.';

  @override
  String get pinLoadFailed => 'Could not load PIN devices.';

  @override
  String get pinModalTitle => 'Set a PIN';

  @override
  String get pinModalPasswordLabel => 'Your password';

  @override
  String get pinModalPinLabel => 'New PIN';

  @override
  String get pinModalConfirmLabel => 'Confirm PIN';

  @override
  String get pinModalSubmit => 'Save PIN';

  @override
  String get pinModalBusy => 'Saving…';

  @override
  String get pinFormatInvalid => 'Enter a 6-digit PIN.';

  @override
  String get pinWeak => 'Choose a PIN that is not too easy to guess.';

  @override
  String get pinPasswordWrong => 'Password is not correct.';

  @override
  String get pinPinsDiffer => 'PINs do not match.';

  @override
  String get navConnectivity => 'Connectivity';

  @override
  String get toastDismiss => 'Dismiss message';

  @override
  String get connectivityTitle => 'Connectivity';

  @override
  String get connectivityIntro =>
      'Check that the printer and the TV screen are connected.';

  @override
  String get printerTitle => 'Printer';

  @override
  String get printerStatusConnected => 'Connected';

  @override
  String get printerStatusConnecting => 'Connecting…';

  @override
  String get printerStatusDisconnected => 'Not connected';

  @override
  String get printerStatusNotPaired => 'No printer set up';

  @override
  String get printerStatusBtOff => 'Bluetooth is off';

  @override
  String get printerStatusBtDenied => 'Bluetooth is not allowed';

  @override
  String get printerStatusBtMissing => 'No Bluetooth on this tablet';

  @override
  String get printerBodyNotPaired =>
      'Switch the printer on and choose it from the list. You only do this once.';

  @override
  String get printerBodyDisconnected =>
      'Trying to connect by itself. Make sure the printer is on and close by.';

  @override
  String get printerBodyConnected => 'Ready to print tokens.';

  @override
  String get printerBodyBtOff =>
      'Turn Bluetooth on so the tablet can reach the printer.';

  @override
  String get printerBodyBtDenied =>
      'Allow Bluetooth for this app so the tablet can reach the printer.';

  @override
  String get printerBodyBtMissing =>
      'This tablet cannot connect to a Bluetooth printer.';

  @override
  String printerRetryIn(int seconds) {
    return 'Trying again in $seconds s';
  }

  @override
  String get printerActionChoose => 'Choose printer';

  @override
  String get printerActionRetry => 'Connect now';

  @override
  String get printerActionTest => 'Test print';

  @override
  String get printerActionAllow => 'Allow Bluetooth';

  @override
  String get printerActionTurnOn => 'Turn Bluetooth on';

  @override
  String get printerPickerTitle => 'Choose your printer';

  @override
  String get printerPickerBody =>
      'Switch the printer on and keep it close. Printers nearby appear below.';

  @override
  String get printerPickerPairHint =>
      'Android may ask for a pairing code. For most printers it is 0000 or 1234.';

  @override
  String get printerPickerEmpty => 'No printer found yet.';

  @override
  String get printerPickerScanning => 'Looking for printers…';

  @override
  String get printerPickerScanAgain => 'Search again';

  @override
  String get printerPickerPairedTag => 'Paired';

  @override
  String get printerToastConnected => 'Printer connected.';

  @override
  String get printerToastLost =>
      'Printer disconnected. The tablet is reconnecting.';

  @override
  String get printerToastRejected =>
      'Pairing was cancelled or the code was wrong.';

  @override
  String get printerToastChooseFailed =>
      'Could not connect to the printer. Check that it is on and close by.';

  @override
  String get printerToastConnectFailed =>
      'Still cannot reach the printer. The tablet will keep trying.';

  @override
  String get printerToastTestOk => 'Test token printed.';

  @override
  String get printerToastTestFailed =>
      'The test token did not print. Check paper and cover.';

  @override
  String get tvTitle => 'TV screen';

  @override
  String get tvStatus => 'Coming soon';

  @override
  String get tvBody => 'You will check and connect the waiting-room TV here.';

  @override
  String get dialogClose => 'Close';

  @override
  String get printerTestConfirmTitle => 'Print a test token?';

  @override
  String get printerTestConfirmBody =>
      'A sample token with a dummy number will print, using the chamber and doctor details set up here.';

  @override
  String get printerTestConfirmAction => 'Print test token';

  @override
  String get printerToastNoDetails =>
      'The chamber or doctor details for the token could not be found.';
}
