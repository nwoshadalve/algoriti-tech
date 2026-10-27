import 'dart:convert';

import 'package:cryptography/dart.dart';

/// Links audit entries so any edit or deletion is detectable: each entry's
/// hash covers the previous entry's hash and its own content.
abstract final class AuditChain {
  /// The "previous hash" of the first entry.
  static final genesis = '0' * 64;

  static String hashOf({
    required String previousHash,
    required DateTime at,
    required String? actorId,
    required String action,
    required String? detail,
  }) {
    final text = [
      previousHash,
      at.toUtc().millisecondsSinceEpoch,
      actorId ?? '',
      action,
      detail ?? '',
    ].join('|');
    final digest = const DartSha256().hashSync(utf8.encode(text));
    return [
      for (final byte in digest.bytes) byte.toRadixString(16).padLeft(2, '0'),
    ].join();
  }
}
