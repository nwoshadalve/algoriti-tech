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
  String get readinessBluetoothTitle => 'ব্লুটুথের অনুমতি';

  @override
  String get readinessBluetoothBody =>
      'ব্লুটুথ চালু বা বন্ধ—অ্যাপ জানতে পারবে এবং প্রিন্টের জন্য দরকার হলে চালু করতে বলতে পারবে।';

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
  String get clinicDataTitle => 'ক্লিনিকের তথ্য';

  @override
  String get clinicDataIntro =>
      'এই ট্যাবলেটে নতুন শুরু করুন, অথবা ওয়েব অ্যাপের ব্যাকআপ থেকে সংরক্ষিত জিপ ফিরিয়ে আনুন।';

  @override
  String get clinicDataStartNew => 'নতুন শুরু';

  @override
  String get clinicDataRestore => 'ব্যাকআপ থেকে রিস্টোর';

  @override
  String get clinicDataRestoreHint =>
      'ব্যাকআপ পৃষ্ঠা থেকে ডাউনলোড করা জিপ ফাইল বেছে নিন।';

  @override
  String get clinicDataRestoreBusy => 'রিস্টোর হচ্ছে…';

  @override
  String get clinicDataRestoreFailed =>
      'এই ব্যাকআপ রিস্টোর করা যায়নি। ফাইল যাচাই করে আবার চেষ্টা করুন।';

  @override
  String get signInTitle => 'সাইন ইন';

  @override
  String get signInIntro =>
      'আপনার অ্যাডমিন অ্যাকাউন্টের ইউজারনেম বা ইমেইল এবং পাসওয়ার্ড দিন।';

  @override
  String get signInIdentifierLabel => 'ইউজারনেম বা ইমেইল';

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
  String get signInRemember => 'এই ট্যাবলেটে মনে রাখুন';

  @override
  String get signInRememberHint =>
      '৩০ দিন সাইন ইন থাকবেন। শুধু নিজের ডিভাইসে ব্যবহার করুন।';

  @override
  String pinLoginTitle(String name) {
    return 'আবার স্বাগতম, $name';
  }

  @override
  String get pinLoginIntro => 'এই ট্যাবলেটে সাইন ইন করতে আপনার পিন দিন।';

  @override
  String get fieldPin => 'পিন';

  @override
  String get pinUsePassword => 'পাসওয়ার্ড দিয়ে সাইন ইন করুন';

  @override
  String get pinUsePin => 'পিন দিয়ে সাইন ইন করুন';

  @override
  String pinWrong(int count) {
    return 'পিন সঠিক নয়। আর $count বার চেষ্টা করতে পারবেন।';
  }

  @override
  String get pinLocked => 'অনেকবার ভুল পিন। পাসওয়ার্ড দিয়ে সাইন ইন করুন।';

  @override
  String get pinRequired => '৬ অঙ্কের পিন লিখুন।';

  @override
  String get adminNoticeTitle => 'অ্যাডমিন সাইন-ইন এখন ওয়েবে';

  @override
  String get adminNoticeBody =>
      'এই ট্যাবলেটে আপাতত শুধু রিসেপশনিস্টের স্ক্রিন আছে। অ্যাডমিন হিসেবে ক্লিনিক পরিচালনা করতে আপনার ফোন বা ল্যাপটপের ব্রাউজারে নিচের ঠিকানাটি খুলে সেখানে সাইন ইন করুন। ট্যাবলেটে অ্যাডমিন সাইন-ইন পরের কোনো আপডেটে আসতে পারে।';

  @override
  String get adminNoticeSignOut =>
      'সাইন-ইন স্ক্রিনে ফিরতে ঠিক আছে চাপুন। অ্যাপ বন্ধ করলেও আপনি সাইন আউট হয়ে যাবেন।';

  @override
  String get adminNoticeOk => 'ঠিক আছে';

  @override
  String get signInFieldsRequired => 'ইউজারনেম বা ইমেইল এবং পাসওয়ার্ড লিখুন।';

  @override
  String get signInWrong => 'ইউজারনেম, ইমেইল বা পাসওয়ার্ড ভুল।';

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

  @override
  String get navPrimaryLabel => 'ড্যাশবোর্ডের অংশ';

  @override
  String get navBoard => 'বোর্ড';

  @override
  String get navCloseMenu => 'মেনু বন্ধ করুন';

  @override
  String get navOpenMenu => 'মেনু খুলুন';

  @override
  String boardGreeting(String name) {
    return 'আবার স্বাগতম, $name';
  }

  @override
  String get workScopeTitle => 'আপনি কোথায় কাজ করছেন?';

  @override
  String get workScopeIntroChamber =>
      'বোর্ড ও রোগীর কিউ খুলতে একটি চেম্বার বেছে নিন।';

  @override
  String get workScopeIntroDoctor =>
      'বোর্ড ও রোগীর কিউ খুলতে একজন ডাক্তার বেছে নিন।';

  @override
  String get workScopeEmpty =>
      'আপনাকে এখনো কোনো চেম্বারে নিয়োগ দেওয়া হয়নি। অ্যাডমিনকে বলুন।';

  @override
  String workScopeActive(String name) {
    return '$name-এ কাজ করছেন। এখান থেকেই কাউন্টার চালান।';
  }

  @override
  String get workScopeSidebarLabel => 'কাজ করছেন';

  @override
  String get navChangeWorkScope => 'চেম্বার বদলান';

  @override
  String get boardIntro =>
      'এখান থেকেই কাউন্টার চালান। লাইভ কিউ সরঞ্জাম এই বোর্ডে দেখা যাবে।';

  @override
  String get boardServerTitle => 'ক্লিনিক সারভার';

  @override
  String get boardServerOk =>
      'এই ট্যাবলেট ওয়েব অ্যাপ ও অন্যান্য ডিভাইসকে সেবা দিচ্ছে।';

  @override
  String get boardServerStarting => 'ক্লিনিক সারভার চালু হচ্ছে…';

  @override
  String get boardServerFailed =>
      'ক্লিনিক সারভার চালু হয়নি। রেডিনেস সেটিংস দেখুন বা অ্যাপ আবার চালু করুন।';

  @override
  String get boardAccountTitle => 'আপনার অ্যাকাউন্ট';

  @override
  String get fieldRole => 'ভূমিকা';

  @override
  String get fieldUsername => 'ইউজারনেম';

  @override
  String get fieldEmail => 'ইমেইল';

  @override
  String get roleAdmin => 'অ্যাডমিন';

  @override
  String get roleReceptionist => 'রিসেপশনিস্ট';

  @override
  String get boardQueueTitle => 'রোগীর কিউ';

  @override
  String get boardQueueSoon => 'লাইভ কিউ সরঞ্জাম প্রস্তুত হলে এখানে দেখা যাবে।';

  @override
  String get themeLight => 'হালকা থিমে যান';

  @override
  String get themeDark => 'গাঢ় থিমে যান';

  @override
  String get navSettings => 'সেটিংস';

  @override
  String get settingsIntro =>
      'প্রোফাইল ছবি, নাম, পাসওয়ার্ড ও এই ডিভাইসের পিন।';

  @override
  String get userMenuLabel => 'অ্যাকাউন্ট মেনু';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get signingOut => 'সাইন আউট হচ্ছে…';

  @override
  String get fieldFirstName => 'নামের প্রথম অংশ';

  @override
  String get fieldLastName => 'নামের শেষ অংশ';

  @override
  String get fieldPhone => 'ফোন';

  @override
  String get settingsPhotoTitle => 'প্রোফাইল ছবি';

  @override
  String get settingsPhotoHelp =>
      'JPEG, PNG বা WebP। ছবি এই ট্যাবলেটে সংরক্ষিত হয়।';

  @override
  String get settingsProfileTitle => 'ব্যক্তিগত তথ্য';

  @override
  String get settingsProfileIntro => 'আপনার নাম ও যোগাযোগের তথ্য।';

  @override
  String get settingsSave => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get settingsSaving => 'সংরক্ষণ হচ্ছে…';

  @override
  String get settingsSaved => 'পরিবর্তন সংরক্ষিত হয়েছে।';

  @override
  String get settingsUsernameNote => 'ইউজারনেম বদলানো যায় না।';

  @override
  String get settingsFixFields => 'চিহ্নিত ঘরগুলো ঠিক করুন।';

  @override
  String get settingsFirstNameRequired => 'নামের প্রথম অংশ লিখুন।';

  @override
  String get settingsNameTooLong => 'ছোট নাম ব্যবহার করুন।';

  @override
  String get settingsEmailInvalid => 'সঠিক ইমেইল লিখুন।';

  @override
  String get settingsEmailTaken => 'এই ইমেইল ইতিমধ্যে ব্যবহারে আছে।';

  @override
  String get settingsPhoneInvalid => 'সঠিক ফোন নম্বর লিখুন।';

  @override
  String get settingsPhotoSaved => 'ছবি আপডেট হয়েছে।';

  @override
  String get settingsPhotoRemoved => 'ছবি সরানো হয়েছে।';

  @override
  String get settingsPhotoFailed => 'ছবি সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get securityCardTitle => 'পাসওয়ার্ড ও পিন';

  @override
  String get securityCardIntro =>
      'পাসওয়ার্ড বদলান অথবা দ্রুত সাইন-ইনের জন্য পিন সেট করুন। পাসওয়ার্ড বদলালে সব পিন মুছে যাবে।';

  @override
  String get passwordCardTitle => 'পাসওয়ার্ড';

  @override
  String get passwordCardIntro =>
      'নতুন পাসওয়ার্ড বেছে নিন। অন্য সাইন-ইন শেষ হয়ে যাবে।';

  @override
  String get passwordChangeButton => 'পাসওয়ার্ড বদলান';

  @override
  String get passwordModalTitle => 'পাসওয়ার্ড বদলান';

  @override
  String get passwordCurrentLabel => 'বর্তমান পাসওয়ার্ড';

  @override
  String get passwordNewLabel => 'নতুন পাসওয়ার্ড';

  @override
  String get passwordConfirmLabel => 'নতুন পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get passwordChanged =>
      'পাসওয়ার্ড বদলানো হয়েছে। অন্য সাইন-ইন শেষ হয়েছে।';

  @override
  String get passwordCurrentWrong => 'বর্তমান পাসওয়ার্ড সঠিক নয়।';

  @override
  String get passwordNewSame => 'অন্য পাসওয়ার্ড বেছে নিন।';

  @override
  String get pinCardTitle => 'দ্রুত সাইন-ইন পিন';

  @override
  String get pinCardIntro =>
      'এই ট্যাবলেটে পাসওয়ার্ডের বদলে ৬ অঙ্কের পিন দিয়ে সাইন ইন করুন।';

  @override
  String get pinNone => 'এই ট্যাবলেটে এখনও কোনো পিন নেই।';

  @override
  String get pinThisTablet => 'এই ট্যাবলেট';

  @override
  String get pinSetButton => 'এই ট্যাবলেটের জন্য পিন সেট করুন';

  @override
  String get pinChangeButton => 'পিন বদলান';

  @override
  String get pinRemove => 'সরান';

  @override
  String get pinRemoved => 'পিন সরানো হয়েছে।';

  @override
  String get pinSetDone => 'এই ট্যাবলেটের জন্য পিন সংরক্ষিত হয়েছে।';

  @override
  String get pinLoadFailed => 'পিন ডিভাইস লোড করা যায়নি।';

  @override
  String get pinModalTitle => 'পিন সেট করুন';

  @override
  String get pinModalPasswordLabel => 'আপনার পাসওয়ার্ড';

  @override
  String get pinModalPinLabel => 'নতুন পিন';

  @override
  String get pinModalConfirmLabel => 'পিন নিশ্চিত করুন';

  @override
  String get pinModalSubmit => 'পিন সংরক্ষণ করুন';

  @override
  String get pinModalBusy => 'সংরক্ষণ হচ্ছে…';

  @override
  String get pinFormatInvalid => '৬ অঙ্কের পিন লিখুন।';

  @override
  String get pinWeak => 'অনুমান করা সহজ এমন পিন বেছে নিন না।';

  @override
  String get pinPasswordWrong => 'পাসওয়ার্ড সঠিক নয়।';

  @override
  String get pinPinsDiffer => 'পিন দুটি মেলেনি।';

  @override
  String get navConnectivity => 'সংযোগ';

  @override
  String get toastDismiss => 'বার্তা বন্ধ করুন';

  @override
  String get connectivityTitle => 'সংযোগ';

  @override
  String get connectivityIntro =>
      'প্রিন্টার ও টিভি স্ক্রিন যুক্ত আছে কি না দেখুন।';

  @override
  String get printerTitle => 'প্রিন্টার';

  @override
  String get printerStatusConnected => 'যুক্ত আছে';

  @override
  String get printerStatusConnecting => 'যুক্ত হচ্ছে…';

  @override
  String get printerStatusDisconnected => 'যুক্ত নেই';

  @override
  String get printerStatusNotPaired => 'কোনো প্রিন্টার সেট করা নেই';

  @override
  String get printerStatusBtOff => 'ব্লুটুথ বন্ধ';

  @override
  String get printerStatusBtDenied => 'ব্লুটুথের অনুমতি নেই';

  @override
  String get printerStatusBtMissing => 'এই ট্যাবলেটে ব্লুটুথ নেই';

  @override
  String get printerBodyNotPaired =>
      'প্রিন্টার চালু করে তালিকা থেকে বেছে নিন। এটি শুধু একবারই করতে হবে।';

  @override
  String get printerBodyDisconnected =>
      'ট্যাবলেট নিজে থেকেই যুক্ত হওয়ার চেষ্টা করছে। প্রিন্টার চালু ও কাছে আছে কি না দেখুন।';

  @override
  String get printerBodyConnected => 'টোকেন ছাপার জন্য প্রস্তুত।';

  @override
  String get printerBodyBtOff =>
      'ট্যাবলেট যেন প্রিন্টারে পৌঁছাতে পারে, তাই ব্লুটুথ চালু করুন।';

  @override
  String get printerBodyBtDenied =>
      'ট্যাবলেট যেন প্রিন্টারে পৌঁছাতে পারে, তাই এই অ্যাপের জন্য ব্লুটুথের অনুমতি দিন।';

  @override
  String get printerBodyBtMissing =>
      'এই ট্যাবলেট ব্লুটুথ প্রিন্টারে যুক্ত হতে পারে না।';

  @override
  String printerRetryIn(int seconds) {
    return '$seconds সেকেন্ড পরে আবার চেষ্টা হবে';
  }

  @override
  String get printerActionChoose => 'প্রিন্টার বেছে নিন';

  @override
  String get printerActionRetry => 'এখনই যুক্ত করুন';

  @override
  String get printerActionTest => 'টেস্ট প্রিন্ট';

  @override
  String get printerActionAllow => 'ব্লুটুথের অনুমতি দিন';

  @override
  String get printerActionTurnOn => 'ব্লুটুথ চালু করুন';

  @override
  String get printerPickerTitle => 'প্রিন্টার বেছে নিন';

  @override
  String get printerPickerBody =>
      'প্রিন্টার চালু করে কাছে রাখুন। আশপাশের প্রিন্টার নিচে দেখা যাবে।';

  @override
  String get printerPickerPairHint =>
      'অ্যান্ড্রয়েড পেয়ারিং কোড চাইতে পারে। বেশির ভাগ প্রিন্টারে এটি ০০০০ বা ১২৩৪।';

  @override
  String get printerPickerEmpty => 'এখনও কোনো প্রিন্টার পাওয়া যায়নি।';

  @override
  String get printerPickerScanning => 'প্রিন্টার খোঁজা হচ্ছে…';

  @override
  String get printerPickerScanAgain => 'আবার খুঁজুন';

  @override
  String get printerPickerPairedTag => 'পেয়ার করা';

  @override
  String get printerToastConnected => 'প্রিন্টার যুক্ত হয়েছে।';

  @override
  String get printerToastLost =>
      'প্রিন্টারের সংযোগ কেটে গেছে। ট্যাবলেট আবার যুক্ত হচ্ছে।';

  @override
  String get printerToastRejected => 'পেয়ারিং বাতিল হয়েছে বা কোড ভুল ছিল।';

  @override
  String get printerToastChooseFailed =>
      'প্রিন্টারে যুক্ত হওয়া যায়নি। প্রিন্টার চালু ও কাছে আছে কি না দেখুন।';

  @override
  String get printerToastConnectFailed =>
      'এখনও প্রিন্টারে পৌঁছানো যাচ্ছে না। ট্যাবলেট চেষ্টা চালিয়ে যাবে।';

  @override
  String get printerToastTestOk => 'টেস্ট টোকেন ছাপা হয়েছে।';

  @override
  String get printerToastTestFailed =>
      'টেস্ট টোকেন ছাপা হয়নি। কাগজ ও ঢাকনা দেখুন।';

  @override
  String get tvTitle => 'টিভি স্ক্রিন';

  @override
  String get tvStatus => 'শীঘ্রই আসছে';

  @override
  String get tvBody => 'ওয়েটিং রুমের টিভি এখান থেকে দেখে যুক্ত করবেন।';

  @override
  String get dialogClose => 'বন্ধ করুন';

  @override
  String get printerTestConfirmTitle => 'টেস্ট টোকেন ছাপাবেন?';

  @override
  String get printerTestConfirmBody =>
      'এখানে সেট করা চেম্বার ও ডাক্তারের তথ্য দিয়ে একটি নমুনা টোকেন, ডামি নম্বরসহ, ছাপা হবে।';

  @override
  String get printerTestConfirmAction => 'টেস্ট টোকেন ছাপান';

  @override
  String get printerToastNoDetails =>
      'টোকেনের জন্য চেম্বার বা ডাক্তারের তথ্য পাওয়া যায়নি।';
}
