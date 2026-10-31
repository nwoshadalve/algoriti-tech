// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// What this tablet keeps so the person can sign in with a PIN. The PIN itself
/// is never stored.
final class PinClientRegistration {
  const PinClientRegistration({
    required this.deviceToken,
    required this.deviceId,
    required this.username,
    required this.displayName,
  });

  final String deviceToken;
  final String deviceId;
  final String username;
  final String displayName;

  Map<String, dynamic> toJson() => {
    'deviceToken': deviceToken,
    'deviceId': deviceId,
    'username': username,
    'displayName': displayName,
  };

  static PinClientRegistration? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final token = json['deviceToken'];
    final id = json['deviceId'];
    final username = json['username'];
    final displayName = json['displayName'];
    if (token is! String ||
        id is! String ||
        username is! String ||
        displayName is! String) {
      return null;
    }
    return PinClientRegistration(
      deviceToken: token,
      deviceId: id,
      username: username,
      displayName: displayName,
    );
  }
}

/// Persists the PIN device secret for this tablet app install.
final class PinClientStore {
  const PinClientStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'pin.client.registration';

  final FlutterSecureStorage _storage;

  Future<PinClientRegistration?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return null;
      try {
        return PinClientRegistration.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } on FormatException {
        return null;
      }
    } on MissingPluginException {
      return null;
    }
  }

  Future<void> write(PinClientRegistration registration) async {
    await _storage.write(key: _key, value: jsonEncode(registration.toJson()));
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
