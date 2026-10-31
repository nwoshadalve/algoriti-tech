// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/api/api_host.dart';
import 'package:algoritiq_app/api/server_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/licensing_kit.dart';

void main() {
  late FakeApiHost host;
  late ProviderContainer container;

  setUp(() {
    host = FakeApiHost();
    container = ProviderContainer(
      overrides: [apiHostProvider.overrideWithValue(host)],
    );
    addTearDown(container.dispose);
    container.listen(serverControllerProvider, (_, _) {});
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  ApiEndpoint endpoint() =>
      (container.read(serverControllerProvider) as ServerRunning).endpoint;

  test('should have no local name until the tablet claims one', () async {
    await settle();

    expect(endpoint().localName, isNull);
    expect(endpoint().nameUrl, isNull);
  });

  test('should show the local name once it is claimed', () async {
    await settle();

    host.claimName('algoritiq.local');
    await settle();

    expect(endpoint().nameUrl, 'https://algoritiq.local:8443');
    expect(endpoint().url, 'https://192.168.0.20:8443');
  });

  test('should drop the local name when it is lost', () async {
    await settle();
    host.claimName('algoritiq.local');
    await settle();

    host.claimName(null);
    await settle();

    expect(endpoint().nameUrl, isNull);
  });

  test('should keep the name when the address is read again', () async {
    await settle();
    host.claimName('algoritiq.local');
    await settle();

    host.addresses = ['192.168.0.99'];
    await container.read(serverControllerProvider.notifier).refreshAddresses();

    expect(endpoint().nameUrl, 'https://algoritiq.local:8443');
    expect(endpoint().url, 'https://192.168.0.99:8443');
  });
}
