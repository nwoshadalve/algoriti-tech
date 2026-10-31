// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/server_host.dart';
import '../core/l10n/locale_controller.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../core/toast/toast_host.dart';
import '../features/access/presentation/admin_gate.dart';
import '../features/access/presentation/sign_in_gate.dart';
import '../features/clinic/presentation/setup_gate.dart';
import '../features/clinic_onboarding/presentation/clinic_data_gate.dart';
import '../features/home/presentation/receptionist_work_gate.dart';
import '../features/home/presentation/home_page.dart';
import '../features/readiness/presentation/readiness_gate.dart';
import '../features/licensing/presentation/license_gate.dart';
import '../l10n/app_localizations.dart';

/// The opening screen is the native launch screen only (animated wordmark,
/// see `tool/splash_wordmark/`). Then the license gate: activation screen on an
/// unlicensed device, otherwise [HomePage].
class AlgoritiqApp extends ConsumerWidget {
  const AlgoritiqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AlgoritiQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeControllerProvider),
      locale: ref.watch(localeControllerProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => ToastHost(child: child),
      home: const LicenseGate(
        child: ReadinessGate(
          child: ClinicDataGate(
            child: SetupGate(
              child: ServerHost(
                child: AdminGate(
                  child: SignInGate(
                    child: ReceptionistWorkGate(child: HomePage()),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
