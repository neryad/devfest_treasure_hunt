/// Minimal key/value storage abstraction.
///
/// The demo uses SharedPreferences behind this interface, but `AppDataSource`
/// only ever talks to [AppLocalStorage], so swapping to another store (or
/// removing persistence entirely) never touches business logic.
abstract class AppLocalStorage {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> remove(String key);
}