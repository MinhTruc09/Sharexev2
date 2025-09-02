import 'package:dio/dio.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/chat/dtos/chat_message_dto.dart';
import 'package:sharexev2/data/models/chat/dtos/chat_room_dto.dart';
import 'chat_service_interface.dart';

/// Chat API Service Implementation
class ChatApiService implements ChatServiceInterface {
  final Dio _dio;

  ChatApiService(this._dio);

  @override
  Future<ApiResponse<List<ChatMessageDto>>> getChatMessages(String token, String roomId) async {
    try {
      final response = await _dio.get(
        '/api/chat/$roomId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data != null && response.data['data'] is List) {
        final List<dynamic> messagesJson = response.data['data'];
        final messages = messagesJson
            .map((json) => ChatMessageDto.fromJson(json))
            .toList();

        return ApiResponse<List<ChatMessageDto>>(
          message: response.data['message'] ?? 'Lấy tin nhắn thành công',
          statusCode: response.statusCode ?? 200,
          data: messages,
          success: true,
        );
      }

      return ApiResponse<List<ChatMessageDto>>(
        message: response.data['message'] ?? 'Không thể lấy tin nhắn',
        statusCode: response.statusCode ?? 400,
        data: null,
        success: false,
      );
    } catch (e) {
      return ApiResponse<List<ChatMessageDto>>(
        message: 'Lỗi kết nối: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  @override
  Future<ApiResponse<ChatMessageDto>> sendTestMessage(String roomId, ChatMessageDto message, String token) async {
    try {
      final response = await _dio.post(
        '/api/chat/test/$roomId',
        data: message.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data != null && response.data['data'] != null) {
        final sentMessage = ChatMessageDto.fromJson(response.data['data']);

        return ApiResponse<ChatMessageDto>(
          message: response.data['message'] ?? 'Gửi tin nhắn thành công',
          statusCode: response.statusCode ?? 200,
          data: sentMessage,
          success: true,
        );
      }

      return ApiResponse<ChatMessageDto>(
        message: response.data['message'] ?? 'Không thể gửi tin nhắn',
        statusCode: response.statusCode ?? 400,
        data: null,
        success: false,
      );
    } catch (e) {
      return ApiResponse<ChatMessageDto>(
        message: 'Lỗi kết nối: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  @override
  Future<ApiResponse<void>> markMessagesAsRead(String roomId, String token) async {
    try {
      final response = await _dio.put(
        '/api/chat/$roomId/mark-read',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          message: response.data['message'] ?? 'Đánh dấu đã đọc thành công',
          statusCode: response.statusCode ?? 200,
          data: null,
          success: true,
        );
      }

      return ApiResponse<void>(
        message: response.data['message'] ?? 'Không thể đánh dấu đã đọc',
        statusCode: response.statusCode ?? 400,
        data: null,
        success: false,
      );
    } catch (e) {
      return ApiResponse<void>(
        message: 'Lỗi kết nối: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  /// Get chat rooms for user
  Future<ApiResponse<List<ChatRoomDTO>>> getChatRooms(String token) async {
    try {
      final response = await _dio.get(
        '/api/chat/rooms',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data != null && response.data['data'] is List) {
        final List<dynamic> roomsJson = response.data['data'];
        final rooms = roomsJson
            .map((json) => ChatRoomDTO.fromJson(json))
            .toList();

        return ApiResponse<List<ChatRoomDTO>>(
          message: response.data['message'] ?? 'Lấy danh sách phòng chat thành công',
          statusCode: response.statusCode ?? 200,
          data: rooms,
          success: true,
        );
      }

      return ApiResponse<List<ChatRoomDTO>>(
        message: response.data['message'] ?? 'Không thể lấy danh sách phòng chat',
        statusCode: response.statusCode ?? 400,
        data: null,
        success: false,
      );
    } catch (e) {
      return ApiResponse<List<ChatRoomDTO>>(
        message: 'Lỗi kết nối: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  /// Get messages for a chat room
  Future<ApiResponse<List<ChatMessageDto>>> getMessages(String roomId, String token) async {
    return getChatMessages(token, roomId);
  }

  /// Get chat room ID by user email
  Future<ApiResponse<String>> getChatRoomId(String otherUserEmail, String token) async {
    try {
      final response = await _dio.get(
        '/api/chat/room/$otherUserEmail',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data != null && response.data['data'] is String) {
        return ApiResponse<String>(
          message: response.data['message'] ?? 'Lấy room ID thành công',
          statusCode: response.statusCode ?? 200,
          data: response.data['data'],
          success: true,
        );
      }

      return ApiResponse<String>(
        message: response.data['message'] ?? 'Không thể lấy room ID',
        statusCode: response.statusCode ?? 400,
        data: null,
        success: false,
      );
    } catch (e) {
      return ApiResponse<String>(
        message: 'Lỗi kết nối: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  /// Send message to chat room
  Future<ApiResponse<ChatMessageDto>> sendMessage(String roomId, ChatMessageDto messageDto, String token) async {
    try {
      final response = await _dio.post(
        '/api/chat/$roomId',
        data: messageDto.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data != null && response.data['data'] != null) {
        final message = ChatMessageDto.fromJson(response.data['data']);

        return ApiResponse<ChatMessageDto>(
          message: response.data['message'] ?? 'Gửi tin nhắn thành công',
          statusCode: response.statusCode ?? 200,
          data: message,
          success: true,
        );
      }

      return ApiResponse<ChatMessageDto>(
        message: response.data['message'] ?? 'Không thể gửi tin nhắn',
        statusCode: response.statusCode ?? 400,
        data: null,
        success: false,
      );
    } catch (e) {
      return ApiResponse<ChatMessageDto>(
        message: 'Lỗi kết nối: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }
}
