// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/live_event_bus.dart';
import '../../../api/live_providers.dart';
import '../../clinic/application/clinic_providers.dart';
import '../../home/application/receptionist_work.dart';

/// How a TV test ended. Only a reply from the TV itself counts: "sent" is not
/// "shown".
enum TvTestOutcome {
  /// The TV put the test screen up.
  shown,

  /// The TV put the test screen up and played the test sound.
  played,

  /// The screen came up but the sound did not play.
  soundFailed,

  /// No TV of this chamber is connected.
  notConnected,

  /// A TV is connected but did not answer in time.
  noReply,

  /// The chamber is not known.
  noDetails,
}

/// Path of the test clip. The TV downloads it from the tablet over the same
/// pinned HTTPS connection as everything else, using its own token.
const tvTestAnnouncementPath = '/api/v1/tv/test-announcement';

final tvTestServiceProvider = Provider<TvTestService>((ref) {
  return TvTestService(
    bus: ref.watch(liveEventBusProvider),
    scopeId: () {
      final work = ref.read(receptionistWorkProvider);
      return work is ReceptionistWorkReady ? work.selected.id : null;
    },
    firstChamberId: () async {
      final chambers = await ref
          .read(clinicRepositoryProvider)
          .watchChambers()
          .first;
      return chambers.isEmpty ? null : chambers.first.id;
    },
    newTestId: () => 'test-${DateTime.now().toUtc().microsecondsSinceEpoch}',
  );
});

/// Asks the paired TV to show a test screen and, optionally, play a test
/// sound, then waits for the TV to say what it did. The real queue and the
/// real display are not touched.
class TvTestService {
  TvTestService({
    required LiveEventBus bus,
    required String? Function() scopeId,
    required Future<String?> Function() firstChamberId,
    required String Function() newTestId,
    this.replyWithin = const Duration(seconds: 12),
  }) : _bus = bus,
       _scopeId = scopeId,
       _firstChamberId = firstChamberId,
       _newTestId = newTestId;

  final LiveEventBus _bus;
  final String? Function() _scopeId;
  final Future<String?> Function() _firstChamberId;
  final String Function() _newTestId;

  /// Long enough for the TV to download and play the clip.
  final Duration replyWithin;

  Future<TvTestOutcome> testDisplay() => _run(sound: false);

  Future<TvTestOutcome> testSound() => _run(sound: true);

  /// Same as [testDisplay], but uses the first chamber when no scope is set.
  Future<TvTestOutcome> testDisplayForAdmin() =>
      _run(sound: false, forAdmin: true);

  Future<TvTestOutcome> testSoundForAdmin() =>
      _run(sound: true, forAdmin: true);

  Future<TvTestOutcome> _run({
    required bool sound,
    bool forAdmin = false,
  }) async {
    final chamberId = forAdmin ? await _firstChamberId() : _scopeId();
    if (chamberId == null || chamberId.isEmpty) return TvTestOutcome.noDetails;
    if (_bus.tvPresence(chamberId) == null) return TvTestOutcome.notConnected;

    final testId = _newTestId();
    // Listen before sending: the TV may answer within the same moment.
    final reply = _bus.testAcks
        .firstWhere((a) => a.testId == testId)
        .then<TvTestAck?>((ack) => ack)
        .timeout(replyWithin, onTimeout: () => null);
    final sent = _bus.sendToTv(chamberId, 'tv.test', {
      'chamberId': chamberId,
      'testId': testId,
      if (sound) 'announcementUrl': tvTestAnnouncementPath,
    });
    if (sent == 0) {
      unawaited(reply);
      return TvTestOutcome.notConnected;
    }
    final ack = await reply;
    if (ack == null || !ack.displayShown) return TvTestOutcome.noReply;
    if (!sound) return TvTestOutcome.shown;
    return ack.audio == TvAudioResult.played
        ? TvTestOutcome.played
        : TvTestOutcome.soundFailed;
  }
}
