import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/chat/dtos/chat_message_dto.dart';
import 'package:sharexev2/data/models/chat/dtos/chat_room_dto.dart';

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

  /// GET /api/chat/rooms - Lấy danh sách phòng chat
  /// https://carpooling-j5xn.onrender.com/api/chat/rooms
  Future<ApiResponse<List<ChatRoomDTO>>> getChatRooms(String token);

  /// GET /api/chat/room/{otherUserEmail} - Lấy ID phòng chat
  /// https://carpooling-j5xn.onrender.com/api/chat/room/{otherUserEmail}
  Future<ApiResponse<String>> getChatRoomId(String otherUserEmail, String token);

  /// POST /api/chat/{roomId} - Gửi tin nhắn
  /// https://carpooling-j5xn.onrender.com/api/chat/{roomId}
  Future<ApiResponse<ChatMessageDto>> sendMessage(String roomId, ChatMessageDto message, String token);

  /// POST /api/chat/room/{otherUserEmail} - Tạo phòng chat mới
  /// https://carpooling-j5xn.onrender.com/api/chat/room/{otherUserEmail}
  Future<ApiResponse<String>> createChatRoom(String otherUserEmail, String token);

  /// DELETE /api/chat/{roomId} - Xóa phòng chat
  /// https://carpooling-j5xn.onrender.com/api/chat/{roomId}
  Future<ApiResponse<void>> deleteChatRoom(String roomId, String token);
}
