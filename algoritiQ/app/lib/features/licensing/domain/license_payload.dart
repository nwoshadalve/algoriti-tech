import 'dart:typed_data';

import 'device_code.dart';

/// What the licence was sold as.
enum LicenseType {
  /// One doctor, up to `maxChambers` chambers.
  doctor(1),

  /// One chamber, up to `maxDoctors` doctors.
  chamber(2);

  const LicenseType(this.code);

  final int code;

  static LicenseType fromCode(int code) => values.firstWhere(
    (type) => type.code == code,
    orElse: () => throw FormatException('Unknown licence type $code'),
  );
}

enum LicenseStatus {
  /// Within the licence period (or perpetual).
  active,

  /// Expired, but inside the grace period.
  grace,

  /// Expired beyond the grace period.
  expired,
}

/// The signed content of a licence key (20 bytes, big-endian).
///
/// ```text
/// 0 version | 1 keyId | 2 type | 3 maxDoctors | 4 maxChambers | 5 reserved
/// 6-7 issuedDay | 8-9 expiresDay (0xFFFF = never) | 10-15 device | 16-19 id
/// ```
final class LicensePayload {
  LicensePayload({
    required this.keyId,
    required this.type,
    required this.maxDoctors,
    required this.maxChambers,
    required this.issuedDay,
    required this.expiresDay,
    required this.device,
    required this.licenseId,
  }) {
    RangeError.checkValueInInterval(keyId, 0, 255, 'keyId');
    RangeError.checkValueInInterval(maxDoctors, 1, 255, 'maxDoctors');
    RangeError.checkValueInInterval(maxChambers, 1, 255, 'maxChambers');
    if (type == LicenseType.doctor && maxDoctors != 1) {
      throw ArgumentError('A doctor licence covers exactly 1 doctor');
    }
    if (type == LicenseType.chamber && maxChambers != 1) {
      throw ArgumentError('A chamber licence covers exactly 1 chamber');
    }
    if (licenseId.length != idLength) {
      throw ArgumentError('licenseId must be $idLength bytes');
    }
  }

  factory LicensePayload.decode(Uint8List bytes) {
    if (bytes.length != byteLength) {
      throw const FormatException('Bad licence length');
    }
    if (bytes[0] != version) {
      throw FormatException('Unsupported licence version ${bytes[0]}');
    }
    final data = ByteData.sublistView(bytes);
    final expires = data.getUint16(8);
    try {
      return LicensePayload(
        keyId: bytes[1],
        type: LicenseType.fromCode(bytes[2]),
        maxDoctors: bytes[3],
        maxChambers: bytes[4],
        issuedDay: data.getUint16(6),
        expiresDay: expires == _never ? null : expires,
        device: DeviceCode(Uint8List.sublistView(bytes, 10, 16)),
        licenseId: Uint8List.fromList(bytes.sublist(16, 20)),
      );
    } on ArgumentError catch (error) {
      throw FormatException('Invalid licence: ${error.message}');
    }
  }

  static const version = 1;
  static const byteLength = 20;
  static const idLength = 4;
  static const _never = 0xFFFF;

  final int keyId;
  final LicenseType type;
  final int maxDoctors;
  final int maxChambers;

  /// Days since 1970-01-01 (UTC).
  final int issuedDay;

  /// Last valid day (inclusive), days since 1970-01-01 UTC; null = perpetual.
  final int? expiresDay;
  final DeviceCode device;
  final Uint8List licenseId;

  static int dayOf(DateTime time) =>
      time.toUtc().millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

  static DateTime dateOf(int day) => DateTime.fromMillisecondsSinceEpoch(
    day * Duration.millisecondsPerDay,
    isUtc: true,
  );

  DateTime get issuedAt => dateOf(issuedDay);
  DateTime? get expiresAt => expiresDay == null ? null : dateOf(expiresDay!);

  /// Hex form of [licenseId], for the vendor ledger and support.
  String get licenseIdHex =>
      licenseId.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  LicenseStatus statusAt(
    DateTime now, {
    Duration grace = const Duration(days: 14),
  }) {
    final expires = expiresDay;
    if (expires == null) return LicenseStatus.active;
    final today = dayOf(now);
    if (today <= expires) return LicenseStatus.active;
    return today - expires <= grace.inDays
        ? LicenseStatus.grace
        : LicenseStatus.expired;
  }

  Uint8List encode() {
    final bytes = Uint8List(byteLength);
    final data = ByteData.sublistView(bytes);
    bytes[0] = version;
    bytes[1] = keyId;
    bytes[2] = type.code;
    bytes[3] = maxDoctors;
    bytes[4] = maxChambers;
    data.setUint16(6, issuedDay);
    data.setUint16(8, expiresDay ?? _never);
    bytes.setRange(10, 16, device.bytes);
    bytes.setRange(16, 20, licenseId);
    return bytes;
  }
}
