import 'package:intl/intl.dart';

class TimezoneHelper {
  // Offset dari UTC dalam jam
  static Map<String, int> timezoneOffsets = {
    'Asia/Jakarta': 7, // WIB (UTC+7)
    'Asia/Makassar': 8, // WITA (UTC+8)
    'Asia/Jayapura': 9, // WIT (UTC+9)
    'America/New_York': -5, // EST (UTC-5)
    'Europe/London': 0, // GMT (UTC+0)
  };

  static Map<String, String> timezoneLabels = {
    'Asia/Jakarta': 'WIB',
    'Asia/Makassar': 'WITA',
    'Asia/Jayapura': 'WIT',
    'America/New_York': 'EST',
    'Europe/London': 'GMT',
  };

  // Konversi waktu dari WIB (default) ke timezone target
  static String convertTime(String timeString, String targetTimezone) {
    try {
      // Parse time string (format: "08:00-10:00")
      final times = timeString.split('-');
      if (times.length != 2) return timeString;

      final startParts = times[0].trim().split(':');
      final endParts = times[1].trim().split(':');

      if (startParts.length != 2 || endParts.length != 2) return timeString;

      int startHour = int.parse(startParts[0]);
      int endHour = int.parse(endParts[0]);

      // Offset difference (dari WIB ke target timezone)
      final wibOffset = timezoneOffsets['Asia/Jakarta'] ?? 7;
      final targetOffset = timezoneOffsets[targetTimezone] ?? 7;
      final difference = targetOffset - wibOffset;

      // Konversi jam
      startHour = (startHour + difference) % 24;
      endHour = (endHour + difference) % 24;

      // Format kembali
      final label = timezoneLabels[targetTimezone] ?? '';
      return '${startHour.toString().padLeft(2, '0')}:${startParts[1]} - ${endHour.toString().padLeft(2, '0')}:${endParts[1]} $label';
    } catch (e) {
      return timeString;
    }
  }

  static String getCurrentTimeInTimezone(String timezone) {
    final utcNow = DateTime.now().toUtc();
    final offset = timezoneOffsets[timezone] ?? 7;
    final localTime = utcNow.add(Duration(hours: offset));
    final label = timezoneLabels[timezone] ?? '';
    return '${DateFormat('HH:mm').format(localTime)} $label';
  }

  static String getTimezoneLabel(String timezone) {
    return timezoneLabels[timezone] ?? '';
  }
}
