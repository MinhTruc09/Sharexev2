import '../dtos/chat_message_dto.dart';
import '../entities/chat_message_entity.dart';

/// ChatMessageMapper - Chuyển đổi giữa DTO và Entity
class ChatMessageMapper {
  /// Chuyển từ DTO sang Entity
  static ChatMessageEntity fromDto(ChatMessageDto dto) {
    return ChatMessageEntity(
      senderEmail: dto.senderEmail,
      receiverEmail: dto.receiverEmail,
      senderName: dto.senderName,
      content: dto.content,
      roomId: dto.roomId,
      timestamp: dto.timestamp,
      read: dto.read,
    );
  }

  /// Chuyển từ Entity sang DTO
  static ChatMessageDto toDto(ChatMessageEntity entity) {
    return ChatMessageDto(
      token: '', // ChatMessageEntity doesn't have token
      senderEmail: entity.senderEmail,
      receiverEmail: entity.receiverEmail,
      senderName: entity.senderName,
      content: entity.content,
      roomId: entity.roomId,
      timestamp: entity.timestamp,
      read: entity.read,
    );
  }

  /// Chuyển danh sách DTO sang danh sách Entity
  static List<ChatMessageEntity> fromDtoList(List<ChatMessageDto> dtoList) {
    return dtoList.map((dto) => fromDto(dto)).toList();
  }

  /// Chuyển danh sách Entity sang danh sách DTO
  static List<ChatMessageDto> toDtoList(List<ChatMessageEntity> entityList) {
    return entityList.map((entity) => toDto(entity)).toList();
  }
}
