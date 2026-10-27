import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secret_store.dart';

/// [SecretStore] on `flutter_secure_storage` (Android Keystore).
final class SecureStorageSecretStore implements SecretStore {
  const SecureStorageSecretStore();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String name) => _storage.read(key: name);

  @override
  Future<void> write(String name, String value) =>
      _storage.write(key: name, value: value);
}

final secretStoreProvider = Provider<SecretStore>(
  (ref) => const SecureStorageSecretStore(),
);
