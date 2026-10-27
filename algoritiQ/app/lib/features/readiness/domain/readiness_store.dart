/// Remembers what the user told the readiness guide.
abstract interface class ReadinessStore {
  /// The user has seen the guide and chosen to go on.
  Future<bool> isAcknowledged();

  Future<void> setAcknowledged();

  /// The notification dialog was already shown once (after two refusals
  /// Android no longer shows it; the settings page is the only way).
  Future<bool> notificationsAsked();

  Future<void> setNotificationsAsked();
}
