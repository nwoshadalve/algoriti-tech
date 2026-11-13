// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import '../../../core/database/app_database.dart';
import '../../clinic/domain/chamber.dart';
import '../../clinic/domain/clinic_repository.dart';
import '../../clinic/domain/doctor.dart';
import '../../queue/domain/queue_models.dart';
import '../../queue_board/data/drift_queue_board_repository.dart';

/// Builds TV waiting-room JSON aligned with `mock/tv-app` (doctor footer, called
/// serial, waiting lists). Public surfaces stay serial + queue type only.
final class TvLiveSnapshotService {
  TvLiveSnapshotService({
    required ClinicRepository clinic,
    required DriftQueueBoardRepository board,
    DateTime Function() clock = DateTime.now,
  }) : _clinic = clinic,
       _board = board,
       _clock = clock;

  final ClinicRepository _clinic;
  final DriftQueueBoardRepository _board;
  final DateTime Function() _clock;

  Future<Map<String, Object?>> buildFullSnapshot() async {
    final chambers = await _clinic.watchChambers().first;
    final displays = <Map<String, Object?>>[];
    for (final chamber in chambers) {
      displays.add(await buildChamberDisplay(chamber.id));
    }
    return {'displays': displays};
  }

  Future<Map<String, Object?>> buildChamberDisplay(String chamberId) async {
    await _board.ensureClinicDefaults();
    final chamber = await _clinic.chamberById(chamberId);
    if (chamber == null) {
      return {'chamberId': chamberId, 'sessionOpen': false};
    }
    final doctor = await _doctorForChamber(chamber);
    final session = await _board.openSessionForChamber(chamberId);
    final types =
        (await _board.typesForChamber(chamberId))
            .where((t) => t.enabled)
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    Map<String, Object?>? called;
    final calledList = <Map<String, Object?>>[];
    Map<String, List<int>> waiting = {
      for (final type in types) type.id: <int>[],
    };
    // How long each waiting serial has waited, in seconds as of now, in the
    // same order as [waiting]. The board adds the time since it received this.
    final waitedSeconds = <String, List<int>>{};

    if (session != null) {
      waiting = await _board.waitingSerialsByQueueType(session.id);
      final now = _clock().millisecondsSinceEpoch;
      final issued = await _board.waitingIssuedAtByQueueType(session.id);
      issued.forEach((typeId, times) {
        waitedSeconds[typeId] = [
          for (final at in times) ((now - at) ~/ 1000).clamp(0, 1 << 31),
        ];
      });
      for (final type in types) {
        waiting.putIfAbsent(type.id, () => []);
      }
      final calledRows = await _board.calledTokensForSession(session.id);
      Map<String, Object?> json(QueueTokenRow row) => {
        'tokenId': row.id,
        'queueTypeId': row.queueTypeId,
        'serial': row.serial,
        // False while the token is on the board as the next one and has not
        // been announced yet: the board outlines it.
        'announced': row.announcedAt != null,
      };
      // In the queues' order; `called` is the newest call (the rows come
      // oldest first), which a TV that only knows one call shows.
      for (final type in types) {
        calledList.addAll([
          for (final row in calledRows)
            if (row.queueTypeId == type.id) json(row),
        ]);
      }
      if (calledRows.isNotEmpty) called = json(calledRows.last);
    }

    return {
      'chamberId': chamberId,
      'sessionOpen': session != null,
      if (session != null) ...{
        'sessionId': session.id,
        'businessDate': session.businessDate,
      },
      'doctor': doctor == null ? null : _doctorJson(doctor),
      'chamber': _chamberJson(chamber),
      'queueTypes': [for (final t in types) _queueTypeJson(t)],
      'called': called,
      'calledList': calledList,
      'waiting': waiting.map((key, value) => MapEntry(key, value)),
      'waitedSeconds': waitedSeconds,
    };
  }

  Future<Doctor?> _doctorForChamber(Chamber chamber) async {
    final doctors = await _clinic.watchDoctors().first;
    for (final doctor in doctors) {
      if (doctor.id == chamber.doctorId) return doctor;
    }
    return null;
  }

  Map<String, Object?> _doctorJson(Doctor doctor) => {
    'id': doctor.id,
    'name': doctor.name,
    'degrees': doctor.degrees,
    'designation': doctor.designation ?? '',
    'workplace': doctor.workplace ?? '',
    'registrationNumber': doctor.registrationNumber ?? '',
    'specialty': doctor.specialty ?? '',
    'photoVersion': doctor.photoPath == null ? 0 : doctor.photoPath.hashCode,
    'photoUrl': '/api/v1/tv/doctor-photo?doctor=${doctor.id}',
  };

  Map<String, Object?> _chamberJson(Chamber chamber) => {
    'id': chamber.id,
    'doctorId': chamber.doctorId,
    'name': chamber.name,
    'location': chamber.location ?? '',
    'phone': chamber.phone ?? '',
  };

  Map<String, Object?> _queueTypeJson(QueueTypeConfig type) => {
    'id': type.id,
    'englishName': type.englishName,
    'bengaliName': type.bengaliName,
  };
}
