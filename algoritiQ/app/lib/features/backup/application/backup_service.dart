// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:io';

import '../../../core/clock.dart';
import '../../../platform/backup_gateway.dart';
import '../domain/backup_policy.dart';

/// Admin backup and restore: create archives, list them, run automatic copies.
class BackupService {
  BackupService({
    required BackupGateway gateway,
    required BackupPreferences prefs,
    required Clock clock,
    this.maxBackups = BackupPolicy.retentionLimit,
  }) : _gateway = gateway,
       _prefs = prefs,
       _clock = clock;

  final BackupGateway _gateway;
  final BackupPreferences _prefs;
  final Clock _clock;
  final int maxBackups;

  Future<BackupSettings> settings() async => _prefs.readSettings();

  Future<BackupSettings> updateSettings(BackupSettings next) async {
    await _prefs.writeSettings(next);
    return next;
  }

  Future<List<BackupEntry>> list({bool runSchedule = true}) async {
    if (runSchedule) await _maybeRunAutomatic();
    await _prune();
    return _gateway.list();
  }

  Future<BackupEntry> createManual() async {
    final entry = await _gateway.create(BackupKind.manual);
    await _prune();
    return entry;
  }

  Future<void> delete(String id) => _gateway.delete(id);

  Future<void> restore(String id) => _gateway.restore(id);

  Future<String> archivePath(String id) => _gateway.archivePath(id);

  /// Saves bytes from the web upload, registers them as a backup, then deletes the temp file.
  Future<BackupEntry> importArchiveBytes(List<int> bytes) async {
    final temp = File(
      '${Directory.systemTemp.path}/algoritiq-import-${_clock().millisecondsSinceEpoch}.zip',
    );
    await temp.writeAsBytes(bytes, flush: true);
    try {
      final entry = await _gateway.importArchiveFile(temp.path);
      await _prune();
      return entry;
    } finally {
      if (await temp.exists()) await temp.delete();
    }
  }

  Future<void> _maybeRunAutomatic() async {
    final settings = _prefs.readSettings();
    if (settings.schedule == BackupSchedule.off) return;
    final interval = switch (settings.schedule) {
      BackupSchedule.daily => const Duration(hours: 24),
      BackupSchedule.weekly => const Duration(days: 7),
      BackupSchedule.off => null,
    };
    if (interval == null) return;
    final now = _clock().toUtc();
    final last = _prefs.lastAutomaticAt();
    if (last != null && now.difference(last) < interval) return;
    await _gateway.create(BackupKind.automatic);
    await _prefs.markAutomaticRun(now);
    await _prune();
  }

  Future<void> _prune() async {
    final entries = await _gateway.list();
    if (entries.length <= maxBackups) return;
    final drop = entries.sublist(maxBackups);
    for (final entry in drop) {
      await _gateway.delete(entry.id);
    }
  }
}
