import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/chat/entities/chat_message_entity.dart';
import 'package:sharexev2/data/models/chat/entities/chat_room.dart';
import 'package:sharexev2/data/models/chat/mappers/chat_message_mapper.dart';
import 'package:sharexev2/data/models/chat/dtos/chat_message_dto.dart';
import 'package:sharexev2/data/services/chat/chat_api_service.dart';
import 'chat_repository_interface.dart';

/// Chat Repository Implementation
class ChatRepositoryImpl implements ChatRepositoryInterface {
  final ChatApiService _chatApiService;

  ChatRepositoryImpl({
    required ChatApiService chatApiService,
  }) : _chatApiService = chatApiService;

  @override
  Future<ApiResponse<List<ChatRoom>>> getChatRooms(String token) async {
    try {
      final response = await _chatApiService.getChatRooms(token);
      
      if (response.success && response.data != null) {
        // TODO: Map response to ChatRoom entities
        return ApiResponse.success(
          data: <ChatRoom>[], // Placeholder until mapping is implemented
          message: response.message,
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to get chat rooms',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error getting chat rooms: $e',
      );
    }
  }

  @override
  Future<ApiResponse<List<ChatMessageEntity>>> fetchMessages(
    String roomId,
    String token,
  ) async {
    try {
      final response = await _chatApiService.getMessages(roomId, token);
      
      if (response.success && response.data != null) {
        final messages = ChatMessageMapper.fromDtoList(response.data!);
        return ApiResponse.success(
          data: messages,
          message: response.message,
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to fetch messages',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error fetching messages: $e',
      );
    }
  }

  @override
  Future<ApiResponse<String>> createChatRoom(
    String participantEmail,
    String token,
  ) async {
    try {
      final response = await _chatApiService.getChatRoomId(participantEmail, token);
      
      if (response.success && response.data != null) {
        return ApiResponse.success(
          data: response.data!,
          message: response.message,
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to create chat room',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error creating chat room: $e',
      );
    }
  }

  @override
  Future<ApiResponse<String>> getChatRoomId(
    String otherUserEmail,
    String token,
  ) async {
    try {
      final response = await _chatApiService.getChatRoomId(otherUserEmail, token);
      
      if (response.success && response.data != null) {
        return ApiResponse.success(
          data: response.data!,
          message: response.message,
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to get chat room ID',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error getting chat room ID: $e',
      );
    }
  }

  @override
  Future<ApiResponse<ChatMessageEntity>> sendMessage(
    String roomId,
    ChatMessageEntity message,
    String token,
  ) async {
    try {
      final messageDto = ChatMessageMapper.toDto(message);
      final response = await _chatApiService.sendMessage(roomId, messageDto, token);
      
      if (response.success && response.data != null) {
        final sentMessage = ChatMessageMapper.fromDto(response.data!);
        return ApiResponse.success(
          data: sentMessage,
          message: response.message,
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to send message',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error sending message: $e',
      );
    }
  }

  @override
  Future<ApiResponse<ChatMessageEntity>> sendTestMessage(
    String roomId,
    ChatMessageDto messageData,
    String token,
  ) async {
    try {
      final response = await _chatApiService.sendTestMessage(roomId, messageData, token);
      
      if (response.success && response.data != null) {
        final sentMessage = ChatMessageMapper.fromDto(response.data!);
        return ApiResponse.success(
          data: sentMessage,
          message: response.message,
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to send test message',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error sending test message: $e',
      );
    }
  }

  @override
  Future<ApiResponse<void>> markMessagesAsRead(
    String roomId,
    String token,
  ) async {
    try {
      final response = await _chatApiService.markMessagesAsRead(roomId, token);
      
      return ApiResponse.success(
        data: null,
        message: response.message ?? 'Messages marked as read',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Error marking messages as read: $e',
      );
    }
  }
}
