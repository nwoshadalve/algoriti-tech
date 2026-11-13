// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/features/fee_codes/application/fee_code_service.dart';
import 'package:algoritiq_app/features/fee_codes/domain/fee_code.dart';
import 'package:algoritiq_app/features/queue_board/presentation/queue_desk_fee_field.dart';
import 'package:algoritiq_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _codes = [
  FeeCode(id: 'a', code: 'NEW', amountBdt: 500),
  FeeCode(id: 'b', code: 'FOLLOW', amountBdt: 300),
];

Future<void> _pump(
  WidgetTester tester,
  TextEditingController controller, {
  required List<FeeCode> codes,
}) async {
  tester.view.physicalSize = const Size(900, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [feeCodesProvider.overrideWith((ref) async => codes)],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: DeskFeeField(controller: controller, enabled: true),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should be the free field while no codes are defined', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await _pump(tester, controller, codes: const []);
    await tester.enterText(find.byType(TextField), '450');

    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(controller.text, '450');
  });

  testWidgets('should start as "No fee" when codes exist', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await _pump(tester, controller, codes: _codes);

    expect(find.byType(TextField), findsNothing);
    expect(find.text('No fee'), findsOneWidget);
    expect(controller.text, isEmpty);
  });

  testWidgets('should put the amount of the chosen code in the form', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await _pump(tester, controller, codes: _codes);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NEW — 500').last);
    await tester.pumpAndSettle();

    expect(controller.text, '500');
    expect(find.text('NEW — 500'), findsOneWidget);
  });

  testWidgets('should clear the fee when "No fee" is chosen again', (
    tester,
  ) async {
    final controller = TextEditingController(text: '300');
    addTearDown(controller.dispose);
    await _pump(tester, controller, codes: _codes);
    expect(find.text('FOLLOW — 300'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No fee').last);
    await tester.pumpAndSettle();

    expect(controller.text, isEmpty);
  });

  testWidgets('should keep a fee that matches no code', (tester) async {
    final controller = TextEditingController(text: '725');
    addTearDown(controller.dispose);

    await _pump(tester, controller, codes: _codes);

    expect(find.text('725'), findsOneWidget);
    expect(controller.text, '725');
  });
}
