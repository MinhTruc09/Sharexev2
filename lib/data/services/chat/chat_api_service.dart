import 'package:dio/dio.dart';
import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/config/app_config.dart';
import 'package:sharexev2/data/models/chat/dtos/chat_message_dto.dart';
import 'chat_service_interface.dart';

/// Implementation của ChatServiceInterface
/// Sử dụng ApiClient thay vì http package
/// Loại bỏ code duplication và consistent error handling
class ChatApiService implements ChatServiceInterface {
  final ApiClient _apiClient;

  ChatApiService(this._apiClient);

  // ===== Helper Methods để tránh code duplication =====

  /// Build headers cho tất cả requests
  Map<String, String> _buildHeaders(String token) {
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  /// Handle API response và parse JSON
  ApiResponse<T> _handleApiResponse<T>(
    Response response,
    T Function(dynamic) parser,
  ) {
    try {
      final data = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(data, parser);
    } catch (e) {
      throw ChatServiceException('Failed to parse API response: $e');
    }
  }

  /// Handle DioException với proper error messages
  Never _handleDioException(DioException e, String operation) {
    String message;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout during $operation';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout during $operation';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout during $operation';
        break;
      case DioExceptionType.badResponse:
        message = 'Server error during $operation: ${e.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled during $operation';
        break;
      default:
        message = 'Network error during $operation: $e';
    }
    throw ChatServiceException(message);
  }

  // ===== Chat Operations =====

  @override
  Future<ApiResponse<List<ChatMessageDTO>>> fetchMessages(
    String roomId,
    String token,
  ) async {
    try {
      final response = await _apiClient.client.get(
        "${AppConfig.I.chat.messages}$roomId",
        options: Options(headers: _buildHeaders(token)),
      );

      return _handleApiResponse<List<ChatMessageDTO>>(
        response,
        (data) => (data as List<dynamic>)
            .map((e) => ChatMessageDTO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      _handleDioException(e, 'fetching messages');
    } catch (e) {
      throw ChatServiceException('Unexpected error fetching messages: $e');
    }
  }

  @override
  Future<ApiResponse<String>> createChatRoom(
    String participantEmail,
    String token,
  ) async {
    try {
      final response = await _apiClient.client.get(
        AppConfig.I.chat.roomByUser + participantEmail,
        options: Options(headers: _buildHeaders(token)),
      );

      return _handleApiResponse<String>(
        response,
        (data) => data as String,
      );
    } on DioException catch (e) {
      _handleDioException(e, 'creating chat room');
    } catch (e) {
      throw ChatServiceException('Unexpected error creating chat room: $e');
    }
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getChatRooms(
    String token,
  ) async {
    try {
      final response = await _apiClient.client.get(
        AppConfig.I.chat.rooms,
        options: Options(headers: _buildHeaders(token)),
      );

      return _handleApiResponse<List<Map<String, dynamic>>>(
        response,
        (data) => List<Map<String, dynamic>>.from(data as List<dynamic>),
      );
    } on DioException catch (e) {
      _handleDioException(e, 'getting chat rooms');
    } catch (e) {
      throw ChatServiceException('Unexpected error getting chat rooms: $e');
    }
  }

  @override
  Future<ApiResponse<String>> getChatRoomId(
    String otherUserEmail,
    String token,
  ) async {
    try {
      final response = await _apiClient.client.get(
        AppConfig.I.chat.roomByUser + otherUserEmail,
        options: Options(headers: _buildHeaders(token)),
      );

      return _handleApiResponse<String>(
        response,
        (data) => data as String,
      );
    } on DioException catch (e) {
      _handleDioException(e, 'getting chat room ID');
    } catch (e) {
      throw ChatServiceException('Unexpected error getting chat room ID: $e');
    }
  }

  @override
  Future<ApiResponse<void>> markMessagesAsRead(
    String roomId,
    String token,
  ) async {
    try {
      final response = await _apiClient.client.put(
        "${AppConfig.I.chat.markRead}$roomId",
        options: Options(headers: _buildHeaders(token)),
      );

      return _handleApiResponse<void>(
        response,
        (data) => null,
      );
    } on DioException catch (e) {
      _handleDioException(e, 'marking messages as read');
    } catch (e) {
      throw ChatServiceException('Unexpected error marking messages as read: $e');
    }
  }

  @override
  Future<ApiResponse<ChatMessageDTO>> sendMessage(
    String roomId,
    ChatMessageDTO message,
    String token,
  ) async {
    try {
      final response = await _apiClient.client.post(
        "${AppConfig.I.chat.sendTest}$roomId",
        data: message.toJson(),
        options: Options(headers: _buildHeaders(token)),
      );

      return _handleApiResponse<ChatMessageDTO>(
        response,
        (data) => ChatMessageDTO.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      _handleDioException(e, 'sending message');
    } catch (e) {
      throw ChatServiceException('Unexpected error sending message: $e');
    }
  }

  @override
  Future<ApiResponse<ChatMessageDTO>> sendTestMessage(
    String roomId,
    Map<String, dynamic> messageData,
    String token,
  ) async {
    try {
      final response = await _apiClient.client.post(
        "${AppConfig.I.chat.sendTest}$roomId",
        data: messageData,
        options: Options(headers: _buildHeaders(token)),
      );

      return _handleApiResponse<ChatMessageDTO>(
        response,
        (data) => ChatMessageDTO.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      _handleDioException(e, 'sending test message');
    } catch (e) {
      throw ChatServiceException('Unexpected error sending test message: $e');
    }
  }
}

/// Custom exception cho ChatService
class ChatServiceException implements Exception {
  final String message;
  ChatServiceException(this.message);

  @override
  String toString() => 'ChatServiceException: $message';
}
