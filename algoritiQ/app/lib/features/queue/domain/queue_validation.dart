// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

import 'queue_models.dart';

enum QueueTypeProblem {
  englishNameMissing,
  bengaliNameMissing,
  duplicateName,
  startInvalid,
  endInvalid,
  rangeInverted,
  rangeOverlap,
  openSessionBlocksChange,
}

/// Validates queue type fields from [queue-configuration.md] §3.
Map<QueueTypeProblem, void> validateQueueType({
  required String englishName,
  required String bengaliName,
  required int startNumber,
  required int endNumber,
  required List<QueueTypeConfig> siblings,
  required String? editingId,
  required bool hasOpenSession,
  bool sessionBlocksChange = true,
}) {
  final problems = <QueueTypeProblem, void>{};
  if (englishName.trim().isEmpty) {
    problems[QueueTypeProblem.englishNameMissing] = null;
  }
  if (bengaliName.trim().isEmpty) {
    problems[QueueTypeProblem.bengaliNameMissing] = null;
  }
  if (startNumber <= 0) problems[QueueTypeProblem.startInvalid] = null;
  if (endNumber <= 0) problems[QueueTypeProblem.endInvalid] = null;
  if (startNumber > endNumber) problems[QueueTypeProblem.rangeInverted] = null;

  final en = englishName.trim().toLowerCase();
  final bn = bengaliName.trim();
  for (final other in siblings) {
    if (other.id == editingId) continue;
    if (other.englishName.trim().toLowerCase() == en ||
        other.bengaliName.trim() == bn) {
      problems[QueueTypeProblem.duplicateName] = null;
      break;
    }
  }

  if (startNumber <= endNumber && startNumber > 0) {
    for (final other in siblings) {
      if (other.id == editingId || !other.enabled) continue;
      if (!other.enabled) continue;
      final overlap =
          startNumber <= other.endNumber && endNumber >= other.startNumber;
      if (overlap) {
        problems[QueueTypeProblem.rangeOverlap] = null;
        break;
      }
    }
  }

  if (hasOpenSession && sessionBlocksChange) {
    problems[QueueTypeProblem.openSessionBlocksChange] = null;
  }
  return problems;
}

bool isSmallRangeWarning(int startNumber, int endNumber, {int threshold = 50}) {
  return endNumber - startNumber + 1 < threshold;
}
