import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/chat/entities/chat_message_entity.dart';

/// Chat Repository Interface - Business logic layer
abstract class ChatRepositoryInterface {
  /// Lấy tin nhắn của phòng chat
  Future<ApiResponse<List<ChatMessageEntity>>> getChatMessages(String roomId);
  
  /// Gửi tin nhắn test
  Future<ApiResponse<ChatMessageEntity>> sendTestMessage(String roomId, ChatMessageEntity message);
  
  /// Đánh dấu tin nhắn đã đọc
  Future<ApiResponse<void>> markMessagesAsRead(String roomId);
}
