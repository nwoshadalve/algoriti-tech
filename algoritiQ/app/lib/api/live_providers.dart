// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/clinic/application/clinic_providers.dart';
import '../../features/queue_board/application/queue_board_repository_provider.dart';
import '../../features/tv_live/application/tv_live_publisher.dart';
import '../../features/tv_live/application/tv_live_snapshot_service.dart';
import 'live_event_bus.dart';
import 'tv_live_publisher_impl.dart';

final tvLiveSnapshotServiceProvider = Provider<TvLiveSnapshotService>(
  (ref) => TvLiveSnapshotService(
    clinic: ref.watch(clinicRepositoryProvider),
    board: ref.watch(queueBoardRepositoryProvider),
  ),
);

/// Shared bus for [LocalApiHost] and queue mutations.
final liveEventBusProvider = Provider<LiveEventBus>((ref) {
  final snapshots = ref.watch(tvLiveSnapshotServiceProvider);
  late final LiveEventBus bus;
  bus = LiveEventBus(
    snapshotPayload: () async {
      final publisher = TvLivePublisherImpl(bus: bus, snapshots: snapshots);
      return publisher.buildLiveSnapshot();
    },
  );
  return bus;
});

final tvLivePublisherProvider = Provider<TvLivePublisher>((ref) {
  final bus = ref.watch(liveEventBusProvider);
  return TvLivePublisherImpl(
    bus: bus,
    snapshots: ref.watch(tvLiveSnapshotServiceProvider),
  );
});
