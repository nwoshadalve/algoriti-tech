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
  /// **'1. Open this address'**
  String get guideStepOpen;

  /// No description provided for @guideStepCode.
  ///
  /// In en, this message translates to:
  /// **'2. Enter this code when asked'**
  String get guideStepCode;

  /// No description provided for @guideStepRegister.
  ///
  /// In en, this message translates to:
  /// **'3. Register the admin, then sign in'**
  String get guideStepRegister;

  /// No description provided for @guideScanHint.
  ///
  /// In en, this message translates to:
  /// **'Or scan with a phone camera'**
  String get guideScanHint;

  /// No description provided for @guideAddressByIp.
  ///
  /// In en, this message translates to:
  /// **'Or by IP address: {url}'**
  String guideAddressByIp(String url);

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
