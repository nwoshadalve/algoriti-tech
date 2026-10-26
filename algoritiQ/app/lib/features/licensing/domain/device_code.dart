import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'base32.dart';

/// Short code identifying one device, shown on the activation screen.
///
/// 48 bits of SHA-256 over `algoritiq:device:v1:<androidId>`, displayed as
/// `XXXXX-XXXXX`. The raw Android ID never leaves the device.
final class DeviceCode {
  DeviceCode(Uint8List bytes) : bytes = Uint8List.fromList(bytes) {
    if (bytes.length != byteLength) {
      throw ArgumentError('Device code must be $byteLength bytes');
    }
  }

  /// Parses `XXXXX-XXXXX` (case, dashes and spaces are tolerated).
  factory DeviceCode.parse(String input) => DeviceCode(Base32.decode(input));

  static const byteLength = 6;

  final Uint8List bytes;

  static Future<DeviceCode> fromAndroidId(String androidId) async {
    final hash = await Sha256().hash(
      utf8.encode('algoritiq:device:v1:$androidId'),
    );
    return DeviceCode(Uint8List.fromList(hash.bytes.sublist(0, byteLength)));
  }

  @override
  String toString() {
    final text = Base32.encode(bytes);
    return '${text.substring(0, 5)}-${text.substring(5)}';
  }

  @override
  bool operator ==(Object other) =>
      other is DeviceCode && _bytesEqual(bytes, other.bytes);

  @override
  int get hashCode => Object.hashAll(bytes);
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
