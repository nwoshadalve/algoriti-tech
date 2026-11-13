// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

/// Time zones the clinic can be set to, as a fixed offset from UTC. Bangladesh
/// has no daylight saving, so a fixed offset is exact. Any other name falls
/// back to the tablet's own offset.
const _fixedOffsets = {'Asia/Dhaka': Duration(hours: 6)};

/// How far the clinic clock is ahead of UTC at [at], for the clinic's [timeZone].
Duration clinicUtcOffset(String timeZone, DateTime at) =>
    _fixedOffsets[timeZone] ?? at.toLocal().timeZoneOffset;

/// When a session opened at [openedAt] stops by itself: the first time the
/// clinic clock shows [boundary] (`HH:mm`) after the session opened.
///
/// A session opened on Friday at 10:00 with a boundary of 03:00 stops on
/// Saturday at 03:00; one opened at 01:00 stops at 03:00 the same morning.
/// Returns null when [boundary] is not a valid `HH:mm`.
DateTime? sessionStopAt({
  required DateTime openedAt,
  required String boundary,
  required String timeZone,
}) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(boundary.trim());
  if (match == null) return null;
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  if (hour > 23 || minute > 59) return null;

  final opened = openedAt.toUtc();
  final offset = _fixedOffsets[timeZone] ?? openedAt.toLocal().timeZoneOffset;
  // The clinic's wall clock, kept in a UTC DateTime so the day maths is plain.
  final wall = opened.add(offset);
  var stopWall = DateTime.utc(wall.year, wall.month, wall.day, hour, minute);
  if (!stopWall.isAfter(wall)) {
    stopWall = DateTime.utc(wall.year, wall.month, wall.day + 1, hour, minute);
  }
  return stopWall.subtract(offset);
}
