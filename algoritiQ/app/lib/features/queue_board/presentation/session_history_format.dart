// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/board_models.dart';
import '../domain/session_history_models.dart';

/// Day and month with the weekday, in the viewer's language and time zone.
String historyDay(BuildContext context, DateTime at) =>
    DateFormat.yMMMEd(Localizations.localeOf(context).toString())
        .format(at.toLocal());

/// Clock time of day, in the viewer's time zone.
String historyClock(BuildContext context, DateTime at) =>
    DateFormat.jm(Localizations.localeOf(context).toString())
        .format(at.toLocal());

/// Day and time, for a moment that may be on another day than the session.
String historyDayClock(BuildContext context, DateTime at) =>
    '${historyDay(context, at)}, ${historyClock(context, at)}';

/// "2 h 5 min" or "45 min".
String historyDuration(AppLocalizations l10n, Duration length) {
  final minutes = length.inMinutes < 0 ? 0 : length.inMinutes;
  if (minutes < 60) return l10n.historyDurationM(minutes);
  return l10n.historyDurationHM(minutes ~/ 60, minutes % 60);
}

/// How long the session ran (to now while it is open).
Duration historyRunTime(SessionSummary session, DateTime now) =>
    (session.closedAt ?? now).difference(session.openedAt);

/// Tokens that were never seen: still waiting or called but never resolved.
int historyNotSeen(SessionSummary session) =>
    session.count(TokenStatus.waiting) + session.count(TokenStatus.called);

String historyStatusLabel(AppLocalizations l10n, SessionSummary session) {
  if (session.isOpen) return l10n.historyStatusOpen;
  final reason = session.closeReason;
  if (reason != null && reason.trim().isNotEmpty) {
    return l10n.historyStatusForced;
  }
  return l10n.historyStatusEnded;
}
