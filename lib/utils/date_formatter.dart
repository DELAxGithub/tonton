import 'package:intl/intl.dart';

/// A utility class for formatting dates
class DateFormatter {
  /// Formats a date in a user-friendly format like 'Jan 1, 2023'
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Formats a date in a format like 'Jan 1, 2023, 3:30 PM'
  static String formatDateTime(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  /// Formats a time in a format like '3:30 PM'
  static String formatTime(DateTime date) {
    return DateFormat.jm().format(date);
  }

  /// Formats a date as a weekday like 'Monday'
  static String formatWeekday(DateTime date) {
    return DateFormat.EEEE().format(date);
  }

  /// Formats a date as month/day in Japanese format like '12/31'
  static String formatMonthDay(DateTime date) {
    return DateFormat('M/d').format(date);
  }

  /// Formats a date as Japanese weekday like '月曜日'
  static String formatWeekdayJa(DateTime date) {
    final weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    return '${weekdays[date.weekday % 7]}曜日';
  }

  /// Formats a date in long format like '2023年12月31日 (土)'
  static String formatLongDate(DateTime date) {
    final weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    final weekday = weekdays[date.weekday % 7];
    return DateFormat('yyyy年M月d日').format(date) + ' ($weekday)';
  }
}
