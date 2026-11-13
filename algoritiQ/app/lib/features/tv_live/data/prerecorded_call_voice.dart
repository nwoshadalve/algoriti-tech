// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

import '../application/call_clip_keys.dart';
import '../domain/call_voice.dart';
import 'wav.dart';

/// Speaks a call by joining short recorded clips (the voice pack): fully
/// offline, and as natural as the recordings. A call is "token number", the
/// serial digit by digit, and a closing phrase for the queue (and for a
/// recall). It never says the patient's name. Every clip must be the same
/// format; when one is missing or does not match, no clip is made and the
/// caller falls back to another voice.
final class PrerecordedCallVoice implements CallVoice {
  PrerecordedCallVoice({
    required this.load,
    this.gap = const Duration(milliseconds: 80),
    this.numberGap = const Duration(milliseconds: 140),
  });

  /// The bytes of the clip `<key>.wav`, or null when the pack has none.
  final Future<List<int>?> Function(String key) load;

  /// The pause between the phrases of a call (number | closing). The
  /// words inside a phrase run on into each other with no pause.
  final Duration gap;

  /// The pause between the words of the number itself ("একশো" | "এক"): a
  /// native speaker does not run 101 into one word.
  final Duration numberGap;

  @override
  Future<List<int>?> callClip({
    required int serial,
    required String queueTypeId,
    String queueLabelBn = '',
    bool recall = false,
  }) async {
    final List<String> numberKeys;
    try {
      numberKeys = callClipKeys(serial);
    } on RangeError {
      return null;
    }
    return _join(
      [
        callTokenKey,
        ...numberKeys,
        callClosingKey(queueTypeId, recall: recall),
      ],
      // The token key comes first, so the number is keys 1 .. numberKeys.length.
      wordsOfNumber: numberKeys.length,
    );
  }

  @override
  Future<List<int>?> testClip() => callClip(serial: 1001, queueTypeId: '');

  Future<List<int>?> _join(List<String> keys, {int wordsOfNumber = 0}) async {
    Wav? first;
    final pcm = BytesBuilder();
    for (var i = 0; i < keys.length; i++) {
      final bytes = await load(keys[i]);
      if (bytes == null) return null;
      final Wav wav;
      try {
        wav = Wav.parse(bytes);
      } on FormatException {
        return null;
      }
      first ??= wav;
      if (wav.sampleRate != first.sampleRate ||
          wav.channels != first.channels) {
        return null;
      }
      if (i > 0 && i == keys.length - 1) {
        pcm.add(_silence(first, gap));
      } else if (i >= 2 && i <= wordsOfNumber) {
        pcm.add(_silence(first, numberGap));
      }
      pcm.add(wav.pcm);
    }
    if (first == null) return null;
    return Wav.build(
      pcm.toBytes(),
      sampleRate: first.sampleRate,
      channels: first.channels,
    );
  }

  Uint8List _silence(Wav like, Duration length) {
    final samples = like.sampleRate * length.inMicroseconds ~/ 1000000;
    return Uint8List(samples * like.channels * 2);
  }
}
