import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @activationTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate this device'**
  String get activationTitle;

  /// No description provided for @activationIntro.
  ///
  /// In en, this message translates to:
  /// **'Send this device code to your provider to get an activation key.'**
  String get activationIntro;

  /// No description provided for @deviceCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Device code'**
  String get deviceCodeLabel;

  /// No description provided for @copyDeviceCode.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyDeviceCode;

  /// No description provided for @deviceCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Device code copied'**
  String get deviceCodeCopied;

  /// No description provided for @activationKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Activation key'**
  String get activationKeyLabel;

  /// No description provided for @activationKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste or type the key'**
  String get activationKeyHint;

  /// No description provided for @activateButton.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateButton;

  /// No description provided for @licenseErrorMalformed.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t look like an activation key. Check it and try again.'**
  String get licenseErrorMalformed;

  /// No description provided for @licenseErrorUnknownKey.
  ///
  /// In en, this message translates to:
  /// **'This version of the app doesn\'t recognise this key.'**
  String get licenseErrorUnknownKey;

  /// No description provided for @licenseErrorBadSignature.
  ///
  /// In en, this message translates to:
  /// **'This key is not valid.'**
  String get licenseErrorBadSignature;

  /// No description provided for @licenseErrorWrongDevice.
  ///
  /// In en, this message translates to:
  /// **'This key was issued for a different device.'**
  String get licenseErrorWrongDevice;

  /// No description provided for @licenseErrorExpired.
  ///
  /// In en, this message translates to:
  /// **'Your license has expired. Enter a renewed key to continue.'**
  String get licenseErrorExpired;

  /// No description provided for @deviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read this device\'s identity.'**
  String get deviceUnavailable;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryButton;

  /// No description provided for @licenseSummaryDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor license · up to {chambers} {chambers, plural, =1{chamber} other{chambers}}'**
  String licenseSummaryDoctor(int chambers);

  /// No description provided for @licenseSummaryChamber.
  ///
  /// In en, this message translates to:
  /// **'Chamber license · up to {doctors} {doctors, plural, =1{doctor} other{doctors}}'**
  String licenseSummaryChamber(int doctors);

  /// No description provided for @licenseValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String licenseValidUntil(DateTime date);

  /// No description provided for @licenseNoExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry'**
  String get licenseNoExpiry;

  /// No description provided for @licenseGraceNotice.
  ///
  /// In en, this message translates to:
  /// **'License expired. Enter a renewed key soon to avoid interruption.'**
  String get licenseGraceNotice;

  /// No description provided for @activationStepCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get activationStepCopy;

  /// No description provided for @activationStepGet.
  ///
  /// In en, this message translates to:
  /// **'Get key'**
  String get activationStepGet;

  /// No description provided for @activationStepEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter key'**
  String get activationStepEnter;

  /// No description provided for @stepDone.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get stepDone;

  /// No description provided for @stepCurrent.
  ///
  /// In en, this message translates to:
  /// **'current step'**
  String get stepCurrent;

  /// No description provided for @activationFooter.
  ///
  /// In en, this message translates to:
  /// **'Your license is tied to this device and works offline.'**
  String get activationFooter;

  /// No description provided for @activating.
  ///
  /// In en, this message translates to:
  /// **'Activating…'**
  String get activating;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @pasteKey.
  ///
  /// In en, this message translates to:
  /// **'Paste key'**
  String get pasteKey;

  /// No description provided for @setupStepProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get setupStepProfile;

  /// No description provided for @setupStepChambers.
  ///
  /// In en, this message translates to:
  /// **'Chambers'**
  String get setupStepChambers;

  /// No description provided for @setupStepReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get setupStepReady;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @setupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Try again.'**
  String get setupSaveFailed;

  /// No description provided for @setupLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your setup.'**
  String get setupLoadFailed;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileTitle;

  /// No description provided for @profileIntro.
  ///
  /// In en, this message translates to:
  /// **'This is shown on the TV and on tokens.'**
  String get profileIntro;

  /// No description provided for @doctorNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name, with title'**
  String get doctorNameLabel;

  /// No description provided for @specialtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialty and areas of expertise'**
  String get specialtyLabel;

  /// No description provided for @doctorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get doctorNameRequired;

  /// No description provided for @chambersTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your chambers'**
  String get chambersTitle;

  /// No description provided for @chambersIntro.
  ///
  /// In en, this message translates to:
  /// **'Your license covers up to {max} {max, plural, =1{chamber} other{chambers}}. You can change these later in settings.'**
  String chambersIntro(int max);

  /// No description provided for @chamberQuota.
  ///
  /// In en, this message translates to:
  /// **'{count} of {max} {max, plural, =1{chamber} other{chambers}}'**
  String chamberQuota(int count, int max);

  /// No description provided for @chamberNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Chamber name'**
  String get chamberNameLabel;

  /// No description provided for @chamberLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get chamberLocationLabel;

  /// No description provided for @addChamberButton.
  ///
  /// In en, this message translates to:
  /// **'Add chamber'**
  String get addChamberButton;

  /// No description provided for @saveChamberButton.
  ///
  /// In en, this message translates to:
  /// **'Save chamber'**
  String get saveChamberButton;

  /// No description provided for @cancelEditButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelEditButton;

  /// No description provided for @editChamberTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String editChamberTooltip(String name);

  /// No description provided for @chamberNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a chamber name.'**
  String get chamberNameRequired;

  /// No description provided for @chamberLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Your license covers {max} {max, plural, =1{chamber} other{chambers}}, and you\'ve added them all.'**
  String chamberLimitReached(int max);

  /// No description provided for @addOneChamber.
  ///
  /// In en, this message translates to:
  /// **'Add at least one chamber to continue.'**
  String get addOneChamber;

  /// No description provided for @readyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set'**
  String get readyTitle;

  /// No description provided for @readyIntro.
  ///
  /// In en, this message translates to:
  /// **'Your profile and chambers are saved. You can change them later in settings.'**
  String get readyIntro;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @degreesLabel.
  ///
  /// In en, this message translates to:
  /// **'Degrees'**
  String get degreesLabel;

  /// No description provided for @addDegreeButton.
  ///
  /// In en, this message translates to:
  /// **'Add degree'**
  String get addDegreeButton;

  /// No description provided for @removeDegreeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove {degree}'**
  String removeDegreeTooltip(String degree);

  /// No description provided for @designationLabel.
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get designationLabel;

  /// No description provided for @workplaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Hospital or institution (optional)'**
  String get workplaceLabel;

  /// No description provided for @registrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Medical council registration number (optional)'**
  String get registrationLabel;

  /// No description provided for @photoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo (optional)'**
  String get photoLabel;

  /// No description provided for @addPhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhotoButton;

  /// No description provided for @changePhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhotoButton;

  /// No description provided for @removePhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhotoButton;

  /// No description provided for @photoFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photoFromGallery;

  /// No description provided for @photoFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get photoFromCamera;

  /// No description provided for @photoFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t use that photo. Try another.'**
  String get photoFailed;

  /// No description provided for @chamberPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Serial or contact number'**
  String get chamberPhoneLabel;

  /// No description provided for @chamberAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the chamber address.'**
  String get chamberAddressRequired;

  /// No description provided for @chamberPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number.'**
  String get chamberPhoneRequired;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @designationRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your designation.'**
  String get designationRequired;

  /// No description provided for @specialtyRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your specialty.'**
  String get specialtyRequired;

  /// No description provided for @degreesRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one degree.'**
  String get degreesRequired;

  /// No description provided for @adminGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Create the admin account'**
  String get adminGuideTitle;

  /// No description provided for @adminGuideIntro.
  ///
  /// In en, this message translates to:
  /// **'Someone you trust sets up the clinic from a laptop or phone on the same Wi-Fi.'**
  String get adminGuideIntro;

  /// No description provided for @guideStepOpen.
  ///
  /// In en, this message translates to:
  /// **'Open this address'**
  String get guideStepOpen;

  /// No description provided for @guideStepCode.
  ///
  /// In en, this message translates to:
  /// **'Enter this code when asked'**
  String get guideStepCode;

  /// No description provided for @guideStepRegister.
  ///
  /// In en, this message translates to:
  /// **'Register the admin, then sign in'**
  String get guideStepRegister;

  /// No description provided for @guideScanHint.
  ///
  /// In en, this message translates to:
  /// **'Or scan with a phone camera'**
  String get guideScanHint;

  /// No description provided for @guideAddressByIp.
  ///
  /// In en, this message translates to:
  /// **'Or by IP address'**
  String get guideAddressByIp;

  /// No description provided for @copyAddressTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get copyAddressTooltip;

  /// No description provided for @addressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get addressCopied;

  /// No description provided for @codeExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {time}'**
  String codeExpiresIn(String time);

  /// No description provided for @newCodeButton.
  ///
  /// In en, this message translates to:
  /// **'New code'**
  String get newCodeButton;

  /// No description provided for @serverStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting the server…'**
  String get serverStarting;

  /// No description provided for @serverRunning.
  ///
  /// In en, this message translates to:
  /// **'Server running'**
  String get serverRunning;

  /// No description provided for @serverNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connect this tablet to the clinic Wi-Fi to continue.'**
  String get serverNoNetwork;

  /// No description provided for @serverFailed.
  ///
  /// In en, this message translates to:
  /// **'The server could not start.'**
  String get serverFailed;

  /// No description provided for @certNote.
  ///
  /// In en, this message translates to:
  /// **'Your browser will say the connection is not private. That is expected: the tablet uses its own certificate. Check the fingerprint, then continue.'**
  String get certNote;

  /// No description provided for @certFingerprintLabel.
  ///
  /// In en, this message translates to:
  /// **'Certificate fingerprint'**
  String get certFingerprintLabel;

  /// No description provided for @readinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the tablet ready'**
  String get readinessTitle;

  /// No description provided for @readinessIntro.
  ///
  /// In en, this message translates to:
  /// **'So the queue stays reachable for patients, the TV and the web app, even with the screen locked or after a restart.'**
  String get readinessIntro;

  /// No description provided for @readinessBackgroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Run in the background'**
  String get readinessBackgroundTitle;

  /// No description provided for @readinessBackgroundBody.
  ///
  /// In en, this message translates to:
  /// **'Stops Android from pausing the server to save battery.'**
  String get readinessBackgroundBody;

  /// No description provided for @readinessNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Show the running notice'**
  String get readinessNotificationsTitle;

  /// No description provided for @readinessNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'A small notice tells Android this app must keep running.'**
  String get readinessNotificationsBody;

  /// No description provided for @readinessBluetoothTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Bluetooth'**
  String get readinessBluetoothTitle;

  /// No description provided for @readinessBluetoothBody.
  ///
  /// In en, this message translates to:
  /// **'Lets the app see whether Bluetooth is on or off and ask to turn it on when needed for printing.'**
  String get readinessBluetoothBody;

  /// No description provided for @readinessAutoStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start after a restart'**
  String get readinessAutoStartTitle;

  /// No description provided for @readinessAutoStartBody.
  ///
  /// In en, this message translates to:
  /// **'Restart the tablet once to check. This is ticked when the server starts by itself after the restart. If it stays unticked, tap the settings icon, allow AlgoritiQ to start automatically (App launch), and restart again.'**
  String get readinessAutoStartBody;

  /// No description provided for @readinessServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Background service'**
  String get readinessServiceTitle;

  /// No description provided for @readinessServiceDone.
  ///
  /// In en, this message translates to:
  /// **'Running.'**
  String get readinessServiceDone;

  /// No description provided for @readinessServiceNeeded.
  ///
  /// In en, this message translates to:
  /// **'Not running yet.'**
  String get readinessServiceNeeded;

  /// No description provided for @readinessAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get readinessAllow;

  /// No description provided for @readinessOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get readinessOpenSettings;

  /// No description provided for @readinessConfirm.
  ///
  /// In en, this message translates to:
  /// **'I\'ve done this'**
  String get readinessConfirm;

  /// No description provided for @readinessRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get readinessRequired;

  /// No description provided for @readinessContinueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get readinessContinueAnyway;

  /// No description provided for @readinessStateDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get readinessStateDone;

  /// No description provided for @readinessStateNeeded.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get readinessStateNeeded;

  /// No description provided for @readinessStateUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed'**
  String get readinessStateUnconfirmed;

  /// No description provided for @clinicDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinic data'**
  String get clinicDataTitle;

  /// No description provided for @clinicDataIntro.
  ///
  /// In en, this message translates to:
  /// **'Start fresh on this tablet, or bring back a zip you saved from Backup in the web app.'**
  String get clinicDataIntro;

  /// No description provided for @clinicDataStartNew.
  ///
  /// In en, this message translates to:
  /// **'Start new'**
  String get clinicDataStartNew;

  /// No description provided for @clinicDataRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get clinicDataRestore;

  /// No description provided for @clinicDataRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the zip file you downloaded from Backup on another session.'**
  String get clinicDataRestoreHint;

  /// No description provided for @clinicDataRestoreBusy.
  ///
  /// In en, this message translates to:
  /// **'Restoring…'**
  String get clinicDataRestoreBusy;

  /// No description provided for @clinicDataRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore this backup. Check the file and try again.'**
  String get clinicDataRestoreFailed;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signInIntro.
  ///
  /// In en, this message translates to:
  /// **'Use the username or email and the password of your admin account.'**
  String get signInIntro;

  /// No description provided for @signInIdentifierLabel.
  ///
  /// In en, this message translates to:
  /// **'Username or email'**
  String get signInIdentifierLabel;

  /// No description provided for @signInUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get signInUsernameLabel;

  /// No description provided for @signInPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signInPasswordLabel;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @signInBusy.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signInBusy;

  /// No description provided for @signInForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get signInForgot;

  /// No description provided for @signInRemember.
  ///
  /// In en, this message translates to:
  /// **'Remember me on this tablet'**
  String get signInRemember;

  /// No description provided for @signInRememberHint.
  ///
  /// In en, this message translates to:
  /// **'Stay signed in for 30 days. Use only on your own device.'**
  String get signInRememberHint;

  /// No description provided for @pinLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String pinLoginTitle(String name);

  /// No description provided for @pinLoginIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to sign in on this tablet.'**
  String get pinLoginIntro;

  /// No description provided for @fieldPin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get fieldPin;

  /// No description provided for @pinUsePassword.
  ///
  /// In en, this message translates to:
  /// **'Use password instead'**
  String get pinUsePassword;

  /// No description provided for @pinUsePin.
  ///
  /// In en, this message translates to:
  /// **'Use PIN instead'**
  String get pinUsePin;

  /// No description provided for @pinWrong.
  ///
  /// In en, this message translates to:
  /// **'That PIN is not correct. {count} tries left.'**
  String pinWrong(int count);

  /// No description provided for @pinLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong PINs. Sign in with your password.'**
  String get pinLocked;

  /// No description provided for @pinRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your 6-digit PIN.'**
  String get pinRequired;

  /// No description provided for @adminNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin sign-in is on the web'**
  String get adminNoticeTitle;

  /// No description provided for @adminNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'This tablet only has the receptionist screen for now. To manage the clinic as an admin, open the address below in a web browser on your phone or laptop and sign in there. Admin sign-in on the tablet may come in a later update.'**
  String get adminNoticeBody;

  /// No description provided for @adminNoticeSignOut.
  ///
  /// In en, this message translates to:
  /// **'Press OK to go back to the sign-in screen. You are also signed out when this app is closed.'**
  String get adminNoticeSignOut;

  /// No description provided for @adminNoticeOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get adminNoticeOk;

  /// No description provided for @signInFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your username or email and your password.'**
  String get signInFieldsRequired;

  /// No description provided for @signInWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong username, email or password.'**
  String get signInWrong;

  /// No description provided for @signInWait.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds} seconds.'**
  String signInWait(int seconds);

  /// No description provided for @showPasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPasswordTooltip;

  /// No description provided for @hidePasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePasswordTooltip;

  /// No description provided for @signOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutTooltip;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetTitle;

  /// No description provided for @resetIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the username of the admin account whose password you forgot.'**
  String get resetIntro;

  /// No description provided for @resetKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Activation key'**
  String get resetKeyLabel;

  /// No description provided for @resetKeyHint.
  ///
  /// In en, this message translates to:
  /// **'The full key this tablet was activated with. Ask the clinic owner or the vendor. Spaces and dashes are optional.'**
  String get resetKeyHint;

  /// No description provided for @resetNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get resetNewPasswordLabel;

  /// No description provided for @resetConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get resetConfirmLabel;

  /// No description provided for @resetPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters. Must not include your username.'**
  String get resetPasswordHint;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetButton;

  /// No description provided for @resetBusy.
  ///
  /// In en, this message translates to:
  /// **'Resetting…'**
  String get resetBusy;

  /// No description provided for @resetBack.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get resetBack;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Sign in with your new password.'**
  String get resetDone;

  /// No description provided for @resetRefused.
  ///
  /// In en, this message translates to:
  /// **'The activation key or the username is not correct.'**
  String get resetRefused;

  /// No description provided for @resetNeedUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username.'**
  String get resetNeedUsername;

  /// No description provided for @resetNeedKey.
  ///
  /// In en, this message translates to:
  /// **'Enter the activation key.'**
  String get resetNeedKey;

  /// No description provided for @passwordNeeded.
  ///
  /// In en, this message translates to:
  /// **'Choose a password.'**
  String get passwordNeeded;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get passwordTooShort;

  /// No description provided for @passwordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use at most 128 characters.'**
  String get passwordTooLong;

  /// No description provided for @passwordHasUsername.
  ///
  /// In en, this message translates to:
  /// **'Password must not contain your username.'**
  String get passwordHasUsername;

  /// No description provided for @passwordsDiffer.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDiffer;

  /// No description provided for @resetStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String resetStepOf(int current, int total);

  /// No description provided for @resetStepUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get resetStepUsername;

  /// No description provided for @resetStepKey.
  ///
  /// In en, this message translates to:
  /// **'Enter the activation key'**
  String get resetStepKey;

  /// No description provided for @resetStepPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get resetStepPassword;

  /// No description provided for @resetKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm it is you'**
  String get resetKeyTitle;

  /// No description provided for @resetKeyIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the key this tablet was activated with. Ask the clinic owner or the vendor if you do not have it.'**
  String get resetKeyIntro;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'The key was accepted. Choose a new password for {username}.'**
  String resetPasswordIntro(String username);

  /// No description provided for @resetContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get resetContinue;

  /// No description provided for @resetChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking the key…'**
  String get resetChecking;

  /// No description provided for @resetPrevious.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get resetPrevious;

  /// No description provided for @resetExpired.
  ///
  /// In en, this message translates to:
  /// **'This reset has expired. Enter the activation key again.'**
  String get resetExpired;

  /// No description provided for @navPrimaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Dashboard sections'**
  String get navPrimaryLabel;

  /// No description provided for @navBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get navBoard;

  /// No description provided for @navCloseMenu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get navCloseMenu;

  /// No description provided for @navOpenMenu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get navOpenMenu;

  /// No description provided for @boardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String boardGreeting(String name);

  /// No description provided for @workScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you working?'**
  String get workScopeTitle;

  /// No description provided for @workScopeIntroChamber.
  ///
  /// In en, this message translates to:
  /// **'Choose a chamber to open the board and patient queue.'**
  String get workScopeIntroChamber;

  /// No description provided for @workScopeIntroDoctor.
  ///
  /// In en, this message translates to:
  /// **'Choose a doctor to open the board and patient queue.'**
  String get workScopeIntroDoctor;

  /// No description provided for @workScopeEmpty.
  ///
  /// In en, this message translates to:
  /// **'You are not assigned to any chamber yet. Ask your administrator to assign you.'**
  String get workScopeEmpty;

  /// No description provided for @workScopeActive.
  ///
  /// In en, this message translates to:
  /// **'Working at {name}. Run the counter from here.'**
  String workScopeActive(String name);

  /// No description provided for @workScopeSidebarLabel.
  ///
  /// In en, this message translates to:
  /// **'Working at'**
  String get workScopeSidebarLabel;

  /// No description provided for @navChangeWorkScope.
  ///
  /// In en, this message translates to:
  /// **'Change chamber'**
  String get navChangeWorkScope;

  /// No description provided for @boardIntro.
  ///
  /// In en, this message translates to:
  /// **'Run the counter from here. Live queue tools will appear on this board.'**
  String get boardIntro;

  /// No description provided for @boardServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinic server'**
  String get boardServerTitle;

  /// No description provided for @boardServerOk.
  ///
  /// In en, this message translates to:
  /// **'This tablet is serving the web app and other devices.'**
  String get boardServerOk;

  /// No description provided for @boardServerStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting the clinic server…'**
  String get boardServerStarting;

  /// No description provided for @boardServerFailed.
  ///
  /// In en, this message translates to:
  /// **'The clinic server could not start. Check readiness settings or restart the app.'**
  String get boardServerFailed;

  /// No description provided for @boardAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get boardAccountTitle;

  /// No description provided for @fieldRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get fieldRole;

  /// No description provided for @fieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get fieldUsername;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @roleReceptionist.
  ///
  /// In en, this message translates to:
  /// **'Receptionist'**
  String get roleReceptionist;

  /// No description provided for @boardQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient queue'**
  String get boardQueueTitle;

  /// No description provided for @boardQueueSoon.
  ///
  /// In en, this message translates to:
  /// **'Live queue tools will appear here once they are ready.'**
  String get boardQueueSoon;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Switch to light theme'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get themeDark;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsIntro.
  ///
  /// In en, this message translates to:
  /// **'Your profile photo, name, password, and PIN for this device.'**
  String get settingsIntro;

  /// No description provided for @userMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Account menu'**
  String get userMenuLabel;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signingOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out…'**
  String get signingOut;

  /// No description provided for @fieldFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get fieldFirstName;

  /// No description provided for @fieldLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get fieldLastName;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldPhone;

  /// No description provided for @settingsPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get settingsPhotoTitle;

  /// No description provided for @settingsPhotoHelp.
  ///
  /// In en, this message translates to:
  /// **'JPEG, PNG or WebP. The picture is stored on this tablet.'**
  String get settingsPhotoHelp;

  /// No description provided for @settingsProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get settingsProfileTitle;

  /// No description provided for @settingsProfileIntro.
  ///
  /// In en, this message translates to:
  /// **'Your name and contact details.'**
  String get settingsProfileIntro;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get settingsSave;

  /// No description provided for @settingsSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get settingsSaving;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Your changes were saved.'**
  String get settingsSaved;

  /// No description provided for @settingsUsernameNote.
  ///
  /// In en, this message translates to:
  /// **'Your username cannot be changed.'**
  String get settingsUsernameNote;

  /// No description provided for @settingsFixFields.
  ///
  /// In en, this message translates to:
  /// **'Fix the highlighted fields.'**
  String get settingsFixFields;

  /// No description provided for @settingsFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name.'**
  String get settingsFirstNameRequired;

  /// No description provided for @settingsNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use shorter names.'**
  String get settingsNameTooLong;

  /// No description provided for @settingsEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get settingsEmailInvalid;

  /// No description provided for @settingsEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'That email is already in use.'**
  String get settingsEmailTaken;

  /// No description provided for @settingsPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get settingsPhoneInvalid;

  /// No description provided for @settingsPhotoSaved.
  ///
  /// In en, this message translates to:
  /// **'Photo updated.'**
  String get settingsPhotoSaved;

  /// No description provided for @settingsPhotoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Photo removed.'**
  String get settingsPhotoRemoved;

  /// No description provided for @settingsPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be saved. Try again.'**
  String get settingsPhotoFailed;

  /// No description provided for @securityCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Password and PIN'**
  String get securityCardTitle;

  /// No description provided for @securityCardIntro.
  ///
  /// In en, this message translates to:
  /// **'Change your password or set a quick sign-in PIN on this tablet. Changing your password removes every PIN.'**
  String get securityCardIntro;

  /// No description provided for @passwordCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordCardTitle;

  /// No description provided for @passwordCardIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password. Your other sign-ins will end.'**
  String get passwordCardIntro;

  /// No description provided for @passwordChangeButton.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get passwordChangeButton;

  /// No description provided for @passwordModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Change your password'**
  String get passwordModalTitle;

  /// No description provided for @passwordCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get passwordCurrentLabel;

  /// No description provided for @passwordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNewLabel;

  /// No description provided for @passwordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get passwordConfirmLabel;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Your other sign-ins were ended.'**
  String get passwordChanged;

  /// No description provided for @passwordCurrentWrong.
  ///
  /// In en, this message translates to:
  /// **'Current password is not correct.'**
  String get passwordCurrentWrong;

  /// No description provided for @passwordNewSame.
  ///
  /// In en, this message translates to:
  /// **'Choose a different password.'**
  String get passwordNewSame;

  /// No description provided for @pinCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick sign-in PIN'**
  String get pinCardTitle;

  /// No description provided for @pinCardIntro.
  ///
  /// In en, this message translates to:
  /// **'Sign in on this tablet with a 6-digit PIN instead of your password.'**
  String get pinCardIntro;

  /// No description provided for @pinNone.
  ///
  /// In en, this message translates to:
  /// **'No PIN is set on this tablet yet.'**
  String get pinNone;

  /// No description provided for @pinThisTablet.
  ///
  /// In en, this message translates to:
  /// **'This tablet'**
  String get pinThisTablet;

  /// No description provided for @pinSetButton.
  ///
  /// In en, this message translates to:
  /// **'Set PIN for this tablet'**
  String get pinSetButton;

  /// No description provided for @pinChangeButton.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get pinChangeButton;

  /// No description provided for @pinRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get pinRemove;

  /// No description provided for @pinRemoved.
  ///
  /// In en, this message translates to:
  /// **'PIN removed.'**
  String get pinRemoved;

  /// No description provided for @pinSetDone.
  ///
  /// In en, this message translates to:
  /// **'PIN saved for this tablet.'**
  String get pinSetDone;

  /// No description provided for @pinLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load PIN devices.'**
  String get pinLoadFailed;

  /// No description provided for @pinModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN'**
  String get pinModalTitle;

  /// No description provided for @pinModalPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get pinModalPasswordLabel;

  /// No description provided for @pinModalPinLabel.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get pinModalPinLabel;

  /// No description provided for @pinModalConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get pinModalConfirmLabel;

  /// No description provided for @pinModalSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save PIN'**
  String get pinModalSubmit;

  /// No description provided for @pinModalBusy.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get pinModalBusy;

  /// No description provided for @pinFormatInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a 6-digit PIN.'**
  String get pinFormatInvalid;

  /// No description provided for @pinWeak.
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN that is not too easy to guess.'**
  String get pinWeak;

  /// No description provided for @pinPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'Password is not correct.'**
  String get pinPasswordWrong;

  /// No description provided for @pinPinsDiffer.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match.'**
  String get pinPinsDiffer;

  /// No description provided for @navConnectivity.
  ///
  /// In en, this message translates to:
  /// **'Connectivity'**
  String get navConnectivity;

  /// No description provided for @toastDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss message'**
  String get toastDismiss;

  /// No description provided for @connectivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Connectivity'**
  String get connectivityTitle;

  /// No description provided for @connectivityIntro.
  ///
  /// In en, this message translates to:
  /// **'Check that the printer and the TV screen are connected.'**
  String get connectivityIntro;

  /// No description provided for @printerTitle.
  ///
  /// In en, this message translates to:
  /// **'Printer'**
  String get printerTitle;

  /// No description provided for @printerStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get printerStatusConnected;

  /// No description provided for @printerStatusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get printerStatusConnecting;

  /// No description provided for @printerStatusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get printerStatusDisconnected;

  /// No description provided for @printerStatusNotPaired.
  ///
  /// In en, this message translates to:
  /// **'No printer set up'**
  String get printerStatusNotPaired;

  /// No description provided for @printerStatusBtOff.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is off'**
  String get printerStatusBtOff;

  /// No description provided for @printerStatusBtDenied.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is not allowed'**
  String get printerStatusBtDenied;

  /// No description provided for @printerStatusBtMissing.
  ///
  /// In en, this message translates to:
  /// **'No Bluetooth on this tablet'**
  String get printerStatusBtMissing;

  /// No description provided for @printerBodyNotPaired.
  ///
  /// In en, this message translates to:
  /// **'Switch the printer on and choose it from the list. You only do this once.'**
  String get printerBodyNotPaired;

  /// No description provided for @printerBodyDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Trying to connect by itself. Make sure the printer is on and close by.'**
  String get printerBodyDisconnected;

  /// No description provided for @printerBodyConnected.
  ///
  /// In en, this message translates to:
  /// **'Ready to print tokens.'**
  String get printerBodyConnected;

  /// No description provided for @printerBodyBtOff.
  ///
  /// In en, this message translates to:
  /// **'Turn Bluetooth on so the tablet can reach the printer.'**
  String get printerBodyBtOff;

  /// No description provided for @printerBodyBtDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow Bluetooth for this app so the tablet can reach the printer.'**
  String get printerBodyBtDenied;

  /// No description provided for @printerBodyBtMissing.
  ///
  /// In en, this message translates to:
  /// **'This tablet cannot connect to a Bluetooth printer.'**
  String get printerBodyBtMissing;

  /// No description provided for @printerRetryIn.
  ///
  /// In en, this message translates to:
  /// **'Trying again in {seconds} s'**
  String printerRetryIn(int seconds);

  /// No description provided for @printerActionChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose printer'**
  String get printerActionChoose;

  /// No description provided for @printerActionRetry.
  ///
  /// In en, this message translates to:
  /// **'Connect now'**
  String get printerActionRetry;

  /// No description provided for @printerActionTest.
  ///
  /// In en, this message translates to:
  /// **'Test print'**
  String get printerActionTest;

  /// No description provided for @printerActionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow Bluetooth'**
  String get printerActionAllow;

  /// No description provided for @printerActionTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn Bluetooth on'**
  String get printerActionTurnOn;

  /// No description provided for @printerPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your printer'**
  String get printerPickerTitle;

  /// No description provided for @printerPickerBody.
  ///
  /// In en, this message translates to:
  /// **'Switch the printer on and keep it close. Printers nearby appear below.'**
  String get printerPickerBody;

  /// No description provided for @printerPickerPairHint.
  ///
  /// In en, this message translates to:
  /// **'Android may ask for a pairing code. For most printers it is 0000 or 1234.'**
  String get printerPickerPairHint;

  /// No description provided for @printerPickerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No printer found yet.'**
  String get printerPickerEmpty;

  /// No description provided for @printerPickerScanning.
  ///
  /// In en, this message translates to:
  /// **'Looking for printers…'**
  String get printerPickerScanning;

  /// No description provided for @printerPickerScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get printerPickerScanAgain;

  /// No description provided for @printerPickerPairedTag.
  ///
  /// In en, this message translates to:
  /// **'Paired'**
  String get printerPickerPairedTag;

  /// No description provided for @printerToastConnected.
  ///
  /// In en, this message translates to:
  /// **'Printer connected.'**
  String get printerToastConnected;

  /// No description provided for @printerToastLost.
  ///
  /// In en, this message translates to:
  /// **'Printer disconnected. The tablet is reconnecting.'**
  String get printerToastLost;

  /// No description provided for @printerToastRejected.
  ///
  /// In en, this message translates to:
  /// **'Pairing was cancelled or the code was wrong.'**
  String get printerToastRejected;

  /// No description provided for @printerToastChooseFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the printer. Check that it is on and close by.'**
  String get printerToastChooseFailed;

  /// No description provided for @printerToastConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Still cannot reach the printer. The tablet will keep trying.'**
  String get printerToastConnectFailed;

  /// No description provided for @printerToastTestOk.
  ///
  /// In en, this message translates to:
  /// **'Test token printed.'**
  String get printerToastTestOk;

  /// No description provided for @printerToastTestFailed.
  ///
  /// In en, this message translates to:
  /// **'The test token did not print. Check paper and cover.'**
  String get printerToastTestFailed;

  /// No description provided for @tvTitle.
  ///
  /// In en, this message translates to:
  /// **'TV screen'**
  String get tvTitle;

  /// No description provided for @tvStatus.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get tvStatus;

  /// No description provided for @tvBody.
  ///
  /// In en, this message translates to:
  /// **'You will check and connect the waiting-room TV here.'**
  String get tvBody;

  /// No description provided for @dialogClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogClose;

  /// No description provided for @printerTestConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Print a test token?'**
  String get printerTestConfirmTitle;

  /// No description provided for @printerTestConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'A sample token with a dummy number will print, using the chamber and doctor details set up here.'**
  String get printerTestConfirmBody;

  /// No description provided for @printerTestConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Print test token'**
  String get printerTestConfirmAction;

  /// No description provided for @printerToastNoDetails.
  ///
  /// In en, this message translates to:
  /// **'The chamber or doctor details for the token could not be found.'**
  String get printerToastNoDetails;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
