// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

/// Turns Bengali text into spoken audio, on the tablet.
abstract interface class SpeechSynthesizer {
  /// WAV bytes of [text] spoken in Bengali, or null when no voice can do it.
  Future<List<int>?> synthesize(String text);
}
