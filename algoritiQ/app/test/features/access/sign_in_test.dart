// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:algoritiq_app/app/app.dart';
import 'package:algoritiq_app/features/access/application/access_providers.dart';
import 'package:algoritiq_app/features/access/application/access_service.dart';
import 'package:algoritiq_app/features/access/application/tablet_session.dart';
import 'package:algoritiq_app/features/access/domain/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/licensing_kit.dart';

void main() {
  late LicensingKit kit;
  late MemoryLicenseStore licensed;

  const password = 'a-long-passphrase';
  const newPassword = 'a-brand-new-passphrase';

  setUpAll(() async {
    kit = await LicensingKit.create();
    licensed = MemoryLicenseStore(await kit.issue());
  });

  /// Real work (hashing) needs real time; the screen needs pumping.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// A tablet with an admin ('owner') and nobody signed in.
  Future<ProviderContainer> open(
    WidgetTester tester, {
    Size? size,
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) async {
    if (size != null) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
      tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
      addTearDown(tester.view.reset);
    }
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    final container = ProviderContainer(
      overrides: kit.overrides(
        store: licensed,
        adminRegistered: false,
        signedIn: false,
      ),
    );
    addTearDown(container.dispose);
    final service = await tester.runAsync(
      () => container.read(accessServiceProvider.future),
    );
    await tester.runAsync(
      () => service!.registerAdmin(
        claimCode: container.read(claimCodesProvider).current().code,
        username: 'owner',
        firstName: 'The',
        lastName: 'Owner',
        email: 'owner@clinic.test',
        password: password,
      ),
    );
    await tester.runAsync(() async {
      final hasher = await container.read(passwordHasherProvider.future);
      await container
          .read(accountRepositoryProvider)
          .createManagedUser(
            account: Account(
              id: 'desk-1',
              username: 'desk',
              displayName: 'Front Desk',
              email: 'desk@clinic.test',
              role: Role.receptionist,
              createdAt: DateTime.utc(2026, 1, 1),
            ),
            passwordHash: await hasher.hash(password),
            actorId: 'owner',
            at: DateTime.utc(2026, 1, 1),
          );
      final db = container.read(appDatabaseProvider);
      await seedDoctor(db);
      const chamberId = 'sign-in-chamber';
      await db
          .into(db.chambers)
          .insertOnConflictUpdate(
            ChambersCompanion.insert(
              id: chamberId,
              doctorId: 'seed-doctor',
              name: 'Main chamber',
              createdAt: testNow.millisecondsSinceEpoch,
            ),
          );
      await container
          .read(accountRepositoryProvider)
          .setUserScopes(
            userId: 'desk-1',
            scopeIds: [chamberId],
            actorId: 'owner',
            at: DateTime.utc(2026, 1, 1),
          );
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AlgoritiqApp(),
      ),
    );
    await settle(tester);
    return container;
  }

  Future<void> close(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox.shrink());

  Future<void> signIn(
    WidgetTester tester, {
    String user = 'desk',
    String pass = password,
  }) async {
    await tester.enterText(find.byType(TextField).at(0), user);
    await tester.enterText(find.byType(TextField).at(1), pass);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await settle(tester);
  }

  Future<void> tapSignOut(WidgetTester tester) async {
    final menu = find.byTooltip('Open menu');
    if (menu.evaluate().isNotEmpty) {
      await tester.tap(menu);
      await settle(tester);
    }
    await tester.tap(find.text('Front Desk'));
    await settle(tester);
    await tester.tap(find.text('Sign out'));
    await settle(tester);
  }

  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.widgetWithText(FilledButton, label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await settle(tester);
  }

  /// Step 1: the username.
  Future<void> giveUsername(
    WidgetTester tester, {
    String name = 'owner',
  }) async {
    await tester.enterText(find.byType(TextField).first, name);
    await tapButton(tester, 'Continue');
  }

  /// Step 2: the activation key.
  Future<void> giveKey(WidgetTester tester, {String? key}) async {
    await tester.enterText(
      find.byType(TextField).first,
      key ?? licensed.token!,
    );
    await tapButton(tester, 'Continue');
  }

  /// Step 3: the new password, twice.
  Future<void> givePassword(
    WidgetTester tester, {
    String pass = newPassword,
    String? confirm,
  }) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), pass);
    await tester.enterText(fields.at(1), confirm ?? pass);
    await tapButton(tester, 'Reset password');
  }

  Future<void> openReset(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Forgot password?'));
    await tester.tap(find.text('Forgot password?'));
    await settle(tester);
  }

  group('admin on the tablet', () {
    /// The tablet is closed and opened again: the app is still running.
    Future<void> closeAndReopen(WidgetTester tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(tester);
    }

    testWidgets('should point an admin to the web app instead of the app', (
      tester,
    ) async {
      await open(tester);

      await signIn(tester, user: 'owner');

      expect(find.text('Admin sign-in is on the web'), findsOneWidget);
      expect(
        find.textContaining('only has the receptionist screen'),
        findsOneWidget,
      );
      expect(find.text('https://192.168.0.20:8443'), findsWidgets);
      expect(find.widgetWithText(FilledButton, 'OK'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      await close(tester);
    });

    testWidgets('should show the sign-in screen when the admin presses OK', (
      tester,
    ) async {
      await open(tester);
      await signIn(tester, user: 'owner');

      await tester.tap(find.widgetWithText(FilledButton, 'OK'));
      await settle(tester);

      expect(find.text('Admin sign-in is on the web'), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byType(TextField), findsNWidgets(2));
      await close(tester);
    });

    testWidgets('should sign the admin out when the app is closed', (
      tester,
    ) async {
      await open(tester);
      await signIn(tester, user: 'owner');

      await closeAndReopen(tester);

      expect(find.text('Admin sign-in is on the web'), findsNothing);
      expect(find.byType(TextField), findsNWidgets(2));
      await close(tester);
    });

    testWidgets('should keep a receptionist signed in on the same close', (
      tester,
    ) async {
      await open(tester);
      await signIn(tester);

      await closeAndReopen(tester);

      expect(find.text('Patient queue'), findsOneWidget);
      await close(tester);
    });

    testWidgets('should end the admin sign-in at OK, not keep it hidden', (
      tester,
    ) async {
      final container = await open(tester);
      await signIn(tester, user: 'owner');

      await tester.tap(find.widgetWithText(FilledButton, 'OK'));
      await settle(tester);

      expect(container.read(tabletSessionProvider), isNull);
      await close(tester);
    });
  });

  group('signing in on the tablet', () {
    testWidgets('should ask for the password once an admin exists', (
      tester,
    ) async {
      await open(tester);

      expect(find.text('Sign in'), findsWidgets);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byIcon(Icons.add), findsNothing);
      await close(tester);
    });

    testWidgets('should open the app after the right password', (tester) async {
      await open(tester);

      await signIn(tester);

      expect(find.text('Patient queue'), findsOneWidget);
      await close(tester);
    });

    testWidgets('should not care about capitals in the username', (
      tester,
    ) async {
      await open(tester);

      await signIn(tester, user: ' Desk ');

      expect(find.text('Patient queue'), findsOneWidget);
      await close(tester);
    });

    testWidgets('should refuse a wrong password and clear it', (tester) async {
      await open(tester);

      await signIn(tester, pass: 'wrong-password-1');

      expect(find.text('Wrong username, email or password.'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      final field = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(field.controller!.text, isEmpty);
      await close(tester);
    });

    testWidgets('should not call anything with an empty form', (tester) async {
      await open(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await settle(tester);

      expect(
        find.text('Enter your username or email and your password.'),
        findsOneWidget,
      );
      await close(tester);
    });

    testWidgets('should slow down someone guessing passwords', (tester) async {
      await open(tester);

      for (var i = 0; i < 5; i++) {
        await signIn(tester, pass: 'wrong-password-$i');
      }
      await signIn(tester);

      expect(find.textContaining('Try again in'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      await close(tester);
    });

    testWidgets('should hide the password until asked', (tester) async {
      await open(tester);
      EditableText field() =>
          tester.widget<EditableText>(find.byType(EditableText).at(1));
      expect(field().obscureText, isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();

      expect(field().obscureText, isFalse);
      await close(tester);
    });

    testWidgets('should sign out from the app and ask again', (tester) async {
      await open(tester);
      await signIn(tester);

      await tapSignOut(tester);

      expect(find.text('Patient queue'), findsNothing);
      expect(find.byType(TextField), findsNWidgets(2));
      await close(tester);
    });

    testWidgets('should sign out when the session ended elsewhere', (
      tester,
    ) async {
      final container = await open(tester);
      await signIn(tester);
      expect(find.text('Patient queue'), findsOneWidget);
      final service = await tester.runAsync(
        () => container.read(accessServiceProvider.future),
      );

      // Someone resets the password from a laptop.
      await tester.runAsync(() async {
        final start = await service!.startReset(
          username: 'desk',
          activationKey: licensed.token!,
          clientKey: 'laptop',
        );
        await service.finishReset(
          ticket: (start as ResetTicketIssued).ticket,
          newPassword: newPassword,
          clientKey: 'laptop',
        );
      });
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(tester);

      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byType(TextField), findsNWidgets(2));
      await close(tester);
    });
  });

  group('resetting a forgotten password on the tablet', () {
    testWidgets('should start with the username only', (tester) async {
      await open(tester);

      await openReset(tester);

      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.textContaining('Step 1 of 3'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      await close(tester);
    });

    testWidgets('should go on to the key without asking the tablet', (
      tester,
    ) async {
      await open(tester);
      await openReset(tester);

      // An unknown name goes on just as a real one does: nothing is revealed.
      await giveUsername(tester, name: 'nobody');

      expect(find.textContaining('Step 2 of 3'), findsOneWidget);
      expect(find.text('Confirm it is you'), findsOneWidget);
      await close(tester);
    });

    testWidgets('should ask for the username', (tester) async {
      await open(tester);
      await openReset(tester);

      await tapButton(tester, 'Continue');

      expect(find.text('Enter your username.'), findsOneWidget);
      expect(find.textContaining('Step 1 of 3'), findsOneWidget);
      await close(tester);
    });

    testWidgets('should ask for the key', (tester) async {
      await open(tester);
      await openReset(tester);
      await giveUsername(tester);

      await tapButton(tester, 'Continue');

      expect(find.text('Enter the activation key.'), findsOneWidget);
      await close(tester);
    });

    testWidgets('should refuse a wrong key and stay on that step', (
      tester,
    ) async {
      await open(tester);
      await openReset(tester);
      await giveUsername(tester);

      await giveKey(tester, key: 'WRONG-KEY');

      expect(
        find.text('The activation key or the username is not correct.'),
        findsOneWidget,
      );
      expect(find.textContaining('Step 2 of 3'), findsOneWidget);
      await close(tester);
    });

    testWidgets('should refuse an unknown name with the same words', (
      tester,
    ) async {
      await open(tester);
      await openReset(tester);
      await giveUsername(tester, name: 'nobody');

      await giveKey(tester);

      expect(
        find.text('The activation key or the username is not correct.'),
        findsOneWidget,
      );
      await close(tester);
    });

    testWidgets('should show the password step once the key is right', (
      tester,
    ) async {
      await open(tester);
      await openReset(tester);
      await giveUsername(tester);

      await giveKey(tester);

      expect(find.textContaining('Step 3 of 3'), findsOneWidget);
      expect(find.text('Choose a new password'), findsWidgets);
      expect(
        find.text('The key was accepted. Choose a new password for owner.'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNWidgets(2));
      await close(tester);
    });

    testWidgets('should reset the password, then sign in with it', (
      tester,
    ) async {
      await open(tester);
      await openReset(tester);
      await giveUsername(tester);
      await giveKey(tester);

      await givePassword(tester);

      expect(
        find.text('Password changed. Sign in with your new password.'),
        findsOneWidget,
      );
      await signIn(tester, user: 'owner', pass: newPassword);
      expect(find.text('Admin sign-in is on the web'), findsOneWidget);
      await close(tester);
    });

    testWidgets('should check the new password before using the ticket', (
      tester,
    ) async {
      await open(tester);
      await openReset(tester);
      await giveUsername(tester);
      await giveKey(tester);

      await givePassword(tester, pass: 'short', confirm: 'other');

      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      expect(find.text('Passwords do not match.'), findsOneWidget);
      expect(find.textContaining('Step 3 of 3'), findsOneWidget);
      await close(tester);
    });

    testWidgets('should go back a step and drop the key', (tester) async {
      await open(tester);
      await openReset(tester);
      await giveUsername(tester);
      await giveKey(tester);

      await tester.ensureVisible(find.text('Back'));
      await tester.tap(find.text('Back'));
      await settle(tester);

      expect(find.textContaining('Step 2 of 3'), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isEmpty);
      await close(tester);
    });

    testWidgets('should go back to sign-in from the first step', (
      tester,
    ) async {
      await open(tester);
      await openReset(tester);

      await tester.ensureVisible(find.text('Back to sign in'));
      await tester.tap(find.text('Back to sign in'));
      await settle(tester);

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Sign in'), findsWidgets);
      await close(tester);
    });
  });

  const screens = {
    'phone portrait': Size(360, 740),
    'phone landscape': Size(740, 360),
    'tablet portrait': Size(800, 1280),
    'tablet landscape': Size(1280, 800),
    'honor pad landscape': Size(893, 533),
    'honor pad portrait': Size(533, 893),
  };
  for (final MapEntry(key: name, value: size) in screens.entries) {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'should lay out sign-in and reset on $name, ${brightness.name}, text x$scale',
          (tester) async {
            await open(
              tester,
              size: size,
              brightness: brightness,
              textScale: scale,
            );
            expect(tester.takeException(), isNull);
            expect(find.byType(TextField), findsNWidgets(2));

            await openReset(tester);
            expect(tester.takeException(), isNull);
            expect(find.byType(TextField), findsOneWidget);

            await giveUsername(tester);
            expect(tester.takeException(), isNull);
            expect(find.textContaining('2'), findsWidgets);

            await giveKey(tester);
            expect(tester.takeException(), isNull);
            expect(find.byType(TextField), findsNWidgets(2));
            await close(tester);
          },
        );
      }
    }
  }

  // The test font is about 1.7 times wider than the real one, so this is a
  // pessimistic bound; the real tablet is checked by hand.
  testWidgets('should need very little scrolling on the Honor Pad', (
    tester,
  ) async {
    await open(tester, size: const Size(893, 533));

    final scrollable = find
        .descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    expect(
      tester.state<ScrollableState>(scrollable).position.maxScrollExtent,
      lessThanOrEqualTo(80),
    );
    await close(tester);
  });
}
