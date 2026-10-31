// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/platform/backup_gateway.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_secret_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('tech.algoriti.algoritiq/backup');
  final calls = <MethodCall>[];
  Object? restoreReply;

  setUp(() {
    calls.clear();
    restoreReply = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'create') {
            return {
              'id': 'b1',
              'createdAt': 1,
              'sizeBytes': 2,
              'kind': 'manual',
            };
          }
          return restoreReply;
        });
  });

  test('should save the device secrets with a backup', () async {
    final secrets = MemorySecretStore();
    await secrets.write('password.pepper', 'pepper');
    await secrets.write('tls.certificate', 'cert');
    await secrets.write('unrelated', 'x');

    await ChannelBackupGateway(secrets).create(BackupKind.manual);

    expect(calls.single.arguments['secrets'], {
      'password.pepper': 'pepper',
      'tls.certificate': 'cert',
    });
  });

  test('should put the saved secrets back on restore', () async {
    restoreReply = {'password.pepper': 'old-pepper'};
    final secrets = MemorySecretStore();
    await secrets.write('password.pepper', 'new');

    await ChannelBackupGateway(secrets).restore('b1');

    expect(await secrets.read('password.pepper'), 'old-pepper');
  });

  test('should leave secrets alone for an older backup without any', () async {
    final secrets = MemorySecretStore();
    await secrets.write('password.pepper', 'kept');

    await ChannelBackupGateway(secrets).restore('b1');

    expect(await secrets.read('password.pepper'), 'kept');
  });
}
