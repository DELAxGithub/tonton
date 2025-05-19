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
}