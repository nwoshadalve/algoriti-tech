// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../domain/call_voice.dart';
import 'wav.dart';

/// A voice whose clips are made as loud as they can be (see [Wav.louder]), so
/// a call is heard over a TV speaker or a cast that plays quietly. Clips that
/// are not 16-bit PCM WAV come through unchanged.
final class LoudCallVoice implements CallVoice {
  const LoudCallVoice(this.voice);

  final CallVoice voice;

  @override
  Future<List<int>?> callClip({
    required int serial,
    required String queueTypeId,
    String queueLabelBn = '',
    bool recall = false,
  }) async => _louder(
    await voice.callClip(
      serial: serial,
      queueTypeId: queueTypeId,
      queueLabelBn: queueLabelBn,
      recall: recall,
    ),
  );

  @override
  Future<List<int>?> testClip() async => _louder(await voice.testClip());

  static List<int>? _louder(List<int>? clip) =>
      clip == null || clip.isEmpty ? clip : Wav.louder(clip);
}
