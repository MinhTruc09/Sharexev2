part of 'notification_cubit.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState {
  final NotificationStatus status;
  final String? error;
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.error,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    String? error,
    List<NotificationEntity>? notifications,
    int? unreadCount,
  }) {
    return NotificationState(
      status: status ?? this.status,
      error: error,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  /// Get notifications by type
  List<NotificationEntity> getNotificationsByType(String type) {
    return notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<NotificationEntity> get unreadNotifications {
    return notifications.where((n) => !n.isRead).toList();
  }

  /// Get read notifications
  List<NotificationEntity> get readNotifications {
    return notifications.where((n) => n.isRead).toList();
  }

  /// Get recent notifications (last 24 hours)
  List<NotificationEntity> get recentNotifications {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return notifications.where((n) => n.createdAt.isAfter(yesterday)).toList();
  }

  /// Check if has unread notifications
  bool get hasUnreadNotifications => unreadCount > 0;

  /// Get notification by ID
  NotificationEntity? getNotificationById(int id) {
    try {
      return notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get notifications count by type
  int getNotificationCountByType(String type) {
    return notifications.where((n) => n.type == type).length;
  }

  /// Get unread count by type
  int getUnreadCountByType(String type) {
    return notifications.where((n) => n.type == type && !n.isRead).length;
  }

  /// Check if notification exists
  bool hasNotification(int id) {
    return notifications.any((n) => n.id == id);
  }

  /// Get notifications sorted by date (newest first)
  List<NotificationEntity> get sortedNotifications {
    final sorted = List<NotificationEntity>.from(notifications);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Get notifications sorted by unread first
  List<NotificationEntity> get sortedByUnread {
    final sorted = List<NotificationEntity>.from(notifications);
    sorted.sort((a, b) {
      if (a.isRead == b.isRead) {
        return b.createdAt.compareTo(a.createdAt);
      }
      return a.isRead ? 1 : -1;
    });
    return sorted;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationState &&
        other.status == status &&
        other.error == error &&
        other.notifications == notifications &&
        other.unreadCount == unreadCount;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        error.hashCode ^
        notifications.hashCode ^
        unreadCount.hashCode;
  }

  @override
  String toString() {
    return 'NotificationState(status: $status, error: $error, notifications: ${notifications.length}, unreadCount: $unreadCount)';
  }
}
