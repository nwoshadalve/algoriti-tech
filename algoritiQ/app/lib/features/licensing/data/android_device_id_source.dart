import 'package:flutter/services.dart';

import '../domain/license_ports.dart';

/// Reads `ANDROID_ID` through `DeviceIdChannel.kt`.
final class AndroidDeviceIdSource implements DeviceIdSource {
  const AndroidDeviceIdSource();

  static const _channel = MethodChannel('tech.algoriti.algoritiq/device');

  @override
  Future<String> androidId() async {
    final id = await _channel.invokeMethod<String>('androidId');
    if (id == null || id.isEmpty) {
      throw PlatformException(code: 'UNAVAILABLE');
    }
    return id;
  }
}
