// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/board_models.dart';
import 'queue_desk_format.dart';

/// The time now; tests replace it to move the clock without waiting.
@visibleForTesting
DateTime Function() deskNow = DateTime.now;

/// How long a patient has waited, as a clock that counts up while they wait.
/// It stops at the first call (or entry, or cancellation). Each waiting row
/// ticks on its own timer, so a row that is rebuilt, filtered away and shown
/// again, or scrolled in, always starts counting from the current time.
class DeskLiveWait extends StatefulWidget {
  const DeskLiveWait({super.key, required this.token, this.style});

  final BoardTokenView token;
  final TextStyle? style;

  @override
  State<DeskLiveWait> createState() => _DeskLiveWaitState();
}

class _DeskLiveWaitState extends State<DeskLiveWait> {
  Timer? _timer;

  static DateTime? _stoppedAt(BoardTokenView token) =>
      token.firstCalledAt ?? token.enteredAt ?? token.cancelledAt;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(DeskLiveWait old) {
    super.didUpdateWidget(old);
    _syncTimer();
  }

  /// Ticks while the patient is waiting; silent once the wait has ended.
  void _syncTimer() {
    final waiting = _stoppedAt(widget.token) == null;
    if (!waiting) {
      _timer?.cancel();
      _timer = null;
    } else {
      _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final end = _stoppedAt(widget.token) ?? deskNow();
    // A long wait (1:05:25) shrinks a little rather than being cut off.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        queueDeskWaitClock(end.difference(widget.token.issuedAt), locale),
        style: widget.style,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}
