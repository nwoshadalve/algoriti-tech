import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Source of new record ids. Inject instead of generating ids in logic.
typedef IdGenerator = String Function();

final idGeneratorProvider = Provider<IdGenerator>((ref) {
  final random = Random.secure();
  return () => _uuidV4(random);
});

String _uuidV4(Random random) {
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = [for (final b in bytes) b.toRadixString(16).padLeft(2, '0')];
  return '${hex.sublist(0, 4).join()}-${hex.sublist(4, 6).join()}-'
      '${hex.sublist(6, 8).join()}-${hex.sublist(8, 10).join()}-'
      '${hex.sublist(10).join()}';
}
