// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

import 'package:algoritiq_app/api/mdns/local_name_responder.dart';
import 'package:algoritiq_app/api/mdns/mdns_message.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mdns_kit.dart';

void main() {
  late FakeMdnsSocket socket;
  late List<String> addresses;
  late List<String> addressesV6;

  setUp(() {
    socket = FakeMdnsSocket();
    addresses = ['192.168.1.110'];
    addressesV6 = ['fe80::1234'];
  });

  LocalNameResponder responder() {
    final it = LocalNameResponder(
      open: () async => socket,
      addresses: () async => addresses,
      addressesV6: () async => addressesV6,
      probeInterval: const Duration(milliseconds: 5),
      recheckEvery: const Duration(milliseconds: 30),
    );
    addTearDown(it.stop);
    return it;
  }

  Future<void> pause([int ms = 80]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  List<MdnsRecord> addressRecords(FakeMdnsSocket s) => [
    for (final message in s.answers)
      ...message.records.where((record) => record.type == MdnsType.a),
  ];

  test('should take the plain name when nobody uses it', () async {
    final it = responder();
    final claimed = it.names.first;

    await it.start();

    expect(await claimed, 'algoritiq.local');
    expect(it.name, 'algoritiq.local');
  });

  test('should ask the network three times before taking the name', () async {
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;

    final probes = socket.messages.where((m) => !m.isResponse);
    expect(probes, hasLength(3));
    expect(
      probes.every((m) => m.questions.single.name == 'algoritiq.local'),
      isTrue,
    );
  });

  test('should announce the address once the name is taken', () async {
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;

    final a = addressRecords(socket).first;
    expect(a.name, 'algoritiq.local');
    expect(a.data, [192, 168, 1, 110]);
  });

  test('should pick the next name when another tablet has the first', () async {
    socket = FakeMdnsSocket(taken: {'algoritiq.local'});
    final it = responder();
    final claimed = it.names.first;

    await it.start();

    expect(await claimed, 'algoritiq-2.local');
  });

  test('should go on to the third name when two are taken', () async {
    socket = FakeMdnsSocket(taken: {'algoritiq.local', 'algoritiq-2.local'});
    final it = responder();
    final claimed = it.names.first;

    await it.start();

    expect(await claimed, 'algoritiq-3.local');
  });

  test('should give up and have no name when every name is taken', () async {
    socket = FakeMdnsSocket(
      taken: {
        'algoritiq.local',
        for (var n = 2; n <= 9; n++) 'algoritiq-$n.local',
      },
    );
    final it = responder();

    await it.start();
    await pause(400);

    expect(it.name, isNull);
    expect(addressRecords(socket), isEmpty);
  });

  test('should answer a question about its name with the address', () async {
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;
    final before = socket.sent.length;

    socket.hear(query('algoritiq.local', MdnsType.a));
    await pause(10);

    final reply = socket.messages.skip(before).single;
    expect(reply.records.first.type, MdnsType.a);
    expect(reply.records.first.data, [192, 168, 1, 110]);
  });

  test('should answer an IPv6 question with its IPv6 address', () async {
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;
    final before = socket.sent.length;

    socket.hear(query('algoritiq.local', MdnsType.aaaa));
    await pause(10);

    final reply = socket.messages.skip(before).single;
    expect(reply.records.first.type, MdnsType.aaaa);
    expect(reply.records.first.data.first, 0xFE);
  });

  test('should say nothing to an IPv6 question without an address', () async {
    addressesV6 = [];
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;
    final before = socket.sent.length;

    socket.hear(query('algoritiq.local', MdnsType.aaaa));
    await pause(10);

    expect(socket.sent.length, before);
  });

  test('should announce both addresses', () async {
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;

    final types = socket.answers.first.records.map((r) => r.type);
    expect(types, containsAll([MdnsType.a, MdnsType.aaaa]));
  });

  test('should announce again when only the IPv6 address changes', () async {
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;
    final before = socket.answers.length;

    addressesV6 = ['fe80::abcd'];
    await pause(200);

    expect(socket.answers.length, greaterThan(before));
  });

  test('should stay quiet about names that are not its own', () async {
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;
    final before = socket.sent.length;

    socket.hear(query('printer.local', MdnsType.a));
    await pause(10);

    expect(socket.sent.length, before);
  });

  test('should ignore packets it cannot read', () async {
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;

    socket.hear(Uint8List.fromList([1, 2, 3]));
    await pause(10);

    expect(it.name, 'algoritiq.local');
  });

  test('should wait for a network, then take the name', () async {
    addresses = [];
    final it = responder();
    await it.start();
    await pause(100);
    expect(it.name, isNull);

    addresses = ['192.168.1.110'];
    await pause(300);

    expect(it.name, 'algoritiq.local');
  });

  test('should announce the new address when the Wi-Fi changes', () async {
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;

    addresses = ['192.168.1.200'];
    await pause(200);

    expect(addressRecords(socket).last.data, [192, 168, 1, 200]);
  });

  test('should reopen the socket when the network changes', () async {
    var opens = 0;
    FakeMdnsSocket live = socket;
    final it = LocalNameResponder(
      open: () async {
        opens++;
        live = FakeMdnsSocket();
        return live;
      },
      addresses: () async => addresses,
      addressesV6: () async => addressesV6,
      probeInterval: const Duration(milliseconds: 5),
      recheckEvery: const Duration(hours: 1),
    );
    addTearDown(it.stop);
    final claimed = it.names.first;
    await it.start();
    await claimed;
    expect(opens, 1);

    addresses = ['192.168.1.200'];
    await it.refreshAfterNetworkChange();

    expect(opens, 2);
    expect(addressRecords(live).last.data, [192, 168, 1, 200]);
  });

  test('should tell clients to forget the address when Wi-Fi drops', () async {
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;

    addresses = [];
    await pause(200);

    expect(addressRecords(socket).last.ttl, 0);
    expect(it.name, 'algoritiq.local');
  });

  test('should advertise the first address when there are several', () async {
    addresses = ['192.168.1.110', '10.20.30.40'];
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;

    expect(addressRecords(socket).first.data, [192, 168, 1, 110]);
  });

  test('should ask everyone to forget the name when it stops', () async {
    final it = responder();
    final claimed = it.names.first;
    await it.start();
    await claimed;

    await it.stop();

    expect(addressRecords(socket).last.ttl, 0);
    expect(socket.closed, isTrue);
  });

  test('should close the socket when stopped before it opened', () async {
    final it = LocalNameResponder(
      open: () async {
        await pause(20);
        return socket;
      },
      addresses: () async => addresses,
    );
    final starting = it.start();

    await it.stop();
    await starting;

    expect(socket.closed, isTrue);
  });
}
