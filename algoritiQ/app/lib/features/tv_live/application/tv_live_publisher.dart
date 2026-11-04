// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

/// Pushes waiting-room display updates to TV clients over the live WebSocket.
abstract interface class TvLivePublisher {
  /// Full snapshot payload for every chamber display (connect / reconnect).
  Future<Map<String, Object?>> buildLiveSnapshot();

  /// Queue board changed for one chamber (issue, enter, skip, cancel, session).
  Future<void> notifyQueueUpdated(String chamberId);

  /// A token was called or recalled; [callId] deduplicates announcement playback.
  Future<void> notifyTokenCalled({
    required String chamberId,
    required String tokenId,
    required String queueTypeId,
    required int serial,
    required String callId,
    String? announcementUrl,
  });
}

/// No-op for tests and when the API host is not running.
final class NullTvLivePublisher implements TvLivePublisher {
  const NullTvLivePublisher();

  @override
  Future<Map<String, Object?>> buildLiveSnapshot() async => const {
    'displays': [],
  };

  @override
  Future<void> notifyQueueUpdated(String chamberId) async {}

  @override
  Future<void> notifyTokenCalled({
    required String chamberId,
    required String tokenId,
    required String queueTypeId,
    required int serial,
    required String callId,
    String? announcementUrl,
  }) async {}
}
