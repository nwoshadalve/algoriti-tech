// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../features/tv_live/application/tv_live_publisher.dart';
import '../features/tv_live/application/tv_live_snapshot_service.dart';
import 'live_event_bus.dart';

/// Forwards TV display state through [LiveEventBus] (`/api/v1/ws/live`).
final class TvLivePublisherImpl implements TvLivePublisher {
  TvLivePublisherImpl({
    required LiveEventBus bus,
    required TvLiveSnapshotService snapshots,
  }) : _bus = bus,
       _snapshots = snapshots;

  final LiveEventBus _bus;
  final TvLiveSnapshotService _snapshots;

  @override
  Future<Map<String, Object?>> buildLiveSnapshot() =>
      _snapshots.buildFullSnapshot();

  @override
  Future<void> notifyQueueUpdated(String chamberId) async {
    final display = await _snapshots.buildChamberDisplay(chamberId);
    _bus.publish('queue.updated', {'chamberId': chamberId, 'display': display});
  }

  @override
  Future<void> notifyTokenCalled({
    required String chamberId,
    required String tokenId,
    required String queueTypeId,
    required int serial,
    required String callId,
    String? announcementUrl,
  }) async {
    final display = await _snapshots.buildChamberDisplay(chamberId);
    _bus.publish('token.called', {
      'chamberId': chamberId,
      'tokenId': tokenId,
      'queueTypeId': queueTypeId,
      'serial': serial,
      'callId': callId,
      if (announcementUrl != null) 'announcementUrl': announcementUrl,
      'display': display,
    });
  }
}
