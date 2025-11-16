import 'package:shared_preferences/shared_preferences.dart';
import 'preferences_database.dart';

class UserPreferences {
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<void> setCurrency(String currency) async {
    final userId = await getUserId();
    if (userId != null) {
      await PreferencesDatabase.setCurrency(userId, currency);
    }
  }

  static Future<String> getCurrency() async {
    final userId = await getUserId();
    if (userId != null) {
      return await PreferencesDatabase.getCurrency(userId);
    }
    return 'IDR';
  }

  static Future<void> setTimezone(String timezone) async {
    final userId = await getUserId();
    if (userId != null) {
      await PreferencesDatabase.setTimezone(userId, timezone);
    }
  }

  static Future<String> getTimezone() async {
    final userId = await getUserId();
    if (userId != null) {
      return await PreferencesDatabase.getTimezone(userId);
    }
    return 'Asia/Jakarta';
  }
}
