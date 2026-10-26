/// Persists the language the user picked.
abstract interface class LocaleStore {
  /// The saved language code (`bn`, `en`), or null if none was saved.
  Future<String?> read();

  Future<void> write(String languageCode);
}
