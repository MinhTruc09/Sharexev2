import 'package:sharexev2/data/models/chat/chat_message.dart';
import 'package:sharexev2/data/models/chat/chat_room.dart';

enum ChatStatus { initial, loading, loaded, sending, error }

class ChatState {
  final ChatStatus status;
  final String? error;
  final List<ChatMessage> messages;
  final String? currentRoomId;
  final bool isConnected;
  final bool isTyping;
  final String? typingUser;
  final List<ChatRoom> chatRooms;
  final int unreadCount;

  const ChatState({
    this.status = ChatStatus.initial,
    this.error,
    this.messages = const [],
    this.currentRoomId,
    this.isConnected = false,
    this.isTyping = false,
    this.typingUser,
    this.chatRooms = const [],
    this.unreadCount = 0,
  });

  ChatState copyWith({
    ChatStatus? status,
    String? error,
    List<ChatMessage>? messages,
    String? currentRoomId,
    bool? isConnected,
    bool? isTyping,
    String? typingUser,
    List<ChatRoom>? chatRooms,
    int? unreadCount,
  }) {
    return ChatState(
      status: status ?? this.status,
      error: error,
      messages: messages ?? this.messages,
      currentRoomId: currentRoomId ?? this.currentRoomId,
      isConnected: isConnected ?? this.isConnected,
      isTyping: isTyping ?? this.isTyping,
      typingUser: typingUser ?? this.typingUser,
      chatRooms: chatRooms ?? this.chatRooms,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  // Helper getters
  List<ChatMessage> get sortedMessages {
    final sorted = List<ChatMessage>.from(messages);
    sorted.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sorted;
  }

  ChatMessage? get lastMessage {
    if (messages.isEmpty) return null;
    return sortedMessages.last;
  }

  int get unreadMessagesCount {
    return messages.where((msg) => !msg.read && !msg.isFromMe).length;
  }

  bool get hasMessages => messages.isNotEmpty;
}
