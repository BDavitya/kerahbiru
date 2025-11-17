import 'package:shared_preferences/shared_preferences.dart';

// ✅ SIMPLIFIED: Only use SharedPreferences (no need separate database)
class UserPreferences {
  // Keys
  static const String _keyUserId = 'user_id';
  static const String _keyCurrency = 'preferred_currency';
  static const String _keyTimezone = 'preferred_timezone';

  // Get User ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  // Set User ID
  static Future<void> setUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  // ✅ Currency Methods
  static Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, currency);
    print('💰 Set currency: $currency');
  }

  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final currency = prefs.getString(_keyCurrency) ?? 'IDR';
    print('💰 Get currency: $currency');
    return currency;
  }

  // ✅ Timezone Methods
  static Future<void> setTimezone(String timezone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTimezone, timezone);
    print('⏰ Set timezone: $timezone');
  }

  static Future<String> getTimezone() async {
    final prefs = await SharedPreferences.getInstance();
    final timezone = prefs.getString(_keyTimezone) ?? 'Asia/Jakarta';
    print('⏰ Get timezone: $timezone');
    return timezone;
  }

  // ✅ Set Both (for API sync)
  static Future<void> setPreferences({
    String? currency,
    String? timezone,
  }) async {
    if (currency != null) await setCurrency(currency);
    if (timezone != null) await setTimezone(timezone);
  }

  // ✅ Clear all preferences
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrency);
    await prefs.remove(_keyTimezone);
    print('🗑️ Cleared preferences');
  }
}
