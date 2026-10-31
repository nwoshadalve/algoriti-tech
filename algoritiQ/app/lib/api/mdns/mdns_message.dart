// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:typed_data';

/// Record types used on the local network name service (mDNS).
abstract final class MdnsType {
  static const a = 1;
  static const aaaa = 28;
  static const any = 255;
}

final class MdnsQuestion {
  const MdnsQuestion(this.name, this.type);

  /// Lower case, without a trailing dot (`algoritiq.local`).
  final String name;
  final int type;
}

final class MdnsRecord {
  const MdnsRecord(this.name, this.type, this.ttl, this.data);

  final String name;
  final int type;

  /// Seconds the answer may be remembered; 0 means "forget it".
  final int ttl;
  final Uint8List data;
}

/// What the tablet needs to read from a packet on the local network: whether
/// it is a question or an answer, who it asks about, and which names it
/// answers for. Packets that do not parse are not ours to answer.
final class MdnsMessage {
  const MdnsMessage({
    required this.isResponse,
    required this.questions,
    required this.records,
  });

  final bool isResponse;
  final List<MdnsQuestion> questions;
  final List<MdnsRecord> records;

  /// Throws [FormatException] for a short, looping or otherwise broken packet.
  factory MdnsMessage.parse(Uint8List bytes) {
    if (bytes.length < _headerSize) throw const FormatException('short');
    final view = ByteData.sublistView(bytes);
    final isResponse = view.getUint16(2) & 0x8000 != 0;
    final questionCount = view.getUint16(4);
    final recordCount =
        view.getUint16(6) + view.getUint16(8) + view.getUint16(10);

    var offset = _headerSize;
    final questions = <MdnsQuestion>[];
    for (var i = 0; i < questionCount; i++) {
      final (name, afterName) = _readName(bytes, offset);
      if (afterName + 4 > bytes.length) throw const FormatException('short');
      questions.add(MdnsQuestion(name, view.getUint16(afterName)));
      offset = afterName + 4;
    }
    final records = <MdnsRecord>[];
    for (var i = 0; i < recordCount; i++) {
      final (name, afterName) = _readName(bytes, offset);
      if (afterName + 10 > bytes.length) throw const FormatException('short');
      final type = view.getUint16(afterName);
      final length = view.getUint16(afterName + 8);
      final start = afterName + 10;
      if (start + length > bytes.length) throw const FormatException('short');
      records.add(
        MdnsRecord(
          name,
          type,
          view.getUint32(afterName + 4),
          Uint8List.sublistView(bytes, start, start + length),
        ),
      );
      offset = start + length;
    }
    return MdnsMessage(
      isResponse: isResponse,
      questions: questions,
      records: records,
    );
  }

  static const _headerSize = 12;
  static const _maxJumps = 16;

  static (String, int) _readName(Uint8List bytes, int start) {
    final labels = <String>[];
    var position = start;
    int? end;
    var jumps = 0;
    while (true) {
      if (position >= bytes.length) throw const FormatException('short');
      final length = bytes[position];
      if (length == 0) {
        position++;
        break;
      }
      final flag = length & 0xC0;
      if (flag == 0xC0) {
        if (position + 1 >= bytes.length) throw const FormatException('short');
        end ??= position + 2;
        position = ((length & 0x3F) << 8) | bytes[position + 1];
        if (++jumps > _maxJumps) throw const FormatException('loop');
        continue;
      }
      if (flag != 0 || position + 1 + length > bytes.length) {
        throw const FormatException('bad label');
      }
      labels.add(
        latin1.decode(bytes.sublist(position + 1, position + 1 + length)),
      );
      position += 1 + length;
    }
    return (labels.join('.').toLowerCase(), end ?? position);
  }
}

/// The packets the tablet sends to claim and announce its name.
abstract final class MdnsPackets {
  static const _ttl = 120;
  static const _classIn = 1;
  static const _cacheFlush = 0x8000;
  static const _unicastResponse = 0x8000;

  /// "Is anyone using [host]?" Sent a few times before the name is taken.
  static Uint8List probe(String host) {
    final out = BytesBuilder()
      ..add(_header(questions: 1, answers: 0, additional: 0, response: false))
      ..add(_name(host))
      ..add(_u16(MdnsType.any))
      ..add(_u16(_classIn | _unicastResponse));
    return out.toBytes();
  }

  /// "[host] is at [ipv4] / [ipv6]". The record that was asked for ([forAaaa]
  /// says which) is the answer, the other one rides along.
  ///
  /// A tablet without IPv6 must not answer "no IPv6 address" (a negative
  /// answer): Windows then fails the whole lookup. It sends nothing for an
  /// IPv6 question instead, so [forAaaa] needs an [ipv6].
  /// [ttl] 0 tells everyone to forget the name (sent when the server stops).
  static Uint8List address(
    String host,
    List<int> ipv4, {
    List<int>? ipv6,
    bool forAaaa = false,
    int ttl = _ttl,
  }) {
    final a = _record(host, MdnsType.a, ipv4, ttl);
    final aaaa = ipv6 == null ? null : _record(host, MdnsType.aaaa, ipv6, ttl);
    if (forAaaa && aaaa == null) {
      throw ArgumentError.value(forAaaa, 'forAaaa', 'no IPv6 address');
    }
    final answer = forAaaa ? aaaa! : a;
    final extra = forAaaa ? a : aaaa;
    final out = BytesBuilder()
      ..add(
        _header(
          questions: 0,
          answers: 1,
          additional: extra == null ? 0 : 1,
          response: true,
        ),
      )
      ..add(answer);
    if (extra != null) out.add(extra);
    return out.toBytes();
  }

  static Uint8List _header({
    required int questions,
    required int answers,
    required int additional,
    required bool response,
  }) {
    final out = BytesBuilder()
      ..add(_u16(0))
      ..add(_u16(response ? 0x8400 : 0))
      ..add(_u16(questions))
      ..add(_u16(answers))
      ..add(_u16(0))
      ..add(_u16(additional));
    return out.toBytes();
  }

  static Uint8List _record(String host, int type, List<int> data, int ttl) {
    final out = BytesBuilder()
      ..add(_name(host))
      ..add(_u16(type))
      ..add(_u16(_classIn | _cacheFlush))
      ..add(_u32(ttl))
      ..add(_u16(data.length))
      ..add(data);
    return out.toBytes();
  }

  static Uint8List _name(String host) {
    final out = BytesBuilder();
    for (final label in host.split('.')) {
      final bytes = latin1.encode(label);
      if (bytes.isEmpty || bytes.length > 63) {
        throw ArgumentError.value(host, 'host', 'bad label');
      }
      out
        ..addByte(bytes.length)
        ..add(bytes);
    }
    out.addByte(0);
    return out.toBytes();
  }

  static List<int> _u16(int value) => [(value >> 8) & 0xFF, value & 0xFF];

  static List<int> _u32(int value) => [
    (value >> 24) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 8) & 0xFF,
    value & 0xFF,
  ];
}
