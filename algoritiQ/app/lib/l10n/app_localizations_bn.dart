// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get activationTitle => 'AlgoritiQ সক্রিয় করুন';

  @override
  String get activationIntro =>
      'অ্যাক্টিভেশন কী পেতে এই ডিভাইস কোডটি আপনার AlgoritiQ সরবরাহকারীকে পাঠান।';

  @override
  String get deviceCodeLabel => 'ডিভাইস কোড';

  @override
  String get copyDeviceCode => 'কপি';

  @override
  String get deviceCodeCopied => 'ডিভাইস কোড কপি হয়েছে';

  @override
  String get activationKeyLabel => 'অ্যাক্টিভেশন কী';

  @override
  String get activationKeyHint => 'কী পেস্ট করুন বা টাইপ করুন';

  @override
  String get activateButton => 'সক্রিয় করুন';

  @override
  String get licenseErrorMalformed =>
      'এটি অ্যাক্টিভেশন কী বলে মনে হচ্ছে না। যাচাই করে আবার চেষ্টা করুন।';

  @override
  String get licenseErrorUnknownKey =>
      'অ্যাপের এই সংস্করণ এই কী চিনতে পারছে না।';

  @override
  String get licenseErrorBadSignature => 'এই কী বৈধ নয়।';

  @override
  String get licenseErrorWrongDevice =>
      'এই কী অন্য একটি ডিভাইসের জন্য দেওয়া হয়েছে।';

  @override
  String get licenseErrorExpired =>
      'আপনার লাইসেন্সের মেয়াদ শেষ হয়েছে। চালিয়ে যেতে নবায়ন করা কী দিন।';

  @override
  String get deviceUnavailable => 'এই ডিভাইসের পরিচয় পড়া যায়নি।';

  @override
  String get retryButton => 'আবার চেষ্টা করুন';

  @override
  String licenseSummaryDoctor(int chambers) {
    return 'ডাক্তার লাইসেন্স · সর্বোচ্চ $chambersটি চেম্বার';
  }

  @override
  String licenseSummaryChamber(int doctors) {
    return 'চেম্বার লাইসেন্স · সর্বোচ্চ $doctors জন ডাক্তার';
  }

  @override
  String licenseValidUntil(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'মেয়াদ: $dateString পর্যন্ত';
  }

  @override
  String get licenseNoExpiry => 'মেয়াদ নেই';

  @override
  String get licenseGraceNotice =>
      'লাইসেন্সের মেয়াদ শেষ। বিঘ্ন এড়াতে শীঘ্রই নবায়ন করা কী দিন।';

  @override
  String get activationStepCopy => 'কোড কপি';

  @override
  String get activationStepGet => 'কী সংগ্রহ';

  @override
  String get activationStepEnter => 'কী দিন';

  @override
  String get stepDone => 'সম্পন্ন';

  @override
  String get stepCurrent => 'বর্তমান ধাপ';

  @override
  String get activationFooter =>
      'আপনার লাইসেন্স এই ডিভাইসের সাথে যুক্ত এবং অফলাইনেও কাজ করে।';

  @override
  String get activating => 'সক্রিয় করা হচ্ছে…';

  @override
  String get languageLabel => 'ভাষা';

  @override
  String get loading => 'লোড হচ্ছে…';
}
