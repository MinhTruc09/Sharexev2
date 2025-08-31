import 'package:equatable/equatable.dart';

/// Business Entity cho Notification - dùng trong UI và business logic
class NotificationEntity extends Equatable {
  final int id;
  final String userEmail;
  final String title;
  final String content;
  final NotificationType type;
  final int referenceId;
  final DateTime createdAt;
  final bool read;

  const NotificationEntity({
    required this.id,
    required this.userEmail,
    required this.title,
    required this.content,
    required this.type,
    required this.referenceId,
    required this.createdAt,
    required this.read,
  });

  @override
  List<Object?> get props => [
        id,
        userEmail,
        title,
        content,
        type,
        referenceId,
        createdAt,
        read,
      ];

  /// Business methods
  bool get isUnread => !read;
  String get typeDisplayName => type.displayName;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  NotificationEntity copyWith({
    int? id,
    String? userEmail,
    String? title,
    String? content,
    NotificationType? type,
    int? referenceId,
    DateTime? createdAt,
    bool? read,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userEmail: userEmail ?? this.userEmail,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}

enum NotificationType {
  booking,
  ride,
  payment,
  system,
  promotion;

  String get displayName {
    switch (this) {
      case NotificationType.booking:
        return 'Đặt chỗ';
      case NotificationType.ride:
        return 'Chuyến đi';
      case NotificationType.payment:
        return 'Thanh toán';
      case NotificationType.system:
        return 'Hệ thống';
      case NotificationType.promotion:
        return 'Khuyến mãi';
    }
  }

  static NotificationType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return NotificationType.booking;
      case 'ride':
        return NotificationType.ride;
      case 'payment':
        return NotificationType.payment;
      case 'system':
        return NotificationType.system;
      case 'promotion':
        return NotificationType.promotion;
      default:
        return NotificationType.system;
    }
  }
}
