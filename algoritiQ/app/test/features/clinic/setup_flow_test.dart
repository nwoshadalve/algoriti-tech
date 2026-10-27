import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:algoritiq_app/features/clinic/application/clinic_providers.dart';
import 'package:algoritiq_app/features/licensing/domain/license_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:algoritiq_app/features/clinic/presentation/doctor_photo_field.dart';

import '../../support/fake_photo_store.dart';
import '../../support/licensing_kit.dart';
import '../../support/pump_app.dart';

void main() {
  late LicensingKit kit;
  late MemoryLicenseStore doctorLicense;

  setUpAll(() async {
    kit = await LicensingKit.create();
    doctorLicense = MemoryLicenseStore(await kit.issue(chambers: 2));
  });

  /// A tall screen, so the whole profile form is on screen without scrolling.
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> openSetup(
    WidgetTester tester, {
    String stage = 'profile',
    bool readinessAcknowledged = true,
    Future<void> Function(AppDatabase)? seed,
  }) {
    useTallScreen(tester);
    return pumpApp(tester, [
      ...kit.overrides(
        store: doctorLicense,
        setupDone: false,
        readinessAcknowledged: readinessAcknowledged,
        seed: seed,
      ),
    ]);
  }

  /// Lets queued database work finish, then redraws.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  /// The text field under [label].
  Finder fieldLabelled(String label) => find.descendant(
    of: find.ancestor(
      of: find.text(label),
      matching: find.byType(MergeSemantics),
    ),
    matching: find.byType(TextField),
  );

  Future<void> tapText(WidgetTester tester, String text) =>
      tester.tap(find.text(text));

  /// Fills the chamber form (name, address and phone are all required).
  Future<void> addChamber(
    WidgetTester tester,
    String name, {
    String address = 'Some address',
    String phone = '01700000000',
  }) async {
    await tester.enterText(fieldLabelled('Chamber name'), name);
    await tester.enterText(fieldLabelled('Address'), address);
    await tester.enterText(fieldLabelled('Serial or contact number'), phone);
    await tapText(tester, 'Add chamber');
    await settle(tester);
  }

  testWidgets('should walk a new doctor from profile to home', (tester) async {
    await openSetup(tester);

    expect(find.text('Full name, with title'), findsOneWidget);
    await tester.enterText(fieldLabelled('Full name, with title'), 'Dr. Test');
    await tester.enterText(fieldLabelled('Degrees'), 'MBBS');
    await tester.tap(find.byTooltip('Add degree'));
    await tester.pump();
    await tester.enterText(fieldLabelled('Degrees'), 'MS');
    await tester.tap(find.byTooltip('Add degree'));
    await tester.pump();
    await tester.enterText(fieldLabelled('Designation'), 'Assistant Professor');
    await tester.enterText(
      fieldLabelled('Specialty and areas of expertise'),
      'Orthopaedics',
    );
    await tapText(tester, 'Continue');
    await settle(tester);

    expect(find.text('Add your chambers'), findsOneWidget);
    expect(find.text('0 of 2 chambers'), findsOneWidget);
    await addChamber(tester, 'Dhanmondi Chamber');
    expect(find.text('1 of 2 chambers'), findsOneWidget);
    expect(find.text('Dhanmondi Chamber'), findsOneWidget);

    await tapText(tester, 'Continue');
    await settle(tester);

    expect(find.text("You're all set"), findsOneWidget);
    expect(find.text('Dr. Test'), findsOneWidget);
    expect(find.text('MBBS, MS'), findsOneWidget);
    expect(find.text('Assistant Professor'), findsOneWidget);
    await tapText(tester, 'Start');
    await settle(tester);

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('should show keep the tablet ready after finishing setup', (
    tester,
  ) async {
    await openSetup(tester, readinessAcknowledged: false);

    await tester.enterText(fieldLabelled('Full name, with title'), 'Dr. Test');
    await tester.enterText(fieldLabelled('Degrees'), 'MBBS');
    await tester.tap(find.byTooltip('Add degree'));
    await tester.pump();
    await tester.enterText(fieldLabelled('Degrees'), 'MS');
    await tester.tap(find.byTooltip('Add degree'));
    await tester.pump();
    await tester.enterText(fieldLabelled('Designation'), 'Assistant Professor');
    await tester.enterText(
      fieldLabelled('Specialty and areas of expertise'),
      'Orthopaedics',
    );
    await tapText(tester, 'Continue');
    await settle(tester);

    await addChamber(tester, 'Dhanmondi Chamber');
    await tapText(tester, 'Continue');
    await settle(tester);

    await tapText(tester, 'Start');
    await settle(tester);

    expect(find.text('Keep the tablet ready'), findsOneWidget);
    expect(find.text('Create the admin account'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
  });

  // regression: name, designation, specialty and a degree are mandatory.
  testWidgets('should ask for every blank required profile field', (
    tester,
  ) async {
    await openSetup(tester);

    await tapText(tester, 'Continue');
    await settle(tester);

    expect(find.text('Enter your name.'), findsOneWidget);
    expect(find.text('Enter your designation.'), findsOneWidget);
    expect(find.text('Add at least one degree.'), findsOneWidget);
    expect(find.text('Enter your specialty.'), findsOneWidget);
    expect(find.text('Add your chambers'), findsNothing);
  });

  testWidgets('should only flag the profile fields that are blank', (
    tester,
  ) async {
    await openSetup(tester);
    await tester.enterText(fieldLabelled('Full name, with title'), 'Dr. Test');
    await tester.enterText(fieldLabelled('Designation'), 'Professor');

    await tapText(tester, 'Continue');
    await settle(tester);

    expect(find.text('Enter your name.'), findsNothing);
    expect(find.text('Enter your designation.'), findsNothing);
    expect(find.text('Add at least one degree.'), findsOneWidget);
    expect(find.text('Enter your specialty.'), findsOneWidget);
  });

  testWidgets('should not mark hospital or registration as required', (
    tester,
  ) async {
    await openSetup(tester);

    expect(find.text('Designation (optional)'), findsNothing);
    expect(find.text('Degrees (optional)'), findsNothing);
    expect(
      find.text('Specialty and areas of expertise (optional)'),
      findsNothing,
    );
    expect(find.text('Hospital or institution (optional)'), findsOneWidget);
    expect(
      find.text('Medical council registration number (optional)'),
      findsOneWidget,
    );
  });

  group('chambers step', () {
    Future<void> seedChambersStep(AppDatabase db) async {
      await seedDoctor(db);
      await seedStage(db, 'chambers');
    }

    testWidgets('should not continue without a chamber', (tester) async {
      await openSetup(tester, seed: seedChambersStep);
      await settle(tester);

      await tester.tap(find.text('Continue'));
      await settle(tester);

      expect(
        find.text('Add at least one chamber to continue.'),
        findsOneWidget,
      );
      expect(find.text("You're all set"), findsNothing);
    });

    testWidgets('should stop adding at the license limit', (tester) async {
      await openSetup(tester, seed: seedChambersStep);
      await settle(tester);

      await addChamber(tester, 'First');
      await addChamber(tester, 'Second');

      expect(find.text('2 of 2 chambers'), findsOneWidget);
      expect(
        find.text("Your license covers 2 chambers, and you've added them all."),
        findsOneWidget,
      );
      expect(find.text('Add chamber'), findsNothing);
    });

    // regression: name, address and phone are all mandatory.
    testWidgets('should ask for every blank chamber field', (tester) async {
      await openSetup(tester, seed: seedChambersStep);
      await settle(tester);

      await tapText(tester, 'Add chamber');
      await settle(tester);

      expect(find.text('Enter a chamber name.'), findsOneWidget);
      expect(find.text('Enter the chamber address.'), findsOneWidget);
      expect(find.text('Enter a phone number.'), findsOneWidget);
      expect(find.text('0 of 2 chambers'), findsOneWidget);
    });

    testWidgets('should only flag the fields that are blank', (tester) async {
      await openSetup(tester, seed: seedChambersStep);
      await settle(tester);
      await tester.enterText(fieldLabelled('Chamber name'), 'Only a name');

      await tapText(tester, 'Add chamber');
      await settle(tester);

      expect(find.text('Enter a chamber name.'), findsNothing);
      expect(find.text('Enter the chamber address.'), findsOneWidget);
      expect(find.text('Enter a phone number.'), findsOneWidget);
    });

    testWidgets('should go back to the profile and forward again', (
      tester,
    ) async {
      await openSetup(tester, seed: seedChambersStep);
      await settle(tester);
      await addChamber(tester, 'Kept chamber');

      await tapText(tester, 'Back');
      await settle(tester);

      expect(find.text('Full name, with title'), findsOneWidget);
      expect(find.text('Seeded doctor'), findsOneWidget);

      await tapText(tester, 'Continue');
      await settle(tester);

      expect(find.text('Add your chambers'), findsOneWidget);
      expect(find.text('Kept chamber'), findsOneWidget);
    });

    testWidgets('should treat the system back gesture as Back', (tester) async {
      await openSetup(tester, seed: seedChambersStep);
      await settle(tester);

      await tester.binding.handlePopRoute();
      await settle(tester);

      expect(find.text('Full name, with title'), findsOneWidget);
    });

    testWidgets('should go back from the summary to the chambers', (
      tester,
    ) async {
      await openSetup(tester, seed: seedChambersStep);
      await settle(tester);
      await addChamber(tester, 'Only chamber');
      await tapText(tester, 'Continue');
      await settle(tester);
      expect(find.text("You're all set"), findsOneWidget);

      await tapText(tester, 'Back');
      await settle(tester);

      expect(find.text('Add your chambers'), findsOneWidget);
      expect(find.text('Only chamber'), findsOneWidget);
    });

    testWidgets('should rename a chamber', (tester) async {
      await openSetup(tester, seed: seedChambersStep);
      await settle(tester);
      await addChamber(tester, 'Old name');

      await tester.tap(find.byTooltip('Edit Old name'));
      await tester.pump();
      await tester.enterText(fieldLabelled('Chamber name'), 'New name');
      await tapText(tester, 'Save chamber');
      await settle(tester);

      expect(find.text('New name'), findsOneWidget);
      expect(find.text('Old name'), findsNothing);
      expect(find.text('1 of 2 chambers'), findsOneWidget);
    });

    testWidgets('should resume at the saved step after a restart', (
      tester,
    ) async {
      await openSetup(tester, seed: seedChambersStep);
      await settle(tester);

      expect(find.text('Add your chambers'), findsOneWidget);
      expect(find.text('Full name, with title'), findsNothing);
    });
  });

  group('doctor photo', () {
    final photoTap = find.byKey(DoctorPhotoField.tapKey);

    /// The photo control as a screen reader announces it.
    Finder announced(String label) => find.bySemanticsLabel(RegExp(label));

    Future<void> choosePhoto(WidgetTester tester) async {
      await tester.tap(photoTap);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pumpAndSettle();
    }

    Future<void> openWith(WidgetTester tester, FakePhotoStore photos) {
      useTallScreen(tester);
      return pumpApp(tester, [
        ...kit.overrides(store: doctorLicense, setupDone: false),
        photoStoreProvider.overrideWithValue(photos),
      ]);
    }

    testWidgets('should offer to add a photo, then to change or remove it', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await openWith(tester, FakePhotoStore(next: '/photos/one.jpg'));
      expect(announced('Add photo'), findsOneWidget);

      await choosePhoto(tester);
      expect(announced('Change photo'), findsOneWidget);

      // Removing is one of the choices in the photo sheet.
      await tester.tap(photoTap);
      await tester.pumpAndSettle();
      expect(find.text('Remove photo'), findsOneWidget);
      await tester.tap(find.text('Remove photo'));
      await tester.pumpAndSettle();

      expect(announced('Add photo'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('should delete a photo that was replaced before saving', (
      tester,
    ) async {
      final photos = FakePhotoStore(next: '/photos/one.jpg');
      await openWith(tester, photos);
      await choosePhoto(tester);

      photos.next = '/photos/two.jpg';
      await tester.tap(photoTap);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Take a photo'));
      await tester.pumpAndSettle();

      expect(photos.removed, ['/photos/one.jpg']);
    });

    testWidgets('should keep the form usable when the photo fails', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await openWith(tester, FakePhotoStore(fails: true));

      await choosePhoto(tester);

      expect(
        find.text("Couldn't use that photo. Try another."),
        findsOneWidget,
      );
      expect(announced('Add photo'), findsOneWidget);
      semantics.dispose();
    });
  });

  testWidgets('should skip setup for a chamber license', (tester) async {
    final chamberLicense = MemoryLicenseStore(
      await kit.issue(type: LicenseType.chamber, doctors: 2, chambers: 1),
    );
    await pumpApp(tester, <Override>[
      ...kit.overrides(store: chamberLicense, setupDone: false),
    ]);

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Full name, with title'), findsNothing);
  });
}
