import 'package:intl/intl.dart';

/// Date formatting utilities using id_ID locale.
class AppDateFormat {
  AppDateFormat._();

  /// Example: "25 Oktober 2026"
  static String formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  /// Example: "25 Okt 2026"
  static String formatDateShort(DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  /// Example: "25 Okt 2026, 14:30"
  static String formatDateTime(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  /// Example: "Oktober 2026"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }
}
