import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final SharedPreferences preferences;

  SharedPreferencesService(this.preferences);

  void setInt(String key, int value) async =>
      await preferences.setInt(key, value);

  int? getInt(String key) => preferences.getInt(key);
}
