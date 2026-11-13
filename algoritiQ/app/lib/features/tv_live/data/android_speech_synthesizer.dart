// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../domain/speech_synthesizer.dart';

/// The tablet's Bengali text-to-speech voice, through the Android
/// `TextToSpeech` engine (`SpeechChannel` on the Android side). It prefers an
/// installed voice that works without the internet.
final class AndroidSpeechSynthesizer implements SpeechSynthesizer {
  AndroidSpeechSynthesizer([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel(name);

  static const name = 'tech.algoriti.algoritiq/speech';

  final MethodChannel _channel;

  @override
  Future<List<int>?> synthesize(String text) async {
    try {
      final bytes = await _channel.invokeMethod<Uint8List>('synthesize', {
        'text': text,
      });
      return bytes;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
