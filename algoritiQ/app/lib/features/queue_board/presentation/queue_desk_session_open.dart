// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True when the native queue desk has an open session (hides welcome header).
final queueDeskSessionOpenProvider =
    NotifierProvider<QueueDeskSessionOpenNotifier, bool>(
      QueueDeskSessionOpenNotifier.new,
    );

class QueueDeskSessionOpenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setOpen(bool open) => state = open;
}
