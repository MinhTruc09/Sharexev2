import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/chat/dtos/chat_message_dto.dart';

/// Chat Service Interface - Theo API docs
/// https://carpooling-j5xn.onrender.com/api/chat
abstract class ChatServiceInterface {
  /// GET /api/chat/{roomId} - Lấy tin nhắn của phòng chat
  /// https://carpooling-j5xn.onrender.com/api/chat/{roomId}
  Future<ApiResponse<List<ChatMessageDto>>> getChatMessages(String token, String roomId);

  /// POST /api/chat/test/{roomId} - Gửi tin nhắn test
  /// https://carpooling-j5xn.onrender.com/api/chat/test/{roomId}
  Future<ApiResponse<ChatMessageDto>> sendTestMessage(String roomId, ChatMessageDto message, String token);
  
  /// PUT /api/chat/{roomId}/mark-read - Đánh dấu tin nhắn đã đọc
  /// https://carpooling-j5xn.onrender.com/api/chat/{roomId}/mark-read
  Future<ApiResponse<void>> markMessagesAsRead(String roomId, String token);
}
