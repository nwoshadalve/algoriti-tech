import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/core/widgets/brand_loader.dart';
import 'package:algoritiq_app/core/widgets/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({required bool isLoading, required VoidCallback onPressed}) =>
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: LoadingButton(
            label: 'Save',
            loadingLabel: 'Saving…',
            isLoading: isLoading,
            onPressed: onPressed,
          ),
        ),
      );

  testWidgets('should call onPressed when idle', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(isLoading: false, onPressed: () => taps++));

    await tester.tap(find.text('Save'));

    expect(taps, 1);
    expect(find.byType(BrandLoader), findsNothing);
  });

  testWidgets('should show the loader and ignore taps while loading', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(host(isLoading: true, onPressed: () => taps++));

    await tester.tap(find.byType(FilledButton));

    expect(taps, 0);
    expect(find.byType(BrandLoader), findsOneWidget);
    expect(find.bySemanticsLabel('Saving…'), findsOneWidget);
  });

  testWidgets('should keep its size while loading', (tester) async {
    await tester.pumpWidget(host(isLoading: false, onPressed: () {}));
    final idle = tester.getSize(find.byType(FilledButton));

    await tester.pumpWidget(host(isLoading: true, onPressed: () {}));

    expect(tester.getSize(find.byType(FilledButton)), idle);
  });
}
