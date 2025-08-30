import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/chat/dtos/chat_message_dto.dart';

abstract class ChatServiceInterface {
  Future<ApiResponse<List<ChatMessageDTO>>> fetchMessages(
    String roomId,
    String token,
  );

  Future<ApiResponse<List<Map<String, dynamic>>>> getChatRooms(String token);

  Future<ApiResponse<String>> getChatRoomId(
    String otherUserEmail,
    String token,
  );

  Future<ApiResponse<void>> markMessagesAsRead(String roomId, String token);

  Future<ApiResponse<ChatMessageDTO>> sendMessage(
    String roomId,
    ChatMessageDTO message,
    String token,
  );

  Future<ApiResponse<ChatMessageDTO>> sendTestMessage(
    String roomId,
    Map<String, dynamic> messageData,
    String token,
  );

  Future<ApiResponse<String>> createChatRoom(
    String participantEmail,
    String token,
  );
}
