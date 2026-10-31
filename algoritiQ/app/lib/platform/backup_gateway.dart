// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/security/secret_store.dart';
import '../core/security/secure_storage_secret_store.dart';

enum BackupKind { manual, automatic }

enum BackupSchedule { off, daily, weekly }

/// One saved clinic backup on the tablet.
final class BackupEntry {
  const BackupEntry({
    required this.id,
    required this.createdAt,
    required this.sizeBytes,
    required this.kind,
  });

  final String id;
  final DateTime createdAt;
  final int sizeBytes;
  final BackupKind kind;

  static BackupEntry fromJson(Map<String, Object?> json) {
    final kindRaw = json['kind'] as String? ?? 'manual';
    return BackupEntry(
      id: json['id']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt'] as num).toInt(),
        isUtc: true,
      ),
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      kind: kindRaw == 'automatic' ? BackupKind.automatic : BackupKind.manual,
    );
  }
}

final class BackupSettings {
  const BackupSettings({required this.schedule});

  final BackupSchedule schedule;

  static const defaults = BackupSettings(schedule: BackupSchedule.off);

  BackupSettings copyWith({BackupSchedule? schedule}) =>
      BackupSettings(schedule: schedule ?? this.schedule);
}

abstract interface class BackupGateway {
  Future<BackupEntry> create(BackupKind kind);

  Future<List<BackupEntry>> list();

  Future<void> delete(String id);

  Future<void> restore(String id);

  /// Absolute path to the zip on the tablet (Android only).
  Future<String> archivePath(String id);

  /// Register a zip copied from another device (path is readable by native code).
  Future<BackupEntry> importArchiveFile(String absolutePath);

  /// Restarts the app process after a restore (database and prefs were replaced).
  Future<void> restartApp();
}

final class ChannelBackupGateway implements BackupGateway {
  const ChannelBackupGateway([
    this._secrets = const SecureStorageSecretStore(),
  ]);

  final SecretStore _secrets;

  /// Kept in the backup because the Keystore that protects them stays on this tablet: without
  /// them a restored database has users whose passwords no longer match, and the website's
  /// certificate changes. See docs/features/backup.md.
  static const secretNames = [
    'password.pepper',
    'tls.private_key',
    'tls.certificate',
    'pin.client.registration',
  ];

  static const _channel = MethodChannel('tech.algoriti.algoritiq/backup');

  @override
  Future<BackupEntry> create(BackupKind kind) async {
    final secrets = <String, String>{};
    for (final name in secretNames) {
      final value = await _secrets.read(name);
      if (value != null) secrets[name] = value;
    }
    final map = await _channel.invokeMapMethod<String, Object?>('create', {
      'kind': kind == BackupKind.automatic ? 'automatic' : 'manual',
      'secrets': secrets,
    });
    if (map == null) throw StateError('Backup failed.');
    return BackupEntry.fromJson(map);
  }

  @override
  Future<List<BackupEntry>> list() async {
    final raw = await _channel.invokeMethod<List<Object?>>('list');
    if (raw == null) return const [];
    return raw
        .cast<Map<Object?, Object?>>()
        .map((e) => BackupEntry.fromJson(e.cast<String, Object?>()))
        .toList();
  }

  @override
  Future<void> delete(String id) => _channel.invokeMethod('delete', {'id': id});

  @override
  Future<void> restore(String id) async {
    final saved = await _channel.invokeMapMethod<String, String>('restore', {
      'id': id,
    });
    for (final MapEntry(:key, :value)
        in (saved ?? const <String, String>{}).entries) {
      await _secrets.write(key, value);
    }
  }

  @override
  Future<String> archivePath(String id) async {
    final path = await _channel.invokeMethod<String>('archivePath', {'id': id});
    if (path == null || path.isEmpty) throw StateError('Backup file missing.');
    return path;
  }

  @override
  Future<BackupEntry> importArchiveFile(String absolutePath) async {
    final map = await _channel.invokeMapMethod<String, Object?>(
      'importArchive',
      {'path': absolutePath},
    );
    if (map == null) throw StateError('Import failed.');
    return BackupEntry.fromJson(map);
  }

  @override
  Future<void> restartApp() => _channel.invokeMethod('restart');
}

final backupGatewayProvider = Provider<BackupGateway>(
  (ref) => const ChannelBackupGateway(),
);

const _prefsScheduleKey = 'backup.schedule';
const _prefsLastAutoKey = 'backup.lastAutomaticAtMs';

/// Settings and scheduled backups (Dart side; archive I/O is native).
final class BackupPreferences {
  BackupPreferences(this._prefs);

  final SharedPreferences _prefs;

  static Future<BackupPreferences> open() async =>
      BackupPreferences(await SharedPreferences.getInstance());

  BackupSettings readSettings() {
    final raw = _prefs.getString(_prefsScheduleKey);
    return BackupSettings(
      schedule: BackupSchedule.values.asNameMap()[raw] ?? BackupSchedule.off,
    );
  }

  Future<void> writeSettings(BackupSettings settings) =>
      _prefs.setString(_prefsScheduleKey, settings.schedule.name);

  DateTime? lastAutomaticAt() {
    final ms = _prefs.getInt(_prefsLastAutoKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  Future<void> markAutomaticRun(DateTime when) =>
      _prefs.setInt(_prefsLastAutoKey, when.toUtc().millisecondsSinceEpoch);
}

final backupPreferencesProvider = Provider<BackupPreferences>((ref) {
  throw StateError('BackupPreferences not ready.');
});
