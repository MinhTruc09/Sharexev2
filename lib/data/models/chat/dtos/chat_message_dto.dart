import 'package:sharexev2/core/utils/date_time_ext.dart';

/// ChatMessageDto theo API docs
/// https://carpooling-j5xn.onrender.com/api/chat/test/{roomId}
class ChatMessageDto {
  final String token;
  final String senderEmail;
  final String receiverEmail;
  final String senderName;
  final String content;
  final String roomId;
  final DateTime timestamp;
  final bool read;

  ChatMessageDto({
    required this.token,
    required this.senderEmail,
    required this.receiverEmail,
    required this.senderName,
    required this.content,
    required this.roomId,
    required this.timestamp,
    required this.read,
  });

  /// Getter tiện lợi hiển thị "x phút trước"
  String get timeAgo => timestamp.timeAgo;

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      token: json['token'] ?? '',
      senderEmail: json['senderEmail'] ?? '',
      receiverEmail: json['receiverEmail'] ?? '',
      senderName: json['senderName'] ?? '',
      content: json['content'] ?? '',
      roomId: json['roomId'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "token": token,
      "senderEmail": senderEmail,
      "receiverEmail": receiverEmail,
      "senderName": senderName,
      "content": content,
      "roomId": roomId,
      "timestamp": timestamp.toIso8601String(),
      "read": read,
    };
  }

  @override
  String toString() {
    return 'ChatMessageDTO(token: $token, senderEmail: $senderEmail, content: $content, roomId: $roomId)';
  }
}
