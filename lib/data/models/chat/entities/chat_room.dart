// lib/data/models/chat/entities/chat_room.dart
class ChatRoom {
  final String roomId;
  final String participantName;
  final String participantEmail;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatRoom({
    required this.roomId,
    required this.participantName,
    required this.participantEmail,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  /// UI helper: fallback khi chưa có tin nhắn
  String get displayLastMessage =>
      lastMessage.isEmpty ? "Chưa có tin nhắn" : lastMessage;

  /// UI helper: format thời gian
  String get displayTime {
    if (lastMessageTime == null) return "";
    return "${lastMessageTime!.hour}:${lastMessageTime!.minute.toString().padLeft(2, '0')}";
  }
}
