import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  /// Formats a date for user display (dd/MM/yyyy).
  static String formatForDisplay(DateTime date) {
    return _displayFormat.format(date);
  }

  /// Formats a date for API submission (yyyy-MM-dd).
  static String formatForApi(DateTime date) {
    return _apiFormat.format(date);
  }

  /// Parses a date string in dd/MM/yyyy format.
  static DateTime? parseDisplayDate(String dateString) {
    try {
      return _displayFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parses a date string in yyyy-MM-dd format.
  static DateTime? parseApiDate(String dateString) {
    try {
      return _apiFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
