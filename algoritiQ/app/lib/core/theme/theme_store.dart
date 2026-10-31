// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
/// Persists light / dark / system theme choice.
abstract interface class ThemeStore {
  Future<String?> read();
  Future<void> write(String value);
}
