// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
/// Keeps small secrets (keys, certificates) away from the database and logs.
/// On Android it is backed by the hardware Keystore.
abstract interface class SecretStore {
  Future<String?> read(String name);

  Future<void> write(String name, String value);
}
