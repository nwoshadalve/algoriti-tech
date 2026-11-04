// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/live_providers.dart';

/// Whether the chamber's TV is connected right now, as the bus sees it.
final tvConnectedProvider = StreamProvider.autoDispose.family<bool, String>((
  ref,
  chamberId,
) async* {
  final bus = ref.watch(liveEventBusProvider);
  yield bus.tvPresence(chamberId) != null;
  // Heartbeat sweeps drop a silent TV without a socket event, so look again
  // on a timer as well as on every connect or leave.
  final changes = bus.tvChanges.where((id) => id == chamberId);
  final ticks = Stream<void>.periodic(const Duration(seconds: 10));
  await for (final _ in _merge(changes, ticks)) {
    yield bus.tvPresence(chamberId) != null;
  }
});

Stream<void> _merge(Stream<void> a, Stream<void> b) async* {
  final merged = <Stream<void>>[a, b];
  final controller = StreamController<void>();
  final subs = [for (final s in merged) s.listen((_) => controller.add(null))];
  controller.onCancel = () async {
    for (final sub in subs) {
      await sub.cancel();
    }
  };
  yield* controller.stream;
}
