import 'package:equatable/equatable.dart';

/// Business Entity cho Chat Message - dùng trong UI và business logic
class ChatMessageEntity extends Equatable {
  final String senderEmail;
  final String receiverEmail;
  final String senderName;
  final String content;
  final String roomId;
  final DateTime timestamp;
  final bool read;

  const ChatMessageEntity({
    required this.senderEmail,
    required this.receiverEmail,
    required this.senderName,
    required this.content,
    required this.roomId,
    required this.timestamp,
    required this.read,
  });

  @override
  List<Object?> get props => [
        senderEmail,
        receiverEmail,
        senderName,
        content,
        roomId,
        timestamp,
        read,
      ];

  /// Business methods
  bool get isUnread => !read;
  
  bool isSentBy(String userEmail) => senderEmail == userEmail;
  bool isReceivedBy(String userEmail) => receiverEmail == userEmail;
  
  String get timeFormatted {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
  
  String get senderInitials {
    final names = senderName.split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    return senderName.isNotEmpty ? senderName[0].toUpperCase() : 'U';
  }

  ChatMessageEntity copyWith({
    String? senderEmail,
    String? receiverEmail,
    String? senderName,
    String? content,
    String? roomId,
    DateTime? timestamp,
    bool? read,
  }) {
    return ChatMessageEntity(
      senderEmail: senderEmail ?? this.senderEmail,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      roomId: roomId ?? this.roomId,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
    );
  }
}

/// Business Entity cho Chat Room
class ChatRoomEntity extends Equatable {
  final String id;
  final String otherUserEmail;
  final String otherUserName;
  final String? otherUserAvatar;
  final ChatMessageEntity? lastMessage;
  final int unreadCount;

  const ChatRoomEntity({
    required this.id,
    required this.otherUserEmail,
    required this.otherUserName,
    this.otherUserAvatar,
    this.lastMessage,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [
        id,
        otherUserEmail,
        otherUserName,
        otherUserAvatar,
        lastMessage,
        unreadCount,
      ];

  /// Business methods
  bool get hasUnreadMessages => unreadCount > 0;
  bool get hasLastMessage => lastMessage != null;
  
  String get displayName => otherUserName.isNotEmpty ? otherUserName : otherUserEmail;
  
  String get lastMessagePreview {
    if (lastMessage == null) return 'Chưa có tin nhắn';
    
    final content = lastMessage!.content;
    if (content.length > 50) {
      return '${content.substring(0, 50)}...';
    }
    return content;
  }
  
  String get lastMessageTime {
    if (lastMessage == null) return '';
    return lastMessage!.timeFormatted;
  }

  ChatRoomEntity copyWith({
    String? id,
    String? otherUserEmail,
    String? otherUserName,
    String? otherUserAvatar,
    ChatMessageEntity? lastMessage,
    int? unreadCount,
  }) {
    return ChatRoomEntity(
      id: id ?? this.id,
      otherUserEmail: otherUserEmail ?? this.otherUserEmail,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
