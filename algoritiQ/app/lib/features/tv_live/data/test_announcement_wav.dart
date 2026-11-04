// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

/// Mono WAV clip for TV speaker checks: three clear notes, about 1.5 s, loud
/// enough to hear across a waiting room at a modest TV volume.
Uint8List buildTestAnnouncementWav() {
  const sampleRate = 22050;
  const durationSeconds = 1.5;
  final numSamples = (sampleRate * durationSeconds).round();
  const bytesPerSample = 2;
  final dataSize = numSamples * bytesPerSample;
  final headerSize = 44;
  final bytes = Uint8List(headerSize + dataSize);
  final view = ByteData.view(bytes.buffer);

  void writeString(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes[offset + i] = value.codeUnitAt(i);
    }
  }

  writeString(0, 'RIFF');
  view.setUint32(4, 36 + dataSize, Endian.little);
  writeString(8, 'WAVE');
  writeString(12, 'fmt ');
  view.setUint32(16, 16, Endian.little);
  view.setUint16(20, 1, Endian.little);
  view.setUint16(22, 1, Endian.little);
  view.setUint32(24, sampleRate, Endian.little);
  view.setUint32(28, sampleRate * bytesPerSample, Endian.little);
  view.setUint16(32, bytesPerSample, Endian.little);
  view.setUint16(34, 16, Endian.little);
  writeString(36, 'data');
  view.setUint32(40, dataSize, Endian.little);

  const notes = [660.0, 880.0, 1100.0];
  const amplitude = 0.85;
  const noteSeconds = durationSeconds / 3;
  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final note = (t / noteSeconds).floor().clamp(0, 2);
    final into = t - note * noteSeconds;
    // Each note fades in and out so the notes do not click.
    final envelope = into < 0.02
        ? into / 0.02
        : (noteSeconds - into < 0.08 ? (noteSeconds - into) / 0.08 : 1.0);
    final sample =
        (32767 *
                amplitude *
                envelope *
                _sin(2 * 3.141592653589793 * notes[note] * t))
            .round();
    view.setInt16(
      headerSize + i * 2,
      sample.clamp(-32768, 32767),
      Endian.little,
    );
  }
  return bytes;
}

double _sin(double x) {
  x %= 6.283185307179586;
  if (x > 3.141592653589793) x -= 6.283185307179586;
  final x2 = x * x;
  return x * (1 - x2 / 6 * (1 - x2 / 20));
}
