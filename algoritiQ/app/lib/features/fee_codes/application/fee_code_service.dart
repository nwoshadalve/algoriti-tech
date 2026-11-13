// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/id_generator.dart';
import '../../access/application/access_providers.dart';
import '../../access/domain/account.dart';
import '../../access/domain/account_repository.dart';
import '../domain/fee_code.dart';

/// The save was refused; [problem] says why.
final class FeeCodeRefused implements Exception {
  const FeeCodeRefused(this.problem);

  final FeeCodeProblem problem;
}

/// The clinic's fee codes: read by everyone who enters patients, changed by
/// the admin. Kept in the settings table as one JSON list.
class FeeCodeService {
  FeeCodeService({
    required AppDatabase database,
    required AccountRepository accounts,
    required Clock clock,
    required IdGenerator newId,
  }) : _db = database,
       _accounts = accounts,
       _clock = clock,
       _newId = newId;

  final AppDatabase _db;
  final AccountRepository _accounts;
  final Clock _clock;
  final IdGenerator _newId;

  static const _key = 'fee_codes';

  /// The codes in the order the admin set them (empty: none defined).
  Future<List<FeeCode>> list() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(_key))).getSingleOrNull();
    if (row == null) return const [];
    try {
      return [
        for (final raw in jsonDecode(row.value) as List<Object?>)
          if (raw is Map<String, Object?>) FeeCode.fromJson(raw),
      ];
    } on Object {
      return const [];
    }
  }

  /// Replaces the whole list. A code without an id gets one; a code that
  /// keeps its id keeps standing for the same fee when renamed.
  Future<List<FeeCode>> replace(Account admin, List<FeeCode> input) async {
    final codes = [
      for (final fee in input)
        FeeCode(
          id: fee.id.isEmpty ? _newId() : fee.id,
          code: fee.code.trim(),
          amountBdt: fee.amountBdt,
        ),
    ];
    final problem = FeeCodes.validate(codes);
    if (problem != null) throw FeeCodeRefused(problem);

    final before = await list();
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _key,
            value: jsonEncode([for (final fee in codes) fee.toJson()]),
          ),
        );
    await _accounts.audit(
      at: _clock(),
      action: 'fee_codes.updated',
      actorId: admin.id,
      detail: jsonEncode({
        'before': before.length,
        'after': codes.length,
        'outcome': 'success',
        'category': 'configuration',
        'sourceClient': 'web',
      }),
    );
    return codes;
  }
}

final feeCodeServiceProvider = Provider<FeeCodeService>(
  (ref) => FeeCodeService(
    database: ref.watch(appDatabaseProvider),
    accounts: ref.watch(accountRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);

/// The codes for a dialog that is opening; read again each time it opens so a
/// change the admin just made is picked up.
final feeCodesProvider = FutureProvider.autoDispose<List<FeeCode>>(
  (ref) => ref.watch(feeCodeServiceProvider).list(),
);
