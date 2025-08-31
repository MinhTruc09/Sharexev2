import '../dtos/notification_dto.dart';
import '../entities/notification.dart';

class NotificationMapper {
  static NotificationEntity fromDto(NotificationDto dto) {
    return NotificationEntity(
      id: dto.id,
      userEmail: dto.userEmail,
      title: dto.title,
      content: dto.content,
      type: _mapType(dto.type),
      referenceId: dto.referenceId,
      createdAt: dto.createdAt,
      read: dto.read,
    );
  }

  /// Convert từ Entity sang DTO
  static NotificationDto toDto(NotificationEntity entity) {
    return NotificationDto(
      id: entity.id,
      userEmail: entity.userEmail,
      title: entity.title,
      content: entity.content,
      type: _mapTypeToString(entity.type),
      referenceId: entity.referenceId,
      createdAt: entity.createdAt,
      read: entity.read,
    );
  }

  /// Map type từ String sang Entity enum
  static NotificationType _mapType(String type) {
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
        return NotificationType.system; // fallback
    }
  }

  /// Map type từ Entity enum sang String cho DTO
  static String _mapTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return 'booking';
      case NotificationType.ride:
        return 'ride';
      case NotificationType.payment:
        return 'payment';
      case NotificationType.system:
        return 'system';
      case NotificationType.promotion:
        return 'promotion';
    }
  }
}
