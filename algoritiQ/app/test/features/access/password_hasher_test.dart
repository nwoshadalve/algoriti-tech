import 'package:algoritiq_app/features/access/data/argon2id_password_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/memory_secret_store.dart';

void main() {
  Future<Argon2idPasswordHasher> hasher(MemorySecretStore secrets) =>
      Argon2idPasswordHasher.create(secrets, memoryKiB: 64, passes: 1);

  test('should verify the right password and refuse a wrong one', () async {
    final h = await hasher(MemorySecretStore());
    final hash = await h.hash('correct horse battery');

    expect(await h.verify('correct horse battery', hash), isTrue);
    expect(await h.verify('correct horse batterz', hash), isFalse);
  });

  test('should never contain the password', () async {
    final h = await hasher(MemorySecretStore());

    final hash = await h.hash('correct horse battery');

    expect(hash, startsWith(r'argon2id$m=64,t=1,p=1$'));
    expect(hash, isNot(contains('correct')));
  });

  test('should salt every hash differently', () async {
    final h = await hasher(MemorySecretStore());

    expect(await h.hash('same password'), isNot(await h.hash('same password')));
  });

  test('should not verify on another device (different secret)', () async {
    final hash = await (await hasher(MemorySecretStore())).hash('pass word 1');
    final otherDevice = await hasher(MemorySecretStore());

    expect(await otherDevice.verify('pass word 1', hash), isFalse);
  });

  test('should keep the same secret across restarts', () async {
    final secrets = MemorySecretStore();
    final hash = await (await hasher(secrets)).hash('pass word 1');

    expect(await (await hasher(secrets)).verify('pass word 1', hash), isTrue);
  });

  test('should refuse malformed hashes instead of throwing', () async {
    final h = await hasher(MemorySecretStore());

    expect(await h.verify('x', 'not-a-hash'), isFalse);
    expect(await h.verify('x', r'argon2id$m=zz,t=1,p=1$AA==$AA=='), isFalse);
  });
}
