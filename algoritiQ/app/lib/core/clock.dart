import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Source of "now". Inject instead of calling `DateTime.now()` in logic.
typedef Clock = DateTime Function();

final clockProvider = Provider<Clock>((ref) => DateTime.now);
