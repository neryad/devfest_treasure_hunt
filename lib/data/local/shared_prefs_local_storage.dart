import 'package:shared_preferences/shared_preferences.dart';

import 'app_local_storage.dart';

/// [AppLocalStorage] backed by SharedPreferences.
///
/// This is the only file in the project that knows about SharedPreferences.
class SharedPrefsLocalStorage implements AppLocalStorage {
  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}