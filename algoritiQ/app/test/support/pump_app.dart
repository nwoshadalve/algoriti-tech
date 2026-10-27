import 'package:algoritiq_app/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// Runs the whole app with [overrides] and lets it settle.
///
/// The providers are disposed in a tear-down, outside the test's fake clock,
/// so the database's stream clean-up timers are not reported as pending.
Future<void> pumpApp(WidgetTester tester, List<Override> overrides) async {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const AlgoritiqApp(),
    ),
  );
  await tester.pumpAndSettle();
}
