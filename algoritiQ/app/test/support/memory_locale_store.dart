// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/l10n/locale_store.dart';

class MemoryLocaleStore implements LocaleStore {
  MemoryLocaleStore([this.code]);

  String? code;

  @override
  Future<String?> read() async => code;

  @override
  Future<void> write(String languageCode) async => code = languageCode;
}
