// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../domain/bengali_number_words.dart';
import '../domain/call_voice.dart';
import '../domain/speech_synthesizer.dart';

/// Speaks a call with the phone's own text-to-speech. The fallback when there
/// is no recorded voice pack: understandable, but not a native Bengali voice.
final class TtsCallVoice implements CallVoice {
  TtsCallVoice(this._speech);

  final SpeechSynthesizer _speech;

  /// The words of a call: queue, serial (said as a Bengali number: 106 is
  /// "একশো ছয়"), then the ask to come in. A text-to-speech voice reads digits its
  /// own way, so the number is written out in words.
  static String textFor(int serial, String queueLabelBn) {
    final number = serial >= 1 && serial <= maxSpokenSerial
        ? bengaliNumberWords(serial)
        : serial
              .toString()
              .split('')
              .map((d) => '০১২৩৪৫৬৭৮৯'[int.parse(d)])
              .join();
    final queue = queueLabelBn.isEmpty ? '' : '$queueLabelBn, ';
    return speakable('${queue}টোকেন নম্বর $number। অনুগ্রহ করে ভেতরে আসুন।');
  }

  /// "য়" written as one character (U+09DF) rather than য + a dot (U+09AF
  /// U+09BC): a voice reads the first correctly ("ছয়"), and says "ছু" for the
  /// second.
  static String speakable(String text) =>
      text.replaceAll('\u09AF\u09BC', '\u09DF');

  static const _testText =
      'এটি একটি পরীক্ষামূলক ঘোষণা। টোকেন নম্বর ১০০১। অনুগ্রহ করে ভেতরে আসুন।';

  @override
  Future<List<int>?> callClip({
    required int serial,
    required String queueTypeId,
    String queueLabelBn = '',
    bool recall = false,
  }) => _speech.synthesize(textFor(serial, queueLabelBn));

  @override
  Future<List<int>?> testClip() => _speech.synthesize(_testText);
}
