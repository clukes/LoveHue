import 'package:shared_preferences/shared_preferences.dart';

/// Service to store/retrieve data from shared preferences.
class SharedPreferencesService {
  final SharedPreferences preferences;

  SharedPreferencesService(this.preferences);

  /// Save an int [value] in shared preferences.
  Future<bool> setInt(String key, int value) async =>
      await preferences.setInt(key, value);

  /// Get an int [key] from shared preferences.
  int? getInt(String key) => preferences.getInt(key);
}
