import '../dtos/chat_room_dto.dart';
import '../entities/chat_room.dart';

class ChatRoomMapper {
  static ChatRoom fromDto(ChatRoomDTO dto) {
    return ChatRoom(
      roomId: dto.id,
      participantName: dto.participantName,
      participantEmail: dto.participantEmail,
      lastMessage: dto.lastMessage,
      lastMessageTime:
          dto.lastMessageTime != null
              ? DateTime.tryParse(dto.lastMessageTime!)
              : null,
      unreadCount: dto.unreadCount,
    );
  }

  static ChatRoomDTO toDto(ChatRoom entity) {
    return ChatRoomDTO(
      id: entity.roomId,
      participantName: entity.participantName,
      participantEmail: entity.participantEmail,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime?.toIso8601String(),
      unreadCount: entity.unreadCount,
    );
  }
}
