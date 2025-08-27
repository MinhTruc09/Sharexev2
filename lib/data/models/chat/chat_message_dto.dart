import 'package:sharexev2/core/utils/date_time_ext.dart';

class ChatMessageDTO {
  final String token;
  final String senderEmail;
  final String receiverEmail;
  final String senderName;
  final String content;
  final String roomId;
  final DateTime timestamp;
  final bool read;

  ChatMessageDTO({
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

  factory ChatMessageDTO.fromJson(Map<String, dynamic> json) {
    return ChatMessageDTO(
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
}
