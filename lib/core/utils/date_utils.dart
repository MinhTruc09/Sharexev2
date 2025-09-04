import 'package:intl/intl.dart';

class DateUtils {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  /// Format date for display (dd/MM/yyyy)
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format time for display (HH:mm)
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format date and time for display (dd/MM/yyyy HH:mm)
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Format date for API (yyyy-MM-dd)
  static String formatDateForApi(DateTime date) {
    return _apiDateFormat.format(date);
  }

  /// Parse date from API format
  static DateTime? parseDateFromApi(String dateString) {
    try {
      return _apiDateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get relative time (e.g., "2 giờ trước")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Get day name in Vietnamese
  static String getDayName(DateTime date) {
    const dayNames = [
      'Chủ nhật',
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
    ];
    return dayNames[date.weekday % 7];
  }

  /// Get smart date display (Today, Tomorrow, or date)
  static String getSmartDateDisplay(DateTime date) {
    if (isToday(date)) {
      return 'Hôm nay';
    } else if (isTomorrow(date)) {
      return 'Ngày mai';
    } else {
      return formatDate(date);
    }
  }
}
