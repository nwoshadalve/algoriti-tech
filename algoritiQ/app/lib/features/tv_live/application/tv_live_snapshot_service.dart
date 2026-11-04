// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
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
  }) : _clinic = clinic,
       _board = board;

  final ClinicRepository _clinic;
  final DriftQueueBoardRepository _board;

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
    Map<String, List<int>> waiting = {
      for (final type in types) type.id: <int>[],
    };

    if (session != null) {
      waiting = await _board.waitingSerialsByQueueType(session.id);
      for (final type in types) {
        waiting.putIfAbsent(type.id, () => []);
      }
      final calledRow = await _board.calledTokenForSession(session.id);
      if (calledRow != null) {
        called = {
          'tokenId': calledRow.id,
          'queueTypeId': calledRow.queueTypeId,
          'serial': calledRow.serial,
        };
      }
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
      'waiting': waiting.map((key, value) => MapEntry(key, value)),
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
