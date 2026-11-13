// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:math' as math;
import 'dart:typed_data';

/// The little of the WAV format the announcements need: 16-bit PCM audio.
final class Wav {
  const Wav({
    required this.sampleRate,
    required this.channels,
    required this.pcm,
  });

  final int sampleRate;
  final int channels;

  /// The samples, little-endian 16-bit.
  final Uint8List pcm;

  /// Reads [bytes], or throws a [FormatException] when it is not 16-bit PCM WAV.
  static Wav parse(List<int> bytes) {
    final data = Uint8List.fromList(bytes);
    if (data.length < 44 ||
        String.fromCharCodes(data.sublist(0, 4)) != 'RIFF' ||
        String.fromCharCodes(data.sublist(8, 12)) != 'WAVE') {
      throw const FormatException('Not a WAV file');
    }
    final view = ByteData.sublistView(data);
    int? rate;
    int? channels;
    var offset = 12;
    while (offset + 8 <= data.length) {
      final id = String.fromCharCodes(data.sublist(offset, offset + 4));
      final size = view.getUint32(offset + 4, Endian.little);
      final body = offset + 8;
      if (id == 'fmt ' && body + 16 <= data.length) {
        final format = view.getUint16(body, Endian.little);
        final bits = view.getUint16(body + 14, Endian.little);
        if (format != 1 || bits != 16) {
          throw const FormatException('Only 16-bit PCM is supported');
        }
        channels = view.getUint16(body + 2, Endian.little);
        rate = view.getUint32(body + 4, Endian.little);
      } else if (id == 'data') {
        if (rate == null || channels == null) {
          throw const FormatException('Audio data before its format');
        }
        // A streamed file may state a wrong size: take what is there.
        final end = body + size > data.length ? data.length : body + size;
        return Wav(
          sampleRate: rate,
          channels: channels,
          pcm: Uint8List.sublistView(data, body, end),
        );
      }
      offset = body + size + (size.isOdd ? 1 : 0);
    }
    throw const FormatException('No audio in the WAV file');
  }

  /// [wav] made as loud as it can be without distorting: the loudest sample is
  /// brought up to full scale (at most [maxGain] times), then [makeup] more is
  /// added, with a soft limiter that rounds off whatever would go past full
  /// scale. A speaker that is quiet at full volume needs this; the clips are
  /// recorded with a lot of headroom. Anything that is not 16-bit PCM WAV is
  /// returned as it is.
  static List<int> louder(
    List<int> wav, {
    double makeup = 1.8,
    double maxGain = 8,
  }) {
    final Wav parsed;
    try {
      parsed = parse(wav);
    } on FormatException {
      return wav;
    }
    final pcm = parsed.pcm;
    final count = pcm.length ~/ 2;
    final view = ByteData.sublistView(pcm);
    var peak = 0;
    for (var i = 0; i < count; i++) {
      final v = view.getInt16(i * 2, Endian.little).abs();
      if (v > peak) peak = v;
    }
    if (peak == 0) return wav;
    final gain = math.min(maxGain, 32767 * 0.98 / peak) * makeup;
    const knee = 0.6;
    final out = ByteData(count * 2);
    for (var i = 0; i < count; i++) {
      final v = view.getInt16(i * 2, Endian.little) / 32768 * gain;
      final a = v.abs();
      final limited = a <= knee
          ? a
          : knee + (1 - knee) * _tanh((a - knee) / (1 - knee));
      final sample = (limited * 32767).round().clamp(0, 32767);
      out.setInt16(i * 2, v < 0 ? -sample : sample, Endian.little);
    }
    return build(
      out.buffer.asUint8List(),
      sampleRate: parsed.sampleRate,
      channels: parsed.channels,
    );
  }

  static double _tanh(double x) {
    final e = math.exp(2 * x);
    return (e - 1) / (e + 1);
  }

  /// A WAV file of 16-bit [pcm].
  static List<int> build(
    Uint8List pcm, {
    required int sampleRate,
    int channels = 1,
  }) {
    final header = ByteData(44);
    void text(int at, String s) {
      for (var i = 0; i < s.length; i++) {
        header.setUint8(at + i, s.codeUnitAt(i));
      }
    }

    text(0, 'RIFF');
    header.setUint32(4, 36 + pcm.length, Endian.little);
    text(8, 'WAVE');
    text(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * channels * 2, Endian.little);
    header.setUint16(32, channels * 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    text(36, 'data');
    header.setUint32(40, pcm.length, Endian.little);
    return (BytesBuilder()
          ..add(header.buffer.asUint8List())
          ..add(pcm))
        .toBytes();
  }
}
