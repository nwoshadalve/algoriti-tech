import 'dart:async';
import 'dart:typed_data';

import 'package:algoritiq_app/api/mdns/mdns_message.dart';
import 'package:algoritiq_app/api/mdns/mdns_socket.dart';

/// A question from another device, as it arrives on the network.
Uint8List query(String name, int type) {
  final out = BytesBuilder()..add([0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0]);
  for (final label in name.split('.')) {
    out
      ..addByte(label.length)
      ..add(label.codeUnits);
  }
  out
    ..addByte(0)
    ..add([type >> 8, type & 0xFF, 0, 1]);
  return out.toBytes();
}

/// The network as seen from the tablet: records what it sends, delivers what
/// other devices say, and can have devices that already use some names.
class FakeMdnsSocket implements MdnsSocket {
  FakeMdnsSocket({this.taken = const {}});

  /// Names other devices already use; they answer a probe for one of them.
  final Set<String> taken;

  final sent = <Uint8List>[];
  bool closed = false;

  final _incoming = StreamController<MdnsDatagram>();

  @override
  Stream<MdnsDatagram> get datagrams => _incoming.stream;

  @override
  void send(List<int> data) {
    final bytes = Uint8List.fromList(data);
    sent.add(bytes);
    final message = MdnsMessage.parse(bytes);
    if (message.isResponse) return;
    final name = message.questions.single.name;
    if (taken.contains(name)) {
      hear(MdnsPackets.address(name, [192, 168, 1, 77]), from: '192.168.1.77');
    }
  }

  /// A packet from another device.
  void hear(Uint8List data, {String from = '192.168.1.50'}) =>
      _incoming.add(MdnsDatagram(data, from));

  /// What the tablet has sent, read back.
  List<MdnsMessage> get messages => sent.map(MdnsMessage.parse).toList();

  /// Answers (not probes) the tablet has sent.
  List<MdnsMessage> get answers =>
      messages.where((message) => message.isResponse).toList();

  @override
  void close() {
    closed = true;
    _incoming.close();
  }
}
