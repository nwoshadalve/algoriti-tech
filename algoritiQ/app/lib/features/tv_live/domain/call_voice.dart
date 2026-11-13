// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

/// A voice that can speak a call, as one WAV clip.
abstract interface class CallVoice {
  /// The spoken call of [serial] in the queue [queueTypeId] ([queueLabelBn] is
  /// its Bengali name), or null when this voice cannot make it. The call says
  /// the token number and the queue, never the patient's name. A [recall] is
  /// the reminder, worded differently from the first call.
  Future<List<int>?> callClip({
    required int serial,
    required String queueTypeId,
    String queueLabelBn = '',
    bool recall = false,
  });

  /// A sample call for checking the TV's speaker, or null.
  Future<List<int>?> testClip();
}
