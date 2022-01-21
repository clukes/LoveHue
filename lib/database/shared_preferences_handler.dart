import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHandler {
  static final SharedPreferencesHandler _instance =
      SharedPreferencesHandler._internal();

  factory SharedPreferencesHandler() => _instance;
  SharedPreferencesHandler._internal();
  static SharedPreferencesHandler getInstance() => _instance;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  get prefs async => await _prefs;
}
