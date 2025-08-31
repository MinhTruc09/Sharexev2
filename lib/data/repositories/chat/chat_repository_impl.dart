import 'package:sharexev2/core/auth/auth_manager.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/chat/entities/chat_message_entity.dart';
import 'package:sharexev2/data/models/chat/mappers/chat_message_mapper.dart';
import 'package:sharexev2/data/services/chat/chat_service_interface.dart';
import 'chat_repository.dart';

/// Chat Repository Implementation
class ChatRepositoryImpl implements ChatRepositoryInterface {
  final ChatServiceInterface _chatService;
  final AuthManager _authManager;

  ChatRepositoryImpl({
    required ChatServiceInterface chatService,
    required AuthManager authManager,
  })  : _chatService = chatService,
        _authManager = authManager;

  @override
  Future<ApiResponse<List<ChatMessageEntity>>> getChatMessages(String roomId) async {
    try {
      final token = _authManager.getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<List<ChatMessageEntity>>(
          message: 'Token không hợp lệ',
          statusCode: 401,
          data: null,
          success: false,
        );
      }

      final response = await _chatService.getChatMessages(token, roomId);
      
      if (response.success && response.data != null) {
        final messages = ChatMessageMapper.fromDtoList(response.data!);
        return ApiResponse<List<ChatMessageEntity>>(
          message: response.message,
          statusCode: response.statusCode,
          data: messages,
          success: true,
        );
      }

      return ApiResponse<List<ChatMessageEntity>>(
        message: response.message,
        statusCode: response.statusCode,
        data: null,
        success: false,
      );
    } catch (e) {
      return ApiResponse<List<ChatMessageEntity>>(
        message: 'Lỗi: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  @override
  Future<ApiResponse<ChatMessageEntity>> sendTestMessage(String roomId, ChatMessageEntity message) async {
    try {
      final token = _authManager.getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<ChatMessageEntity>(
          message: 'Token không hợp lệ',
          statusCode: 401,
          data: null,
          success: false,
        );
      }

      final messageDto = ChatMessageMapper.toDto(message);
      final response = await _chatService.sendTestMessage(roomId, messageDto, token);
      
      if (response.success && response.data != null) {
        final sentMessage = ChatMessageMapper.fromDto(response.data!);
        return ApiResponse<ChatMessageEntity>(
          message: response.message,
          statusCode: response.statusCode,
          data: sentMessage,
          success: true,
        );
      }

      return ApiResponse<ChatMessageEntity>(
        message: response.message,
        statusCode: response.statusCode,
        data: null,
        success: false,
      );
    } catch (e) {
      return ApiResponse<ChatMessageEntity>(
        message: 'Lỗi: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  @override
  Future<ApiResponse<void>> markMessagesAsRead(String roomId) async {
    try {
      final token = _authManager.getToken();
      if (token == null || token.isEmpty) {
        return ApiResponse<void>(
          message: 'Token không hợp lệ',
          statusCode: 401,
          data: null,
          success: false,
        );
      }

      final response = await _chatService.markMessagesAsRead(roomId, token);
      
      return ApiResponse<void>(
        message: response.message,
        statusCode: response.statusCode,
        data: null,
        success: response.success,
      );
    } catch (e) {
      return ApiResponse<void>(
        message: 'Lỗi: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }
}
