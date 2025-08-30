import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/chat/entities/chat_message.dart';
import 'package:sharexev2/data/models/chat/entities/chat_room.dart';
import 'package:sharexev2/data/repositories/chat/chat_repository_impl.dart';
import 'package:sharexev2/data/services/chat/chat_api_service.dart';
import 'package:sharexev2/data/services/service_registry.dart';
import 'package:sharexev2/data/services/chat/chat_service_interface.dart';
import 'chat_repository_interface.dart';

/// Legacy ChatRepository - Giữ lại để backward compatibility
/// Implement ChatRepositoryInterface và delegate to ChatRepositoryImpl
class ChatRepository implements ChatRepositoryInterface {
  final ChatRepositoryImpl _impl;

  ChatRepository({ChatServiceInterface? service})
    : _impl = ChatRepositoryImpl(
        service ?? ChatApiService(ServiceRegistry.I.apiClient),
      );

  @override
  Future<ApiResponse<List<ChatRoom>>> getChatRooms(String token) =>
      _impl.getChatRooms(token);

  @override
  Future<ApiResponse<List<ChatMessage>>> fetchMessages(
    String roomId,
    String token,
  ) => _impl.fetchMessages(roomId, token);

  @override
  Future<ApiResponse<String>> createChatRoom(
    String participantEmail,
    String token,
  ) => _impl.createChatRoom(participantEmail, token);

  @override
  Future<ApiResponse<String>> getChatRoomId(
    String otherUserEmail,
    String token,
  ) => _impl.getChatRoomId(otherUserEmail, token);

  @override
  Future<ApiResponse<void>> markMessagesAsRead(String roomId, String token) =>
      _impl.markMessagesAsRead(roomId, token);

  @override
  Future<ApiResponse<ChatMessage>> sendMessage(
    String roomId,
    ChatMessage message,
    String token,
  ) => _impl.sendMessage(roomId, message, token);

  @override
  Future<ApiResponse<ChatMessage>> sendTestMessage(
    String roomId,
    Map<String, dynamic> messageData,
    String token,
  ) => _impl.sendTestMessage(roomId, messageData, token);
}
