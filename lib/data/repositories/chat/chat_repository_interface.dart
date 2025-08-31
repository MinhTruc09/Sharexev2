import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/chat/entities/chat_message_entity.dart';
import 'package:sharexev2/data/models/chat/entities/chat_room.dart';

/// Interface cho ChatRepository
/// Định nghĩa tất cả operations liên quan đến chat data layer
abstract class ChatRepositoryInterface {
  /// Lấy danh sách tất cả phòng chat của user
  Future<ApiResponse<List<ChatRoom>>> getChatRooms(String token);

  /// Lấy danh sách tin nhắn của một phòng chat
  Future<ApiResponse<List<ChatMessageEntity>>> fetchMessages(
    String roomId,
    String token,
  );

  /// Tạo phòng chat mới hoặc lấy ID phòng chat hiện có
  Future<ApiResponse<String>> createChatRoom(
    String participantEmail,
    String token,
  );

  /// Lấy ID phòng chat giữa 2 users
  Future<ApiResponse<String>> getChatRoomId(
    String otherUserEmail,
    String token,
  );

  /// Đánh dấu tất cả tin nhắn trong phòng chat là đã đọc
  Future<ApiResponse<void>> markMessagesAsRead(
    String roomId,
    String token,
  );

  /// Gửi tin nhắn mới
  Future<ApiResponse<ChatMessageEntity>> sendMessage(
    String roomId,
    ChatMessageEntity message,
    String token,
  );

  /// Gửi tin nhắn test (cho development/testing)
  Future<ApiResponse<ChatMessageEntity>> sendTestMessage(
    String roomId,
    Map<String, dynamic> messageData,
    String token,
  );
}
