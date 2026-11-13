// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:collection';

import '../domain/call_voice.dart';

/// Prepares the spoken call for the waiting-room TV.
abstract interface class AnnouncementPreparer {
  /// Makes the clip for one call and returns the address the TV fetches it
  /// from, or null when no clip could be made. Never throws: the queue must
  /// not wait on, or fail because of, the voice.
  Future<String?> prepare({
    required String callId,
    required int serial,
    required String queueTypeId,
    required String queueLabelBn,
    bool recall = false,
  });
}

/// For tests and when there is no voice: calls go out silent.
final class NullAnnouncementPreparer implements AnnouncementPreparer {
  const NullAnnouncementPreparer();

  @override
  Future<String?> prepare({
    required String callId,
    required int serial,
    required String queueTypeId,
    required String queueLabelBn,
    bool recall = false,
  }) async => null;
}

/// Has the tablet's voices speak a call and keeps the last few clips so the TV
/// can fetch them over the local API. A call says the token number and the
/// queue, never the patient's name.
///
/// The [voices] are tried in order and the first that can make the clip wins:
/// the recorded voice pack first, the phone's own text-to-speech after it.
/// The same call is spoken once: a recall reuses the clip already made, so it
/// is ready at once.
class AnnouncementService implements AnnouncementPreparer {
  AnnouncementService({
    required List<CallVoice> voices,
    this.timeout = const Duration(seconds: 6),
    this.keep = 30,
  }) : _voices = voices;

  final List<CallVoice> _voices;

  /// How long a call may wait for its voice.
  final Duration timeout;

  /// How many clips are kept.
  final int keep;

  /// Where the TV fetches the clip of one call.
  static String pathFor(String callId) => '/api/v1/tv/announcements/$callId';

  final _byCall = LinkedHashMap<String, List<int>>();
  final _bySerial = LinkedHashMap<String, List<int>>();
  List<int>? _test;

  @override
  Future<String?> prepare({
    required String callId,
    required int serial,
    required String queueTypeId,
    required String queueLabelBn,
    bool recall = false,
  }) async {
    final key = '$serial|$queueTypeId|$recall';
    var clip = _bySerial[key];
    if (clip == null) {
      clip = await _first(
        (voice) => voice.callClip(
          serial: serial,
          queueTypeId: queueTypeId,
          queueLabelBn: queueLabelBn,
          recall: recall,
        ),
      );
      if (clip == null) return null;
      _remember(_bySerial, key, clip);
    }
    _remember(_byCall, callId, clip);
    return pathFor(callId);
  }

  /// The clip of a call made earlier, or null when it is unknown or forgotten.
  List<int>? clip(String callId) => _byCall[callId];

  /// A spoken sample for the TV sound test, or null when there is no voice.
  Future<List<int>?> testClip() async =>
      _test ??= await _first((voice) => voice.testClip());

  void _remember(Map<String, List<int>> into, String key, List<int> clip) {
    into.remove(key);
    into[key] = clip;
    while (into.length > keep) {
      into.remove(into.keys.first);
    }
  }

  /// The first clip any voice makes, within [timeout] overall.
  Future<List<int>?> _first(
    Future<List<int>?> Function(CallVoice voice) make,
  ) async {
    final deadline = DateTime.now().add(timeout);
    for (final voice in _voices) {
      final left = deadline.difference(DateTime.now());
      if (left <= Duration.zero) return null;
      try {
        final clip = await make(voice).timeout(left);
        if (clip != null && clip.isNotEmpty) return clip;
      } on Object {
        // This voice failed: try the next.
      }
    }
    return null;
  }
}
