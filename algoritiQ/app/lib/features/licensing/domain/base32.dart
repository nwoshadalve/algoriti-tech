import 'dart:typed_data';

const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

/// Crockford base32: no I, L, O, U. Easy to read aloud and type.
abstract final class Base32 {
  static String encode(Uint8List bytes) {
    final out = StringBuffer();
    var buffer = 0;
    var bits = 0;
    for (final byte in bytes) {
      buffer = (buffer << 8) | byte;
      bits += 8;
      while (bits >= 5) {
        out.write(_alphabet[(buffer >> (bits - 5)) & 31]);
        bits -= 5;
      }
      buffer &= (1 << bits) - 1;
    }
    if (bits > 0) out.write(_alphabet[(buffer << (5 - bits)) & 31]);
    return out.toString();
  }

  /// Decodes [input], ignoring case, spaces and dashes; O is read as 0 and
  /// I/L as 1. Throws [FormatException] on invalid characters or non-zero
  /// padding bits.
  static Uint8List decode(String input) {
    final bytes = <int>[];
    var buffer = 0;
    var bits = 0;
    for (final unit in input.toUpperCase().codeUnits) {
      var char = String.fromCharCode(unit);
      if (char == '-' || char.trim().isEmpty) continue;
      if (char == 'O') char = '0';
      if (char == 'I' || char == 'L') char = '1';
      final value = _alphabet.indexOf(char);
      if (value < 0) throw FormatException('Invalid character "$char"');
      buffer = (buffer << 5) | value;
      bits += 5;
      if (bits >= 8) {
        bytes.add((buffer >> (bits - 8)) & 255);
        bits -= 8;
      }
      buffer &= (1 << bits) - 1;
    }
    if (buffer != 0) throw const FormatException('Non-zero padding bits');
    return Uint8List.fromList(bytes);
  }
}
