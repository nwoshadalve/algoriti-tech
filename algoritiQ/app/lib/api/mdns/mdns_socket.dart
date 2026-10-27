import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

/// One packet received from the local network.
final class MdnsDatagram {
  const MdnsDatagram(this.data, this.sender);

  final Uint8List data;

  /// IPv4 address the packet came from.
  final String sender;
}

/// The multicast socket the name service talks through. A plain interface so
/// tests can play the other devices on the network.
abstract interface class MdnsSocket {
  Stream<MdnsDatagram> get datagrams;

  /// Sends to everyone on the local network.
  void send(List<int> data);

  void close();
}

/// UDP port 5353 on the multicast group every device on the network listens to.
final class UdpMdnsSocket implements MdnsSocket {
  UdpMdnsSocket._(this._socket);

  final RawDatagramSocket _socket;

  static final _group = InternetAddress('224.0.0.251');
  static const _port = 5353;

  static Future<UdpMdnsSocket> open() async {
    RawDatagramSocket socket;
    try {
      socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        _port,
        reuseAddress: true,
        reusePort: true,
      );
    } on SocketException {
      // Not every system lets several programs share the port.
      socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        _port,
        reuseAddress: true,
      );
    }
    socket
      ..joinMulticast(_group)
      ..multicastLoopback = false;
    return UdpMdnsSocket._(socket);
  }

  @override
  Stream<MdnsDatagram> get datagrams => _socket
      .where((event) => event == RawSocketEvent.read)
      .map((_) => _socket.receive())
      .where((datagram) => datagram != null)
      .map(
        (datagram) => MdnsDatagram(datagram!.data, datagram.address.address),
      );

  @override
  void send(List<int> data) => _socket.send(data, _group, _port);

  @override
  void close() => _socket.close();
}
