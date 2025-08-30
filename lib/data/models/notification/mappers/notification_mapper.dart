import '../notification_dto.dart';
import '../notification.dart';

class NotificationMapper {
  static Notification fromDto(NotificationDto dto) {
    return Notification(
      id: dto.id,
      userEmail: dto.userEmail,
      title: dto.title,
      content: dto.content,
      type: dto.type,
      referenceId: dto.referenceId,
      createdAt: dto.createdAt,
      read: dto.read,
    );
  }
}
