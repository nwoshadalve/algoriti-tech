// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/queue/domain/session_stop_time.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime? stop(DateTime openedAt, {String boundary = '03:00'}) => sessionStopAt(
  openedAt: openedAt,
  boundary: boundary,
  timeZone: 'Asia/Dhaka',
);

void main() {
  test('should stop at the next 03:00 clinic time when opened in the day', () {
    // Friday 6 Nov 2026, 10:00 in Dhaka (04:00 UTC).
    final stopAt = stop(DateTime.utc(2026, 11, 6, 4));

    // Saturday 7 Nov, 03:00 in Dhaka (Friday 21:00 UTC).
    expect(stopAt, DateTime.utc(2026, 11, 6, 21));
  });

  test('should stop the same morning when opened before the boundary', () {
    // Saturday 7 Nov, 01:00 in Dhaka (Friday 19:00 UTC).
    final stopAt = stop(DateTime.utc(2026, 11, 6, 19));

    expect(stopAt, DateTime.utc(2026, 11, 6, 21));
  });

  test('should wait for the next day when opened exactly at the boundary', () {
    final stopAt = stop(DateTime.utc(2026, 11, 6, 21));

    expect(stopAt, DateTime.utc(2026, 11, 7, 21));
  });

  test('should follow a boundary later in the day', () {
    // Opened 10:00 Dhaka, boundary 23:30: stops that same night.
    final stopAt = stop(DateTime.utc(2026, 11, 6, 4), boundary: '23:30');

    expect(stopAt, DateTime.utc(2026, 11, 6, 17, 30));
  });

  test('should refuse a boundary that is not a time', () {
    expect(stop(DateTime.utc(2026, 11, 6), boundary: 'soon'), isNull);
    expect(stop(DateTime.utc(2026, 11, 6), boundary: '25:00'), isNull);
    expect(stop(DateTime.utc(2026, 11, 6), boundary: '03:75'), isNull);
  });
}
