import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'mdns_message.dart';
import 'mdns_socket.dart';

/// Gives the tablet a name other devices on the clinic Wi-Fi can use
/// (`algoritiq.local`), with no router setup and no internet.
///
/// Before taking a name it asks the network whether anyone already uses it; if
/// so it tries `algoritiq-2.local` and so on (two tablets on one network).
/// Then it answers questions about the name with the tablet's current address,
/// and announces a new address when the Wi-Fi changes.
final class LocalNameResponder {
  LocalNameResponder({
    required this._open,
    required this._addresses,
    this._addressesV6 = _none,
    this.baseName = 'algoritiq',
    this.probeInterval = const Duration(milliseconds: 250),
    this.recheckEvery = const Duration(seconds: 30),
  });

  final Future<MdnsSocket> Function() _open;
  final Future<List<String>> Function() _addresses;
  final Future<List<String>> Function() _addressesV6;
  final String baseName;
  final Duration probeInterval;
  final Duration recheckEvery;

  static Future<List<String>> _none() async => const [];

  static const _suffix = 'local';
  static const _probes = 3;
  static const _maxNames = 9;

  final _names = StreamController<String?>.broadcast();
  MdnsSocket? _socket;
  StreamSubscription<MdnsDatagram>? _incoming;
  Timer? _recheck;
  Timer? _repeat;
  bool _stopped = false;
  bool _claiming = false;

  String? _host;
  List<int>? _ip;
  List<int>? _ip6;

  String? _probing;
  bool _conflict = false;

  /// The name this tablet answers to, or null while it has none (no network
  /// yet, or every name was taken). Emits when it changes.
  String? get name => _host;

  Stream<String?> get names => _names.stream;

  /// Opens the socket and starts claiming a name in the background.
  Future<void> start() async {
    final socket = await _open();
    if (_stopped) {
      socket.close();
      return;
    }
    _socket = socket;
    _incoming = socket.datagrams.listen(_onPacket, onError: (Object _) {});
    unawaited(_claim());
    _recheck = Timer.periodic(recheckEvery, (_) => unawaited(_look()));
  }

  Future<void> stop() async {
    _stopped = true;
    _recheck?.cancel();
    _repeat?.cancel();
    final host = _host;
    final ip = _ip;
    if (host != null && ip != null) {
      // Everyone forgets the name now instead of after its time runs out.
      _send(MdnsPackets.address(host, ip, ipv6: _ip6, ttl: 0));
    }
    await _incoming?.cancel();
    _socket?.close();
    _socket = null;
    _setName(null);
    await _names.close();
  }

  Future<List<int>?> _firstAddress() => _first(_addresses, 4);

  Future<List<int>?> _firstAddressV6() => _first(_addressesV6, 16);

  Future<List<int>?> _first(
    Future<List<String>> Function() read,
    int bytes,
  ) async {
    for (final address in await read()) {
      final raw = InternetAddress.tryParse(address)?.rawAddress;
      if (raw != null && raw.length == bytes) return raw;
    }
    return null;
  }

  Future<void> _claim() async {
    if (_claiming || _stopped) return;
    _claiming = true;
    try {
      final ip = await _firstAddress();
      if (ip == null) return;
      for (var n = 1; n <= _maxNames && !_stopped; n++) {
        final host = '${n == 1 ? baseName : '$baseName-$n'}.$_suffix';
        if (await _probe(host)) {
          _ip = ip;
          _ip6 = await _firstAddressV6();
          _setName(host);
          _announce();
          return;
        }
      }
    } finally {
      _claiming = false;
    }
  }

  /// True when nobody answered for [host] while we asked.
  Future<bool> _probe(String host) async {
    _probing = host;
    _conflict = false;
    try {
      for (var i = 0; i < _probes && !_conflict && !_stopped; i++) {
        _send(MdnsPackets.probe(host));
        await Future<void>.delayed(probeInterval);
      }
      return !_conflict && !_stopped;
    } finally {
      _probing = null;
    }
  }

  /// Sent twice, a second apart, so a device that missed the first one hears it.
  void _announce() {
    final host = _host;
    final ip = _ip;
    if (host == null || ip == null) return;
    final ip6 = _ip6;
    _send(MdnsPackets.address(host, ip, ipv6: ip6));
    _repeat?.cancel();
    _repeat = Timer(const Duration(seconds: 1), () {
      if (!_stopped) _send(MdnsPackets.address(host, ip, ipv6: ip6));
    });
  }

  Future<void> _look() async {
    if (_stopped) return;
    final ip = await _firstAddress();
    if (_stopped || ip == null) return;
    if (_host == null) {
      await _claim();
      return;
    }
    final ip6 = await _firstAddressV6();
    if (_stopped) return;
    if (!_same(ip, _ip) || !_same(ip6, _ip6)) {
      _ip = ip;
      _ip6 = ip6;
      _announce();
    }
  }

  void _onPacket(MdnsDatagram datagram) {
    final MdnsMessage message;
    try {
      message = MdnsMessage.parse(datagram.data);
    } on FormatException {
      return;
    }
    if (message.isResponse) {
      final probing = _probing;
      if (probing != null &&
          message.records.any((record) => record.name == probing)) {
        _conflict = true;
      }
      return;
    }
    final host = _host;
    final ip = _ip;
    if (host == null || ip == null) return;
    for (final question in message.questions) {
      if (question.name != host) continue;
      switch (question.type) {
        case MdnsType.a || MdnsType.any:
          _send(MdnsPackets.address(host, ip, ipv6: _ip6));
        case MdnsType.aaaa:
          // No IPv6 address: say nothing (see [MdnsPackets.address]).
          final ip6 = _ip6;
          if (ip6 != null) {
            _send(MdnsPackets.address(host, ip, ipv6: ip6, forAaaa: true));
          }
      }
    }
  }

  void _send(Uint8List data) {
    try {
      _socket?.send(data);
    } on SocketException {
      // The network went away; the next look picks it up again.
    }
  }

  void _setName(String? host) {
    if (_host == host) return;
    _host = host;
    if (host == null) {
      _ip = null;
      _ip6 = null;
    }
    if (!_names.isClosed) _names.add(host);
  }

  bool _same(List<int>? a, List<int>? b) => a == null || b == null
      ? a == b
      : a.length == b.length &&
            Iterable<int>.generate(a.length).every((i) => a[i] == b[i]);
}
