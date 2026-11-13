// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/android_speech_synthesizer.dart';
import '../data/loud_call_voice.dart';
import '../data/prerecorded_call_voice.dart';
import '../data/tts_call_voice.dart';
import '../domain/speech_synthesizer.dart';
import 'announcement_service.dart';

final speechSynthesizerProvider = Provider<SpeechSynthesizer>(
  (ref) => AndroidSpeechSynthesizer(),
);

/// The one announcement service: the queue desk prepares clips with it and the
/// local API serves them to the TV.
///
/// The recorded voice pack (`assets/announcements/`) speaks first. When it is
/// missing or incomplete the phone's own text-to-speech takes over.
final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  return AnnouncementService(
    voices: [
      LoudCallVoice(PrerecordedCallVoice(load: _loadPackClip)),
      LoudCallVoice(TtsCallVoice(ref.watch(speechSynthesizerProvider))),
    ],
  );
});

/// One clip of the voice pack, or null when the pack does not have it.
Future<List<int>?> _loadPackClip(String key) =>
    _loadBytes('assets/announcements/$key.wav');

Future<List<int>?> _loadBytes(String asset) async {
  try {
    final data = await rootBundle.load(asset);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  } on FlutterError {
    return null;
  }
}
