import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:algoritiq_app/features/clinic/domain/chamber.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/licensing_kit.dart';
import '../../support/pump_app.dart';

void main() {
  late LicensingKit kit;
  late MemoryLicenseStore license;

  setUpAll(() async {
    kit = await LicensingKit.create();
    license = MemoryLicenseStore(await kit.issue(chambers: 3));
  });

  const screens = {
    'phone portrait': Size(360, 740),
    'phone landscape': Size(740, 360),
    'tablet portrait': Size(800, 1280),
    'tablet landscape': Size(1280, 800),
  };

  Future<void> seedStep(AppDatabase db, String stage) async {
    await db
        .into(db.doctors)
        .insert(
          // A realistic profile: long Bangladeshi credentials fill every field.
          DoctorsCompanion.insert(
            id: 'd1',
            name: 'Assistant Professor Dr. Md. Zahidul Haque Khan',
            specialty: const Value(
              'Bone and joint, rheumatism, accident orthopaedics, trauma '
              'surgery specialist and surgeon',
            ),
            degrees: const Value(
              '["MBBS (DMC)","BCS (Health)","MS (Orthopaedic Surgery)",'
              '"BSMMU (former PG Hospital)","AO Trauma Basic",'
              '"AO Pelvis-Acetabulum"]',
            ),
            designation: const Value('Assistant Professor, Ortho-Surgery'),
            workplace: const Value('National Institute of Traumatology, Dhaka'),
            registrationNumber: const Value('A-50414'),
          ),
        );
    for (final (i, chamber) in const [
      Chamber(
        id: 'c1',
        doctorId: 'd1',
        name: 'Al-Khidmah Medical Services (Pvt.), Chandpur',
        location: 'Chandpur Sadar, Chandpur',
        phone: '01766521717',
      ),
      Chamber(
        id: 'c2',
        doctorId: 'd1',
        name: 'Uttara Chamber',
        location: 'Uttara, Dhaka',
        phone: '01700000000',
      ),
    ].indexed) {
      await db
          .into(db.chambers)
          .insert(
            ChambersCompanion.insert(
              id: chamber.id,
              doctorId: 'd1',
              name: chamber.name,
              location: Value(chamber.location),
              phone: Value(chamber.phone),
              createdAt: i,
            ),
          );
    }
    await seedStage(db, stage);
  }

  const steps = {
    'profile': 'Full name, with title',
    'chambers': 'Chamber name',
    'ready': 'Start',
  };

  for (final MapEntry(key: stage, value: marker) in steps.entries) {
    for (final MapEntry(key: name, value: size) in screens.entries) {
      for (final brightness in Brightness.values) {
        for (final textScale in [1.0, 2.0]) {
          testWidgets(
            'should lay out the $stage step on $name, ${brightness.name}, '
            'text x$textScale',
            (tester) async {
              tester.view.physicalSize = size;
              tester.view.devicePixelRatio = 1;
              tester.platformDispatcher.platformBrightnessTestValue =
                  brightness;
              tester.platformDispatcher.textScaleFactorTestValue = textScale;
              addTearDown(tester.view.reset);
              addTearDown(tester.platformDispatcher.clearAllTestValues);

              await pumpApp(
                tester,
                kit.overrides(
                  store: license,
                  setupDone: false,
                  seed: (db) => seedStep(db, stage),
                ),
              );
              await tester.runAsync(() => Future<void>.delayed(Duration.zero));
              await tester.pumpAndSettle();

              expect(tester.takeException(), isNull);
              expect(find.text(marker), findsWidgets);
            },
          );
        }
      }
    }
  }

  group('landscape tablet', () {
    // Counter tablets are used in landscape: nobody should scroll to finish.
    // 893x533 is the Honor Pad X7 held sideways (800x1340 px at 240 dpi).
    // With a realistic, fully filled-in doctor (six long degrees).
    const tablets = {
      '1280x800': (Size(1280, 800), 0.0),
      '1024x600': (Size(1024, 600), 0.0),
      '893x533': (Size(893, 533), 0.0),
    };

    for (final stage in ['profile', 'chambers', 'ready']) {
      for (final MapEntry(key: name, value: (size, allowed))
          in tablets.entries) {
        testWidgets('should need at most $allowed dp of scrolling for the '
            '$stage step at $name', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          // The tablet's status bar and navigation bar take height too.
          tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
          tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
          addTearDown(tester.view.reset);

          await pumpApp(
            tester,
            kit.overrides(
              store: license,
              setupDone: false,
              seed: (db) => seedStep(db, stage),
            ),
          );
          await tester.runAsync(() => Future<void>.delayed(Duration.zero));
          await tester.pumpAndSettle();

          final scrollable = find
              .descendant(
                of: find.byType(SingleChildScrollView),
                matching: find.byType(Scrollable),
              )
              .first;
          final position = tester.state<ScrollableState>(scrollable).position;
          expect(position.maxScrollExtent, lessThanOrEqualTo(allowed));
        });
      }
    }
  });
}
