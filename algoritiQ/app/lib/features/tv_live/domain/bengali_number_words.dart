// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

/// The largest serial that can be spoken: one lakh.
const maxSpokenSerial = 100000;

/// The numbers 0 .. 99 as Bengali words. In Bengali every one of them is its
/// own word ("বিয়াল্লিশ", "নিরানব্বই"), not tens and ones put together.
const bengaliNumberWordsTo99 = [
  'শূন্য', 'এক', 'দুই', 'তিন', 'চার', 'পাঁচ', 'ছয়', 'সাত', 'আট', 'নয়', //
  'দশ', 'এগারো', 'বারো', 'তেরো', 'চৌদ্দ', 'পনেরো', 'ষোলো', 'সতেরো', 'আঠারো', //
  'উনিশ', 'বিশ', 'একুশ', 'বাইশ', 'তেইশ', 'চব্বিশ', 'পঁচিশ', 'ছাব্বিশ', //
  'সাতাশ', 'আটাশ', 'ঊনত্রিশ', 'ত্রিশ', 'একত্রিশ', 'বত্রিশ', 'তেত্রিশ', //
  'চৌত্রিশ', 'পঁয়ত্রিশ', 'ছত্রিশ', 'সাঁইত্রিশ', 'আটত্রিশ', 'ঊনচল্লিশ', //
  'চল্লিশ',
  'একচল্লিশ',
  'বিয়াল্লিশ',
  'তেতাল্লিশ',
  'চুয়াল্লিশ',
  'পঁয়তাল্লিশ', //
  'ছেচল্লিশ', 'সাতচল্লিশ', 'আটচল্লিশ', 'ঊনপঞ্চাশ', 'পঞ্চাশ', 'একান্ন', //
  'বাহান্ন', 'তিপ্পান্ন', 'চুয়ান্ন', 'পঞ্চান্ন', 'ছাপ্পান্ন', 'সাতান্ন', //
  'আটান্ন', 'ঊনষাট', 'ষাট', 'একষট্টি', 'বাষট্টি', 'তেষট্টি', 'চৌষট্টি', //
  'পঁয়ষট্টি', 'ছেষট্টি', 'সাতষট্টি', 'আটষট্টি', 'ঊনসত্তর', 'সত্তর', //
  'একাত্তর', 'বাহাত্তর', 'তিয়াত্তর', 'চুয়াত্তর', 'পঁচাত্তর', 'ছিয়াত্তর', //
  'সাতাত্তর', 'আটাত্তর', 'ঊনআশি', 'আশি', 'একাশি', 'বিরাশি', 'তিরাশি', //
  'চুরাশি', 'পঁচাশি', 'ছিয়াশি', 'সাতাশি', 'অষ্টাশি', 'ঊননব্বই', 'নব্বই', //
  'একানব্বই', 'বিরানব্বই', 'তিরানব্বই', 'চুরানব্বই', 'পঁচানব্বই', //
  'ছিয়ানব্বই', 'সাতানব্বই', 'আটানব্বই', 'নিরানব্বই',
];

/// The hundreds: "একশো" .. "নয়শো".
const bengaliHundredWords = [
  'একশো',
  'দুইশো',
  'তিনশো',
  'চারশো',
  'পাঁচশো',
  'ছয়শো',
  'সাতশো',
  'আটশো',
  'নয়শো',
];

/// [number] (1 .. 100000) as Bengali words, the way it is said aloud: 106 is
/// "একশো ছয়", 25678 is "পঁচিশ হাজার ছয়শো আটাত্তর", 100000 is "এক লাখ".
String bengaliNumberWords(int number) {
  if (number < 1 || number > maxSpokenSerial) {
    throw RangeError.range(number, 1, maxSpokenSerial, 'number');
  }
  if (number == maxSpokenSerial) return 'এক লাখ';
  final thousands = number ~/ 1000;
  final hundreds = number % 1000 ~/ 100;
  final rest = number % 100;
  return [
    if (thousands > 0) '${bengaliNumberWordsTo99[thousands]} হাজার',
    if (hundreds > 0) bengaliHundredWords[hundreds - 1],
    if (rest > 0) bengaliNumberWordsTo99[rest],
  ].join(' ');
}
