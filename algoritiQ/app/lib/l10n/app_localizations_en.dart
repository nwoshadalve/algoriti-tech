// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get activationTitle => 'Activate AlgoritiQ';

  @override
  String get activationIntro =>
      'Send this device code to your AlgoritiQ provider to get your activation key.';

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
  String get loading => 'Loading…';
}
