import 'package:shared_preferences/shared_preferences.dart';

import '../domain/readiness_store.dart';

final class PrefsReadinessStore implements ReadinessStore {
  const PrefsReadinessStore();

  static const _acknowledged = 'readiness.acknowledged';
  static const _notificationsAsked = 'readiness.notifications_asked';

  Future<bool> _get(String key) async =>
      (await SharedPreferences.getInstance()).getBool(key) ?? false;

  Future<void> _set(String key) async {
    await (await SharedPreferences.getInstance()).setBool(key, true);
  }

  @override
  Future<bool> isAcknowledged() => _get(_acknowledged);

  @override
  Future<void> setAcknowledged() => _set(_acknowledged);

  @override
  Future<bool> notificationsAsked() => _get(_notificationsAsked);

  @override
  Future<void> setNotificationsAsked() => _set(_notificationsAsked);
}
