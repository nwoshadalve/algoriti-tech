// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:io';

import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// A safety check to run before an upgrade reaches a real tablet: it migrates
/// a COPY of the tablet's database and checks that nothing was lost. Set
/// `ALGORITIQ_DB_COPY` to the copied `algoritiq.sqlite`; without it the test
/// is skipped.
void main() {
  final path = Platform.environment['ALGORITIQ_DB_COPY'];

  test('should migrate a copy of a tablet database without losing anything', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final database = AppDatabase(NativeDatabase(File(path!)));
    addTearDown(database.close);

    Future<int> count(String table) async =>
        (await database
                .customSelect('SELECT COUNT(*) AS n FROM $table')
                .getSingle())
            .read<int>('n');

    final version =
        (await database.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version');
    final patients = await database
        .customSelect(
          'SELECT id, name, bengali_name, english_name FROM patients',
        )
        .get();
    final tokens = await database
        .customSelect(
          'SELECT id, status, first_called_at, announced_at FROM queue_tokens',
        )
        .get();

    expect(version, database.schemaVersion);
    expect(patients, isNotEmpty);
    for (final p in patients) {
      final bengali = p.read<String>('bengali_name').trim();
      final english = (p.read<String?>('english_name') ?? '').trim();
      // One name, never blank when there was a name before.
      expect(
        p.read<String>('name'),
        bengali.isNotEmpty ? bengali : english,
        reason: 'patient ${p.read<String>('id')}',
      );
    }
    for (final t in tokens) {
      if (t.read<int?>('first_called_at') != null) {
        expect(
          t.read<int?>('announced_at'),
          t.read<int?>('first_called_at'),
          reason: 'token ${t.read<String>('id')} was called before',
        );
      }
    }
    // Nothing was added or removed.
    expect(await count('patients'), patients.length);
    expect(await count('queue_tokens'), tokens.length);
  }, skip: path == null ? 'set ALGORITIQ_DB_COPY to a copied database' : false);
}
