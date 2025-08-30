import '../dtos/chat_message_dto.dart';
import '../entities/chat_message.dart';

class ChatMessageMapper {
  static ChatMessage fromDto(ChatMessageDTO dto) {
    return ChatMessage(
      messageId: dto.messageId,
      senderEmail: dto.senderEmail,
      receiverEmail: dto.receiverEmail,
      senderName: dto.senderName,
      content: dto.content,
      roomId: dto.roomId,
      timestamp: DateTime.tryParse(dto.timestamp) ?? DateTime.now(),
      read: dto.read,
    );
  }

  static ChatMessageDTO toDto(ChatMessage entity) {
    return ChatMessageDTO(
      messageId: entity.messageId,
      senderEmail: entity.senderEmail,
      receiverEmail: entity.receiverEmail,
      senderName: entity.senderName,
      content: entity.content,
      roomId: entity.roomId,
      timestamp: entity.timestamp.toIso8601String(),
      read: entity.read,
    );
  }
}
