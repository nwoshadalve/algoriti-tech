// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get activationTitle => 'এই ডিভাইসটি সক্রিয় করুন';

  @override
  String get activationIntro =>
      'অ্যাক্টিভেশন কী পেতে এই ডিভাইস কোডটি আপনার সরবরাহকারীকে পাঠান।';

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
  String get pasteKey => 'কী পেস্ট করুন';

  @override
  String get setupStepProfile => 'আপনার প্রোফাইল';

  @override
  String get setupStepChambers => 'চেম্বার';

  @override
  String get setupStepReady => 'প্রস্তুত';

  @override
  String get continueButton => 'চালিয়ে যান';

  @override
  String get saving => 'সংরক্ষণ করা হচ্ছে…';

  @override
  String get setupSaveFailed => 'সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get setupLoadFailed => 'আপনার সেটআপ লোড করা যায়নি।';

  @override
  String get profileTitle => 'আপনার প্রোফাইল';

  @override
  String get profileIntro => 'এটি টিভিতে ও টোকেনে দেখানো হবে।';

  @override
  String get doctorNameLabel => 'পূর্ণ নাম (উপাধিসহ)';

  @override
  String get specialtyLabel => 'বিশেষত্ব ও দক্ষতার ক্ষেত্র';

  @override
  String get doctorNameRequired => 'আপনার নাম লিখুন।';

  @override
  String get chambersTitle => 'আপনার চেম্বার যোগ করুন';

  @override
  String chambersIntro(int max) {
    return 'আপনার লাইসেন্সে সর্বোচ্চ $maxটি চেম্বার থাকতে পারবে। পরে সেটিংসে পরিবর্তন করতে পারবেন।';
  }

  @override
  String chamberQuota(int count, int max) {
    return '$maxটির মধ্যে $countটি চেম্বার';
  }

  @override
  String get chamberNameLabel => 'চেম্বারের নাম';

  @override
  String get chamberLocationLabel => 'ঠিকানা';

  @override
  String get addChamberButton => 'চেম্বার যোগ করুন';

  @override
  String get saveChamberButton => 'চেম্বার সংরক্ষণ করুন';

  @override
  String get cancelEditButton => 'বাতিল';

  @override
  String editChamberTooltip(String name) {
    return '$name সম্পাদনা করুন';
  }

  @override
  String get chamberNameRequired => 'চেম্বারের নাম লিখুন।';

  @override
  String chamberLimitReached(int max) {
    return 'আপনার লাইসেন্সে $maxটি চেম্বার, আর সবগুলোই যোগ করা হয়েছে।';
  }

  @override
  String get addOneChamber => 'চালিয়ে যেতে অন্তত একটি চেম্বার যোগ করুন।';

  @override
  String get readyTitle => 'সব প্রস্তুত';

  @override
  String get readyIntro =>
      'আপনার প্রোফাইল ও চেম্বার সংরক্ষিত হয়েছে। পরে সেটিংসে পরিবর্তন করতে পারবেন।';

  @override
  String get startButton => 'শুরু করুন';

  @override
  String get degreesLabel => 'ডিগ্রি';

  @override
  String get addDegreeButton => 'ডিগ্রি যোগ করুন';

  @override
  String removeDegreeTooltip(String degree) {
    return '$degree মুছুন';
  }

  @override
  String get designationLabel => 'পদবি';

  @override
  String get workplaceLabel => 'হাসপাতাল বা প্রতিষ্ঠান (ঐচ্ছিক)';

  @override
  String get registrationLabel => 'মেডিকেল কাউন্সিল নিবন্ধন নম্বর (ঐচ্ছিক)';

  @override
  String get photoLabel => 'ছবি (ঐচ্ছিক)';

  @override
  String get addPhotoButton => 'ছবি যোগ করুন';

  @override
  String get changePhotoButton => 'ছবি পরিবর্তন করুন';

  @override
  String get removePhotoButton => 'ছবি সরান';

  @override
  String get photoFromGallery => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get photoFromCamera => 'ছবি তুলুন';

  @override
  String get photoFailed => 'এই ছবিটি ব্যবহার করা যায়নি। অন্যটি চেষ্টা করুন।';

  @override
  String get chamberPhoneLabel => 'সিরিয়াল বা যোগাযোগের নম্বর';

  @override
  String get chamberAddressRequired => 'চেম্বারের ঠিকানা লিখুন।';

  @override
  String get chamberPhoneRequired => 'একটি ফোন নম্বর লিখুন।';

  @override
  String get backButton => 'পেছনে';

  @override
  String get designationRequired => 'আপনার পদবি লিখুন।';

  @override
  String get specialtyRequired => 'আপনার বিশেষত্ব লিখুন।';

  @override
  String get degreesRequired => 'অন্তত একটি ডিগ্রি যোগ করুন।';

  @override
  String get adminGuideTitle => 'অ্যাডমিন অ্যাকাউন্ট তৈরি করুন';

  @override
  String get adminGuideIntro =>
      'আপনার বিশ্বস্ত কেউ একই ওয়াই-ফাইয়ে থাকা ল্যাপটপ বা ফোন থেকে ক্লিনিক সেটআপ করবেন।';

  @override
  String get guideStepOpen => 'এই ঠিকানাটি খুলুন';

  @override
  String get guideStepCode => 'চাইলে এই কোডটি লিখুন';

  @override
  String get guideStepRegister => 'অ্যাডমিন নিবন্ধন করে সাইন ইন করুন';

  @override
  String get guideScanHint => 'অথবা ফোনের ক্যামেরা দিয়ে স্ক্যান করুন';

  @override
  String get guideAddressByIp => 'অথবা আইপি ঠিকানায়';

  @override
  String get copyAddressTooltip => 'ঠিকানা কপি করুন';

  @override
  String get addressCopied => 'ঠিকানা কপি হয়েছে';

  @override
  String codeExpiresIn(String time) {
    return 'মেয়াদ বাকি $time';
  }

  @override
  String get newCodeButton => 'নতুন কোড';

  @override
  String get serverStarting => 'সার্ভার চালু হচ্ছে…';

  @override
  String get serverRunning => 'সার্ভার চলছে';

  @override
  String get serverNoNetwork =>
      'চালিয়ে যেতে এই ট্যাবলেটকে ক্লিনিকের ওয়াই-ফাইয়ে যুক্ত করুন।';

  @override
  String get serverFailed => 'সার্ভার চালু করা যায়নি।';

  @override
  String get certNote =>
      'ব্রাউজার বলবে সংযোগটি ব্যক্তিগত নয়। এটি স্বাভাবিক, কারণ ট্যাবলেট নিজের সার্টিফিকেট ব্যবহার করে। ফিঙ্গারপ্রিন্ট মিলিয়ে নিয়ে চালিয়ে যান।';

  @override
  String get certFingerprintLabel => 'সার্টিফিকেট ফিঙ্গারপ্রিন্ট';

  @override
  String get readinessTitle => 'ট্যাবলেট প্রস্তুত রাখুন';

  @override
  String get readinessIntro =>
      'যাতে স্ক্রিন লক থাকলে বা রিস্টার্টের পরেও রোগী, টিভি ও ওয়েব অ্যাপ কিউ-তে পৌঁছাতে পারে।';

  @override
  String get readinessBackgroundTitle => 'ব্যাকগ্রাউন্ডে চালু রাখুন';

  @override
  String get readinessBackgroundBody =>
      'ব্যাটারি বাঁচাতে অ্যান্ড্রয়েড যেন সার্ভার থামিয়ে না দেয়।';

  @override
  String get readinessNotificationsTitle => 'চলমান নোটিশ দেখান';

  @override
  String get readinessNotificationsBody =>
      'ছোট একটি নোটিশ অ্যান্ড্রয়েডকে জানায় যে অ্যাপটি চালু থাকতে হবে।';

  @override
  String get readinessAutoStartTitle => 'রিস্টার্টের পর চালু হোক';

  @override
  String get readinessAutoStartBody =>
      'যাচাই করতে ট্যাবলেটটি একবার রিস্টার্ট করুন। রিস্টার্টের পর সার্ভার নিজে থেকে চালু হলে এখানে টিক চিহ্ন আসবে। না এলে সেটিংস আইকনে চাপ দিয়ে AlgoritiQ-কে নিজে থেকে চালু হওয়ার অনুমতি দিন (App launch), তারপর আবার রিস্টার্ট করুন।';

  @override
  String get readinessServiceTitle => 'ব্যাকগ্রাউন্ড সার্ভিস';

  @override
  String get readinessServiceDone => 'চলছে।';

  @override
  String get readinessServiceNeeded => 'এখনও চালু হয়নি।';

  @override
  String get readinessAllow => 'অনুমতি দিন';

  @override
  String get readinessOpenSettings => 'সেটিংস খুলুন';

  @override
  String get readinessConfirm => 'আমি করেছি';

  @override
  String get readinessRequired => 'আবশ্যক';

  @override
  String get readinessContinueAnyway => 'তবুও চালিয়ে যান';

  @override
  String get readinessStateDone => 'সম্পন্ন';

  @override
  String get readinessStateNeeded => 'মনোযোগ দরকার';

  @override
  String get readinessStateUnconfirmed => 'নিশ্চিত নয়';

  @override
  String get signInTitle => 'সাইন ইন';

  @override
  String get signInIntro =>
      'আপনার অ্যাডমিন অ্যাকাউন্টের ইউজারনেম ও পাসওয়ার্ড দিন।';

  @override
  String get signInUsernameLabel => 'ইউজারনেম';

  @override
  String get signInPasswordLabel => 'পাসওয়ার্ড';

  @override
  String get signInButton => 'সাইন ইন করুন';

  @override
  String get signInBusy => 'সাইন ইন হচ্ছে…';

  @override
  String get signInForgot => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get signInFieldsRequired => 'ইউজারনেম ও পাসওয়ার্ড লিখুন।';

  @override
  String get signInWrong => 'ইউজারনেম বা পাসওয়ার্ড ভুল।';

  @override
  String signInWait(int seconds) {
    return 'অনেকবার চেষ্টা হয়েছে। $seconds সেকেন্ড পরে আবার চেষ্টা করুন।';
  }

  @override
  String get showPasswordTooltip => 'পাসওয়ার্ড দেখুন';

  @override
  String get hidePasswordTooltip => 'পাসওয়ার্ড লুকান';

  @override
  String get signOutTooltip => 'সাইন আউট';

  @override
  String get resetTitle => 'পাসওয়ার্ড রিসেট করুন';

  @override
  String get resetIntro =>
      'যে অ্যাডমিন অ্যাকাউন্টের পাসওয়ার্ড ভুলে গেছেন তার ইউজারনেম লিখুন।';

  @override
  String get resetKeyLabel => 'অ্যাক্টিভেশন কী';

  @override
  String get resetKeyHint =>
      'এই ট্যাবলেট যে কী দিয়ে চালু করা হয়েছিল তার পুরোটা। ক্লিনিকের মালিক বা সরবরাহকারীর কাছ থেকে নিন। স্পেস ও ড্যাশ লাগবে না।';

  @override
  String get resetNewPasswordLabel => 'নতুন পাসওয়ার্ড';

  @override
  String get resetConfirmLabel => 'নতুন পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get resetPasswordHint => 'কমপক্ষে ৮ অক্ষর। ইউজারনেম থাকা যাবে না।';

  @override
  String get resetButton => 'পাসওয়ার্ড রিসেট করুন';

  @override
  String get resetBusy => 'রিসেট হচ্ছে…';

  @override
  String get resetBack => 'সাইন ইনে ফিরে যান';

  @override
  String get resetDone =>
      'পাসওয়ার্ড বদলানো হয়েছে। নতুন পাসওয়ার্ড দিয়ে সাইন ইন করুন।';

  @override
  String get resetRefused => 'অ্যাক্টিভেশন কী বা ইউজারনেম সঠিক নয়।';

  @override
  String get resetNeedUsername => 'ইউজারনেম লিখুন।';

  @override
  String get resetNeedKey => 'অ্যাক্টিভেশন কী লিখুন।';

  @override
  String get passwordNeeded => 'একটি পাসওয়ার্ড দিন।';

  @override
  String get passwordTooShort => 'কমপক্ষে ৮ অক্ষর দিন।';

  @override
  String get passwordTooLong => 'সর্বোচ্চ ১২৮ অক্ষর দিন।';

  @override
  String get passwordHasUsername => 'পাসওয়ার্ডে ইউজারনেম থাকা যাবে না।';

  @override
  String get passwordsDiffer => 'পাসওয়ার্ড দুটি মেলেনি।';

  @override
  String resetStepOf(int current, int total) {
    return 'ধাপ $current / $total';
  }

  @override
  String get resetStepUsername => 'ইউজারনেম লিখুন';

  @override
  String get resetStepKey => 'অ্যাক্টিভেশন কী লিখুন';

  @override
  String get resetStepPassword => 'নতুন পাসওয়ার্ড বেছে নিন';

  @override
  String get resetKeyTitle => 'আপনিই যে আপনি, তা নিশ্চিত করুন';

  @override
  String get resetKeyIntro =>
      'এই ট্যাবলেট যে কী দিয়ে চালু করা হয়েছিল সেটি লিখুন। না থাকলে ক্লিনিকের মালিক বা সরবরাহকারীর কাছ থেকে নিন।';

  @override
  String get resetPasswordTitle => 'নতুন পাসওয়ার্ড বেছে নিন';

  @override
  String resetPasswordIntro(String username) {
    return 'কী গ্রহণ করা হয়েছে। $username-এর জন্য নতুন পাসওয়ার্ড বেছে নিন।';
  }

  @override
  String get resetContinue => 'এগিয়ে যান';

  @override
  String get resetChecking => 'কী যাচাই হচ্ছে…';

  @override
  String get resetPrevious => 'পেছনে';

  @override
  String get resetExpired => 'এই রিসেটের সময় শেষ। অ্যাক্টিভেশন কী আবার লিখুন।';
}
