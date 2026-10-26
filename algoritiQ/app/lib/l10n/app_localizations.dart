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
  /// **'Activate AlgoritiQ'**
  String get activationTitle;

  /// No description provided for @activationIntro.
  ///
  /// In en, this message translates to:
  /// **'Send this device code to your AlgoritiQ provider to get your activation key.'**
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

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;
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
