// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
/// Persists the language the user picked.
abstract interface class LocaleStore {
  /// The saved language code (`bn`, `en`), or null if none was saved.
  Future<String?> read();

  Future<void> write(String languageCode);
}
