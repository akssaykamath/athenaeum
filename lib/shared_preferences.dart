import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  static SharedPreferences? _sharedPreferences;

  static Future init() async =>
      _sharedPreferences = await SharedPreferences.getInstance();

  static Future writeString(
          {required String key, required String value}) async =>
      await _sharedPreferences!.setString(key, value);

  static String readString({required String key}) =>
      _sharedPreferences!.getString(key) ?? "";

  static Future writeInt({required String key, required int value}) async =>
      await _sharedPreferences!.setInt(key, value);

  static int readInt({required String key}) =>
      _sharedPreferences!.getInt(key) ?? -1;
}
