import 'dart:typed_data';

import 'package:algoritiq_app/api/mdns/mdns_message.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mdns_kit.dart';

void main() {
  test('should read the question in a probe', () {
    final message = MdnsMessage.parse(MdnsPackets.probe('algoritiq.local'));

    expect(message.isResponse, isFalse);
    expect(message.questions.single.name, 'algoritiq.local');
    expect(message.questions.single.type, MdnsType.any);
  });

  test('should say where the name is, with the address and a time limit', () {
    final message = MdnsMessage.parse(
      MdnsPackets.address('algoritiq.local', [192, 168, 1, 110]),
    );

    expect(message.isResponse, isTrue);
    final a = message.records.firstWhere((r) => r.type == MdnsType.a);
    expect(a.name, 'algoritiq.local');
    expect(a.data, [192, 168, 1, 110]);
    expect(a.ttl, 120);
  });

  test('should carry the IPv6 address along with the IPv4 one', () {
    final message = MdnsMessage.parse(
      MdnsPackets.address(
        'algoritiq.local',
        [10, 0, 0, 2],
        ipv6: [0xFE, 0x80, ...List.filled(13, 0), 1],
      ),
    );

    expect(message.records.map((r) => r.type), [MdnsType.a, MdnsType.aaaa]);
  });

  test('should answer an IPv6 question with the IPv6 address first', () {
    final message = MdnsMessage.parse(
      MdnsPackets.address(
        'algoritiq.local',
        [10, 0, 0, 2],
        ipv6: [0xFE, 0x80, ...List.filled(13, 0), 1],
        forAaaa: true,
      ),
    );

    expect(message.records.first.type, MdnsType.aaaa);
    expect(message.records.first.data, hasLength(16));
  });

  test('should never answer "no IPv6" (Windows then fails the lookup)', () {
    expect(
      () =>
          MdnsPackets.address('algoritiq.local', [10, 0, 0, 2], forAaaa: true),
      throwsArgumentError,
    );
    final message = MdnsMessage.parse(
      MdnsPackets.address('algoritiq.local', [10, 0, 0, 2]),
    );
    expect(message.records.map((r) => r.type), [MdnsType.a]);
  });

  test('should ask everyone to forget the name when told to', () {
    final message = MdnsMessage.parse(
      MdnsPackets.address('algoritiq.local', [10, 0, 0, 2], ttl: 0),
    );

    expect(message.records.every((record) => record.ttl == 0), isTrue);
  });

  test('should ignore letter case in names', () {
    final message = MdnsMessage.parse(query('AlgoritiQ.LOCAL', MdnsType.a));

    expect(message.questions.single.name, 'algoritiq.local');
  });

  test('should follow a name that points back into the packet', () {
    // A question for "algoritiq.local", then an answer whose name is a
    // pointer (0xC00C) to the question's name.
    final bytes = BytesBuilder()
      ..add([0, 0, 0x84, 0, 0, 1, 0, 1, 0, 0, 0, 0])
      ..add([9, ...'algoritiq'.codeUnits, 5, ...'local'.codeUnits, 0])
      ..add([0, 1, 0, 1])
      ..add([0xC0, 0x0C, 0, 1, 0, 1, 0, 0, 0, 120, 0, 4, 10, 0, 0, 9]);

    final message = MdnsMessage.parse(bytes.toBytes());

    expect(message.records.single.name, 'algoritiq.local');
    expect(message.records.single.data, [10, 0, 0, 9]);
  });

  test('should reject a packet whose name points at itself', () {
    final bytes = Uint8List.fromList([
      0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, //
      0xC0, 0x0C, 0, 1, 0, 1,
    ]);

    expect(() => MdnsMessage.parse(bytes), throwsFormatException);
  });

  test('should reject a packet cut short', () {
    final full = query('algoritiq.local', MdnsType.a);

    expect(
      () => MdnsMessage.parse(Uint8List.sublistView(full, 0, full.length - 3)),
      throwsFormatException,
    );
    expect(() => MdnsMessage.parse(Uint8List(5)), throwsFormatException);
  });

  test('should refuse to write a name with an empty or too long part', () {
    expect(() => MdnsPackets.probe('a..local'), throwsArgumentError);
    expect(() => MdnsPackets.probe('${'a' * 64}.local'), throwsArgumentError);
  });
}
