class ChatRoomDTO {
  final String id;
  final String participantName;
  final String participantEmail;
  final String lastMessage;
  final String? lastMessageTime;
  final int unreadCount;

  ChatRoomDTO({
    required this.id,
    required this.participantName,
    required this.participantEmail,
    required this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
  });

  factory ChatRoomDTO.fromJson(Map<String, dynamic> json) {
    return ChatRoomDTO(
      id: json['roomId']?.toString() ?? '',
      participantName: json['participantName'] ?? '',
      participantEmail: json['participantEmail'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: json['lastMessageTime']?.toString(),
      unreadCount:
          (json['unreadCount'] is int)
              ? json['unreadCount'] as int
              : int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "roomId": id,
      "participantName": participantName,
      "participantEmail": participantEmail,
      "lastMessage": lastMessage,
      "lastMessageTime": lastMessageTime,
      "unreadCount": unreadCount,
    };
  }
}
