/// Notification Entity - Data model cho thông báo
class NotificationEntity {
  final int id;
  final String title;
  final String message;
  final String type; // 'booking', 'ride', 'system', 'promotion'
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.data,
  });

  /// Create a copy with updated fields
  NotificationEntity copyWith({
    int? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  /// Get notification type display name
  String get typeDisplayName {
    switch (type) {
      case 'booking':
        return 'Đặt chuyến';
      case 'ride':
        return 'Chuyến đi';
      case 'system':
        return 'Hệ thống';
      case 'promotion':
        return 'Khuyến mãi';
      default:
        return 'Thông báo';
    }
  }

  /// Get notification type color
  String get typeColor {
    switch (type) {
      case 'booking':
        return 'info';
      case 'ride':
        return 'success';
      case 'system':
        return 'warning';
      case 'promotion':
        return 'primary';
      default:
        return 'secondary';
    }
  }

  /// Get notification priority
  int get priority {
    switch (type) {
      case 'booking':
        return 3; // High priority
      case 'ride':
        return 2; // Medium priority
      case 'system':
        return 1; // Low priority
      case 'promotion':
        return 0; // Lowest priority
      default:
        return 1;
    }
  }

  /// Check if notification is recent (within last hour)
  bool get isRecent {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    return createdAt.isAfter(oneHourAgo);
  }

  /// Check if notification is today
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
           createdAt.month == now.month &&
           createdAt.day == now.day;
  }

  /// Check if notification is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return createdAt.isAfter(weekAgo);
  }

  /// Get formatted creation time
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Get short formatted time
  String get shortTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${createdAt.day}/${createdAt.month}';
    }
  }

  /// Get notification icon
  String get icon {
    switch (type) {
      case 'booking':
        return 'assignment';
      case 'ride':
        return 'directions_car';
      case 'system':
        return 'settings';
      case 'promotion':
        return 'local_offer';
      default:
        return 'notifications';
    }
  }

  /// Get notification action text
  String get actionText {
    switch (type) {
      case 'booking':
        return 'Xem chi tiết';
      case 'ride':
        return 'Theo dõi chuyến';
      case 'system':
        return 'Tìm hiểu thêm';
      case 'promotion':
        return 'Sử dụng ngay';
      default:
        return 'Xem thêm';
    }
  }

  /// Check if notification has action
  bool get hasAction {
    return type != 'system' || data.containsKey('actionUrl');
  }

  /// Get action URL if available
  String? get actionUrl {
    return data['actionUrl'] as String?;
  }

  /// Get notification data by key
  T? getData<T>(String key) {
    return data[key] as T?;
  }

  /// Check if notification has specific data key
  bool hasData(String key) {
    return data.containsKey(key);
  }

  /// Get notification summary (first 50 characters)
  String get summary {
    if (message.length <= 50) {
      return message;
    }
    return '${message.substring(0, 50)}...';
  }

  /// Get notification title with priority indicator
  String get titleWithPriority {
    if (priority >= 3) {
      return '🔔 $title';
    } else if (priority >= 2) {
      return '📢 $title';
    } else {
      return title;
    }
  }

  /// Check if notification is urgent
  bool get isUrgent {
    return priority >= 3 && !isRead;
  }

  /// Check if notification is important
  bool get isImportant {
    return priority >= 2 && !isRead;
  }

  /// Get notification age in minutes
  int get ageInMinutes {
    final now = DateTime.now();
    return now.difference(createdAt).inMinutes;
  }

  /// Get notification age in hours
  int get ageInHours {
    final now = DateTime.now();
    return now.difference(createdAt).inHours;
  }

  /// Get notification age in days
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationEntity &&
        other.id == id &&
        other.title == title &&
        other.message == message &&
        other.type == type &&
        other.isRead == isRead &&
        other.createdAt == createdAt &&
        other.data == data;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        message.hashCode ^
        type.hashCode ^
        isRead.hashCode ^
        createdAt.hashCode ^
        data.hashCode;
  }

  @override
  String toString() {
    return 'NotificationEntity(id: $id, title: $title, type: $type, isRead: $isRead, createdAt: $createdAt)';
  }
}
