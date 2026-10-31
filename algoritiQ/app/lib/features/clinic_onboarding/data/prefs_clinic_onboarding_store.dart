// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/clinic_onboarding_store.dart';

/// Persists whether the clinic chose "start new" vs restore during onboarding.
final class PrefsClinicOnboardingStore implements ClinicOnboardingStore {
  const PrefsClinicOnboardingStore();

  static const _chosen = 'clinic.onboarding_chosen';

  @override
  Future<bool> isChosen() async =>
      (await SharedPreferences.getInstance()).getBool(_chosen) ?? false;

  @override
  Future<void> markStartNew() async {
    await (await SharedPreferences.getInstance()).setBool(_chosen, true);
  }
}
