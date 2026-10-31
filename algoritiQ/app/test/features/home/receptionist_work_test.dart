// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:algoritiq_app/features/access/application/access_providers.dart';
import 'package:algoritiq_app/features/access/application/tablet_session.dart';
import 'package:algoritiq_app/features/access/application/user_management_service.dart';
import 'package:algoritiq_app/features/access/domain/account.dart';
import 'package:algoritiq_app/features/home/application/receptionist_work.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/licensing_kit.dart';

TabletSignIn _deskSession() => TabletSignIn(
  Account(
    id: 'seed-desk',
    username: 'desk',
    displayName: 'Front Desk',
    email: 'desk@clinic.test',
    role: Role.receptionist,
    createdAt: testNow,
  ),
  'token',
);

void main() {
  late LicensingKit kit;
  late MemoryLicenseStore licensed;

  setUpAll(() async {
    kit = await LicensingKit.create();
    licensed = MemoryLicenseStore(await kit.issue());
  });

  test('should auto-select when the receptionist has one chamber', () async {
    final container = ProviderContainer(
      overrides: [
        ...kit.overrides(
          store: licensed,
          signedIn: false,
          seed: seedSignedInReceptionist,
        ),
      ],
    );
    addTearDown(container.dispose);

    final accounts = container.read(accountRepositoryProvider);
    for (var attempt = 0; attempt < 50; attempt++) {
      if ((await accounts.getUserScopes('seed-desk')).isNotEmpty) break;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }

    final notifier = container.read(receptionistWorkProvider.notifier);
    await notifier.syncSession(_deskSession());

    final work = container.read(receptionistWorkProvider);
    expect(work, isA<ReceptionistWorkReady>());
    expect((work as ReceptionistWorkReady).selected.name, 'Main chamber');
  });

  test(
    'should ask to choose when the receptionist has several chambers',
    () async {
      final container = ProviderContainer(
        overrides: kit.overrides(
          store: licensed,
          signedIn: false,
          seed: (database) async {
            await seedSignedInReceptionist(database);
            await database
                .into(database.chambers)
                .insertOnConflictUpdate(
                  ChambersCompanion.insert(
                    id: 'seed-chamber-2',
                    doctorId: 'seed-doctor',
                    name: 'Second chamber',
                    createdAt: testNow.millisecondsSinceEpoch,
                  ),
                );
            await database
                .into(database.userScopeAssignments)
                .insertOnConflictUpdate(
                  UserScopeAssignmentsCompanion.insert(
                    userId: 'seed-desk',
                    scopeId: 'seed-chamber-2',
                  ),
                );
          },
        ),
      );
      addTearDown(container.dispose);

      final accounts = container.read(accountRepositoryProvider);
      for (var attempt = 0; attempt < 50; attempt++) {
        if ((await accounts.getUserScopes('seed-desk')).length >= 2) break;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      // Seed runs async; wait for DB writes before sync.
      await Future<void>.delayed(Duration.zero);
      await pumpEventQueue();

      final notifier = container.read(receptionistWorkProvider.notifier);
      await notifier.syncSession(_deskSession());

      expect(
        container.read(receptionistWorkProvider),
        isA<ReceptionistWorkChoose>(),
      );
      expect(notifier.canChangeWorkScope, isTrue);

      final choose =
          container.read(receptionistWorkProvider) as ReceptionistWorkChoose;
      notifier.select(choose.options.first);
      expect(
        container.read(receptionistWorkProvider),
        isA<ReceptionistWorkReady>(),
      );

      notifier.reopenChoice();
      expect(
        container.read(receptionistWorkProvider),
        isA<ReceptionistWorkChoose>(),
      );
    },
  );
}
