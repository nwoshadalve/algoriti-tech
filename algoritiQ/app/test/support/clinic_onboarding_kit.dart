// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/features/clinic_onboarding/domain/clinic_onboarding_store.dart';

class MemoryClinicOnboardingStore implements ClinicOnboardingStore {
  MemoryClinicOnboardingStore({this.chosen = true});

  bool chosen;

  @override
  Future<bool> isChosen() async => chosen;

  @override
  Future<void> markStartNew() async => chosen = true;
}
