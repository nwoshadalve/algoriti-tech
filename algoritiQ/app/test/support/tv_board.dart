// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

/// One queue type on the waiting-room board: who is next, and how many more.
final class TvBoardQueue {
  const TvBoardQueue({
    required this.label,
    required this.waiting,
    this.waited = const [],
    this.hidden = 0,
  });

  final String label;

  /// The next serials in line, in order (at most [TvBoard.maxVisible]).
  final List<int> waiting;

  /// Seconds each of [waiting] had waited when the board was made, in the same
  /// order. The board adds the time that has passed since.
  final List<int> waited;

  /// How many more are waiting than [waiting] shows.
  final int hidden;
}

/// A token being called now, with the queue it belongs to.
final class TvBoardCall {
  const TvBoardCall({
    required this.serial,
    required this.label,
    this.announced = true,
  });

  final int serial;
  final String label;

  /// False while the call is on the board but not yet announced: its tile is
  /// outlined in orange until the receptionist announces it.
  final bool announced;
}

/// What the waiting-room board shows for one chamber, the same facts the
/// Android TV app shows: the doctor and chamber, the number being called, and
/// who is waiting. Built from the display the tablet already publishes to TVs.
final class TvBoard {
  const TvBoard({
    this.calledSerial,
    this.calls = const [],
    this.callPulse = 0,
    this.queues = const [],
    this.doctorId = '',
    this.doctorName = '',
    this.degrees = '',
    this.designation = '',
    this.specialty = '',
    this.workplace = '',
    this.registration = '',
    this.chamberName = '',
    this.chamberLocation = '',
    this.chamberPhone = '',
  });

  /// More than this many waiting in a queue show as "N more".
  static const maxVisible = 4;

  factory TvBoard.fromDisplay(
    Map<String, Object?> display, {
    int callPulse = 0,
  }) {
    final types = _list(display['queueTypes']).map(_map).toList();
    final waiting = _map(display['waiting']);
    final waited = _map(display['waitedSeconds']);
    final queues = [
      for (final type in types)
        _queue(
          label: _text(type['bengaliName']).isEmpty
              ? _text(type['id'])
              : _text(type['bengaliName']),
          serials: _list(waiting[_text(type['id'])]).whereType<int>().toList(),
          waited: _list(waited[_text(type['id'])]).whereType<int>().toList(),
        ),
    ];
    final called = _map(display['called']);
    final labels = {
      for (final type in types)
        _text(type['id']): _text(type['bengaliName']).isEmpty
            ? _text(type['id'])
            : _text(type['bengaliName']),
    };
    // Every call in the queues' order; a payload that only knows one call
    // (an older tablet) gives that one.
    final listed = _list(display['calledList']).map(_map).toList();
    final calls = [
      for (final call
          in listed.isEmpty && called.isNotEmpty ? [called] : listed)
        if (call['serial'] is int)
          TvBoardCall(
            serial: call['serial'] as int,
            label: labels[_text(call['queueTypeId'])] ?? '',
            announced: call['announced'] is bool
                ? call['announced'] as bool
                : true,
          ),
    ];
    final doctor = _map(display['doctor']);
    final chamber = _map(display['chamber']);
    return TvBoard(
      calledSerial: called['serial'] is int ? called['serial'] as int : null,
      calls: calls,
      callPulse: callPulse,
      queues: queues,
      doctorId: _text(doctor['id']),
      doctorName: _text(doctor['name']),
      degrees: _list(doctor['degrees']).whereType<String>().join(' · '),
      designation: _text(doctor['designation']),
      specialty: _text(doctor['specialty']),
      workplace: _text(doctor['workplace']),
      registration: _text(doctor['registrationNumber']),
      chamberName: _text(chamber['name']),
      chamberLocation: _text(chamber['location']),
      chamberPhone: _text(chamber['phone']),
    );
  }

  /// The board from plain data, as the second screen's own engine receives it.
  factory TvBoard.fromJson(Map<Object?, Object?> json) => TvBoard(
    calledSerial: json['calledSerial'] is int
        ? json['calledSerial'] as int
        : null,
    calls: [
      for (final call in _list(json['calls']))
        if (_map(call)['serial'] is int)
          TvBoardCall(
            serial: _map(call)['serial'] as int,
            label: _text(_map(call)['label']),
            announced: _map(call)['announced'] is bool
                ? _map(call)['announced'] as bool
                : true,
          ),
    ],
    callPulse: json['callPulse'] is int ? json['callPulse'] as int : 0,
    queues: [
      for (final queue in _list(json['queues']))
        TvBoardQueue(
          label: _text(_map(queue)['label']),
          waiting: _list(_map(queue)['waiting']).whereType<int>().toList(),
          waited: _list(_map(queue)['waited']).whereType<int>().toList(),
          hidden: _map(queue)['hidden'] is int
              ? _map(queue)['hidden'] as int
              : 0,
        ),
    ],
    doctorId: _text(json['doctorId']),
    doctorName: _text(json['doctorName']),
    degrees: _text(json['degrees']),
    designation: _text(json['designation']),
    specialty: _text(json['specialty']),
    workplace: _text(json['workplace']),
    registration: _text(json['registration']),
    chamberName: _text(json['chamberName']),
    chamberLocation: _text(json['chamberLocation']),
    chamberPhone: _text(json['chamberPhone']),
  );

  /// The board as plain data, to hand to the second screen's own engine.
  Map<String, Object?> toJson() => {
    'calledSerial': calledSerial,
    'calls': [
      for (final call in calls)
        {
          'serial': call.serial,
          'label': call.label,
          'announced': call.announced,
        },
    ],
    'callPulse': callPulse,
    'queues': [
      for (final queue in queues)
        {
          'label': queue.label,
          'waiting': queue.waiting,
          'waited': queue.waited,
          'hidden': queue.hidden,
        },
    ],
    'doctorId': doctorId,
    'doctorName': doctorName,
    'degrees': degrees,
    'designation': designation,
    'specialty': specialty,
    'workplace': workplace,
    'registration': registration,
    'chamberName': chamberName,
    'chamberPhone': chamberPhone,
    'chamberLocation': chamberLocation,
  };

  /// The token called most recently: the one the board flashes.
  final int? calledSerial;

  /// Every token being called now, one per queue at most, in the queues' order.
  final List<TvBoardCall> calls;

  /// Goes up on every call, a recall of the same number included, so the
  /// board can show the call again.
  final int callPulse;
  final List<TvBoardQueue> queues;
  final String doctorId;
  final String doctorName;
  final String degrees;
  final String designation;
  final String specialty;
  final String workplace;
  final String registration;
  final String chamberName;
  final String chamberLocation;
  final String chamberPhone;

  TvBoard withCallPulse(int pulse) => TvBoard(
    calledSerial: calledSerial,
    calls: calls,
    callPulse: pulse,
    queues: queues,
    doctorId: doctorId,
    doctorName: doctorName,
    degrees: degrees,
    designation: designation,
    specialty: specialty,
    workplace: workplace,
    registration: registration,
    chamberName: chamberName,
    chamberLocation: chamberLocation,
    chamberPhone: chamberPhone,
  );

  static TvBoardQueue _queue({
    required String label,
    required List<int> serials,
    required List<int> waited,
  }) {
    final shown = serials.take(maxVisible).toList();
    return TvBoardQueue(
      label: label,
      waiting: shown,
      waited: [
        for (var i = 0; i < shown.length; i++)
          i < waited.length ? waited[i] : 0,
      ],
      hidden: serials.length - shown.length,
    );
  }

  static List<Object?> _list(Object? value) =>
      value is List ? List<Object?>.from(value) : const [];

  static Map<String, Object?> _map(Object? value) =>
      value is Map ? Map<String, Object?>.from(value) : const {};

  static String _text(Object? value) => value is String ? value : '';
}
