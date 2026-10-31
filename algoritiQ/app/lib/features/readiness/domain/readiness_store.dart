// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
/// Remembers what the user told the readiness guide.
abstract interface class ReadinessStore {
  /// The user has seen the guide and chosen to go on.
  Future<bool> isAcknowledged();

  Future<void> setAcknowledged();

  /// The notification dialog was already shown once (after two refusals
  /// Android no longer shows it; the settings page is the only way).
  Future<bool> notificationsAsked();

  Future<void> setNotificationsAsked();

  /// The Bluetooth connect dialog was already shown once (after a refusal the
  /// app settings page is the only way).
  Future<bool> bluetoothAsked();

  Future<void> setBluetoothAsked();
}
