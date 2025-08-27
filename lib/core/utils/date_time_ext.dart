extension DateTimeExt on DateTime {
  /// Format đơn giản: "HH:mm" nếu hôm nay, còn lại "dd/MM/yyyy"
  String get short {
    final now = DateTime.now();
    if (isSameDay(now)) {
      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    }
    return "$day/$month/$year";
  }

  /// Kiểm tra có cùng ngày không
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Hôm nay?
  bool get isToday => isSameDay(DateTime.now());

  /// Hôm qua?
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Ngày mai?
  bool get isTomorrow => isSameDay(DateTime.now().add(const Duration(days: 1)));

  /// Time ago: "5m ago", "2h ago", "3d ago"
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return "${difference.inSeconds}s ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return "$day/$month/$year";
    }
  }
}
