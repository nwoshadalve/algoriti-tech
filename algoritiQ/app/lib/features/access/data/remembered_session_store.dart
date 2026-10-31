// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Bearer token for a remembered sign-in on this tablet (30-day session).
final class RememberedSessionStore {
  const RememberedSessionStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth.remembered.token';

  final FlutterSecureStorage _storage;

  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } on MissingPluginException {
      return null;
    }
  }

  Future<void> write(String token) async {
    try {
      await _storage.write(key: _key, value: token);
    } on MissingPluginException {
      // Tests and some platforms have no secure storage plugin.
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } on MissingPluginException {
      // Tests and some platforms have no secure storage plugin.
    }
  }
}
