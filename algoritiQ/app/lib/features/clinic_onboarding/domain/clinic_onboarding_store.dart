// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
/// Whether the user chose restore or start new after activation.
abstract interface class ClinicOnboardingStore {
  Future<bool> isChosen();

  Future<void> markStartNew();
}
