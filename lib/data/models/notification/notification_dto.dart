import 'package:sharexev2/core/utils/date_time_ext.dart';

class NotificationDto {
  final int id;
  final String userEmail;
  final String title;
  final String content;
  final String type;
  final int referenceId;
  final DateTime createdAt;
  final bool read;

  NotificationDto({
    required this.id,
    required this.userEmail,
    required this.title,
    required this.content,
    required this.type,
    required this.referenceId,
    required this.createdAt,
    required this.read,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] ?? 0,
      userEmail: json['userEmail'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      referenceId: json['referenceId'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userEmail": userEmail,
      "title": title,
      "content": content,
      "type": type,
      "referenceId": referenceId,
      "createdAt": createdAt.toIso8601String(),
      "read": read,
    };
  }

  /// Getter hiển thị thời gian đẹp (dùng extension)
  String get formattedTime => createdAt.timeAgo;
}

// final noti = NotificationDto.fromJson(json);
// print(noti.formattedTime); /
// syntax gọi hàm thời gian
