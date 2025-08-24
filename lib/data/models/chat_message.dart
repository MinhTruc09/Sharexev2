class ChatMessage {
  final String roomId;
  final String senderEmail;
  final String senderName;
  final String receiverEmail;
  final String content;
  final DateTime timestamp;
  final bool read;
  final String? messageId;
  final String? messageType; // 'text', 'image', 'location'

  ChatMessage({
    required this.roomId,
    required this.senderEmail,
    required this.senderName,
    required this.receiverEmail,
    required this.content,
    required this.timestamp,
    this.read = false,
    this.messageId,
    this.messageType = 'text',
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      roomId: json['roomId'] ?? '',
      senderEmail: json['senderEmail'] ?? '',
      senderName: json['senderName'] ?? '',
      receiverEmail: json['receiverEmail'] ?? '',
      content: json['content'] ?? '',
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      read: json['read'] ?? false,
      messageId: json['messageId'],
      messageType: json['messageType'] ?? 'text',
    );
  }

  Map<String, dynamic> toJson() => {
    "roomId": roomId,
    "senderEmail": senderEmail,
    "senderName": senderName,
    "receiverEmail": receiverEmail,
    "content": content,
    "timestamp": timestamp.toIso8601String(),
    "read": read,
    if (messageId != null) "messageId": messageId,
    "messageType": messageType,
  };

  ChatMessage copyWith({
    String? roomId,
    String? senderEmail,
    String? senderName,
    String? receiverEmail,
    String? content,
    DateTime? timestamp,
    bool? read,
    String? messageId,
    String? messageType,
  }) {
    return ChatMessage(
      roomId: roomId ?? this.roomId,
      senderEmail: senderEmail ?? this.senderEmail,
      senderName: senderName ?? this.senderName,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      messageId: messageId ?? this.messageId,
      messageType: messageType ?? this.messageType,
    );
  }

  bool get isFromMe => senderEmail == getCurrentUserEmail();

  // Mock method - replace with actual user service
  static String getCurrentUserEmail() {
    return 'passenger@test.com'; // This should come from auth service
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.messageId == messageId &&
        other.roomId == roomId &&
        other.content == content &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return messageId.hashCode ^
        roomId.hashCode ^
        content.hashCode ^
        timestamp.hashCode;
  }
}
