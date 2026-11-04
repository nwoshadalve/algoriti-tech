// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../domain/board_models.dart';

/// Localized queue type label for the counter UI.
String queueDeskQueueName(Locale locale, QueueTypeBoardControl control) {
  if (locale.languageCode == 'bn' && control.bengaliName.trim().isNotEmpty) {
    return control.bengaliName;
  }
  return control.englishName;
}

String queueDeskQueueNameForToken(Locale locale, BoardTokenView token) {
  if (locale.languageCode == 'bn' && token.queueBengaliName.trim().isNotEmpty) {
    return token.queueBengaliName;
  }
  return token.queueEnglishName;
}

String queueDeskPreviewQueueName(Locale locale, IssuePreview preview) {
  if (locale.languageCode == 'bn' &&
      preview.queueBengaliName.trim().isNotEmpty) {
    return preview.queueBengaliName;
  }
  return preview.queueEnglishName;
}

/// Serial for display (Bengali digits when locale is bn).
String queueDeskFormatSerial(int serial, Locale locale) {
  final text = serial.toString();
  if (locale.languageCode != 'bn') return text;
  const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return text.replaceAllMapped(RegExp(r'\d'), (m) => bn[int.parse(m[0]!)]);
}

String queueDeskWaitingMinutes(DateTime issuedAt, DateTime now, Locale locale) {
  final minutes = now.difference(issuedAt).inMinutes.clamp(0, 9999);
  final text = minutes.toString();
  if (locale.languageCode == 'bn') {
    return '${queueDeskFormatSerial(minutes, locale)} মি';
  }
  return '$text min';
}
