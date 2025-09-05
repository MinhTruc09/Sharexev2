import '../dtos/notification_dto.dart';
import '../entities/notification_entity.dart';

/// Mapper để convert giữa NotificationDto và NotificationEntity
class NotificationMapper {
  /// Convert từ DTO sang Entity
  static NotificationEntity fromDto(NotificationDto dto) {
    return NotificationEntity(
      id: dto.id,
      title: dto.title,
      message: dto.content,
      type: dto.type,
      isRead: dto.read,
      createdAt: dto.createdAt,
      data: {
        'userEmail': dto.userEmail,
        'referenceId': dto.referenceId,
      },
    );
  }

  /// Convert từ Entity sang DTO
  static NotificationDto toDto(NotificationEntity entity) {
    return NotificationDto(
      id: entity.id,
      userEmail: entity.data['userEmail'] ?? '',
      title: entity.title,
      content: entity.message,
      type: entity.type,
      referenceId: entity.data['referenceId'] ?? 0,
      createdAt: entity.createdAt,
      read: entity.isRead,
    );
  }

  /// Convert list từ DTO sang Entity
  static List<NotificationEntity> fromDtoList(List<NotificationDto> dtoList) {
    return dtoList.map((dto) => fromDto(dto)).toList();
  }

  /// Convert list từ Entity sang DTO
  static List<NotificationDto> toDtoList(List<NotificationEntity> entityList) {
    return entityList.map((entity) => toDto(entity)).toList();
  }

  /// Map notification type từ string sang enum (if needed)
  static String _mapNotificationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'booking':
        return 'booking';
      case 'ride':
        return 'ride';
      case 'payment':
        return 'payment';
      case 'system':
        return 'system';
      case 'promotion':
        return 'promotion';
      default:
        return 'system';
    }
  }

  /// Map notification type từ enum sang string (if needed)
  static String _mapNotificationTypeToString(String type) {
    return type;
  }
}