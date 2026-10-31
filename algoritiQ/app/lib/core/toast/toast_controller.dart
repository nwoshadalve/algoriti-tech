// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ToastKind { success, error, info }

/// One message in the toaster. Text is already localized by the caller.
final class ToastMessage {
  const ToastMessage({
    required this.id,
    required this.kind,
    required this.text,
  });

  final int id;
  final ToastKind kind;
  final String text;
}

/// The most toasts shown at once; the oldest goes when a sixth arrives.
const maxToasts = 5;

const _successDuration = Duration(milliseconds: 4500);
const _infoDuration = Duration(milliseconds: 4500);
const _errorDuration = Duration(seconds: 8);

final toastControllerProvider =
    NotifierProvider<ToastController, List<ToastMessage>>(ToastController.new);

/// The app-wide toaster: one place for "saved", "copied", "could not connect".
///
/// Success and info fade after a few seconds; errors stay longer. A message
/// identical to one already showing is not stacked twice.
class ToastController extends Notifier<List<ToastMessage>> {
  var _nextId = 0;
  final _timers = <int, Timer>{};

  @override
  List<ToastMessage> build() {
    ref.onDispose(() {
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();
    });
    return const [];
  }

  void success(String text) => _show(ToastKind.success, text);

  void error(String text) => _show(ToastKind.error, text);

  void info(String text) => _show(ToastKind.info, text);

  void dismiss(int id) {
    _timers.remove(id)?.cancel();
    state = [
      for (final toast in state)
        if (toast.id != id) toast,
    ];
  }

  void _show(ToastKind kind, String text) {
    final duplicate = state.where((t) => t.kind == kind && t.text == text);
    if (duplicate.isNotEmpty) {
      _restartTimer(duplicate.first);
      return;
    }
    final toast = ToastMessage(id: _nextId++, kind: kind, text: text);
    final next = [...state, toast];
    while (next.length > maxToasts) {
      final oldest = next.removeAt(0);
      _timers.remove(oldest.id)?.cancel();
    }
    state = next;
    _restartTimer(toast);
  }

  void _restartTimer(ToastMessage toast) {
    _timers.remove(toast.id)?.cancel();
    final duration = switch (toast.kind) {
      ToastKind.success => _successDuration,
      ToastKind.info => _infoDuration,
      ToastKind.error => _errorDuration,
    };
    _timers[toast.id] = Timer(duration, () => dismiss(toast.id));
  }
}
