import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../../core/security/secret_store.dart';
import '../domain/password_hasher.dart';

/// Argon2id password hashing with a per-password salt and a device secret
/// ("pepper") from the Keystore, so a copied database cannot be attacked on
/// its own. Cost parameters travel with each hash so they can be raised later.
///
/// Format: `argon2id$m=<KiB>,t=<passes>,p=<lanes>$<salt>$<hash>` (base64url).
final class Argon2idPasswordHasher implements PasswordHasher {
  Argon2idPasswordHasher._(
    this._pepper, {
    required this.memoryKiB,
    required this.passes,
  });

  /// Loads (or creates once) the device secret, then builds the hasher.
  static Future<Argon2idPasswordHasher> create(
    SecretStore secrets, {
    int memoryKiB = 19456,
    int passes = 2,
  }) async {
    const name = 'password.pepper';
    var stored = await secrets.read(name);
    if (stored == null) {
      final random = Random.secure();
      stored = base64Url.encode(
        Uint8List.fromList(List.generate(32, (_) => random.nextInt(256))),
      );
      await secrets.write(name, stored);
    }
    return Argon2idPasswordHasher._(
      base64Url.decode(stored),
      memoryKiB: memoryKiB,
      passes: passes,
    );
  }

  final List<int> _pepper;

  /// Memory cost (19 MiB is the OWASP minimum for Argon2id with 2 passes).
  final int memoryKiB;
  final int passes;

  static const _lanes = 1;
  static const _hashBytes = 32;

  @override
  Future<String> hash(String password) async {
    final random = Random.secure();
    final salt = List.generate(16, (_) => random.nextInt(256));
    final memory = memoryKiB;
    final iterations = passes;
    final pepper = _pepper;
    final raw = await Isolate.run(
      () => _derive(password, salt, pepper, memory, iterations),
    );
    return 'argon2id\$m=$memory,t=$iterations,p=$_lanes\$'
        '${base64Url.encode(salt)}\$${base64Url.encode(raw)}';
  }

  @override
  Future<bool> verify(String password, String encodedHash) async {
    final parts = encodedHash.split(r'$');
    if (parts.length != 4 || parts[0] != 'argon2id') return false;
    final params = {
      for (final pair in parts[1].split(','))
        if (pair.split('=') case [final key, final value]) key: value,
    };
    final memory = int.tryParse(params['m'] ?? '');
    final iterations = int.tryParse(params['t'] ?? '');
    if (memory == null || iterations == null) return false;
    final salt = base64Url.decode(parts[2]);
    final expected = base64Url.decode(parts[3]);
    final pepper = _pepper;
    final actual = await Isolate.run(
      () => _derive(password, salt, pepper, memory, iterations),
    );
    return _constantTimeEquals(actual, expected);
  }

  static Future<List<int>> _derive(
    String password,
    List<int> salt,
    List<int> pepper,
    int memory,
    int iterations,
  ) async {
    // The pepper is mixed in first, so the stored hash depends on a secret
    // that never leaves the Keystore.
    final peppered = await Hmac.sha256().calculateMac(
      utf8.encode(password),
      secretKey: SecretKey(pepper),
    );
    final key =
        await Argon2id(
          memory: memory,
          parallelism: _lanes,
          iterations: iterations,
          hashLength: _hashBytes,
        ).deriveKeyFromPassword(
          password: base64Url.encode(peppered.bytes),
          nonce: salt,
        );
    return key.extractBytes();
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
