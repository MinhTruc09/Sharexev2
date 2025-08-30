import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/chat/entities/chat_message.dart';
import 'package:sharexev2/data/models/chat/mappers/chat_message_mapper.dart';
import 'package:sharexev2/data/models/chat/mappers/chat_room_mapper.dart';
import 'package:sharexev2/data/models/chat/dtos/chat_room_dto.dart';
import 'package:sharexev2/data/models/chat/dtos/chat_message_dto.dart';
import 'package:sharexev2/data/models/chat/entities/chat_room.dart';
import 'package:sharexev2/data/services/chat/chat_service_interface.dart';
import 'package:sharexev2/data/services/chat/chat_api_service.dart';
import 'package:sharexev2/data/services/service_registry.dart';
import 'chat_repository_interface.dart';

class ChatRepositoryImpl implements ChatRepositoryInterface {
  final ChatServiceInterface _service;

  ChatRepositoryImpl([ChatServiceInterface? service]) : _service = service ?? ChatApiService(ServiceRegistry.I.apiClient);

  Future<ApiResponse<List<ChatRoom>>> getChatRooms(String token) async {
    final resp = await _service.getChatRooms(token);
    final dtos = resp.data ?? [];
    final rooms = dtos
        .map((json) {
          final dto = ChatRoomDTO.fromJson(json as Map<String, dynamic>);
          return ChatRoomMapper.fromDto(dto);
        })
        .toList();

    return ApiResponse<List<ChatRoom>>(
      message: resp.message,
      statusCode: resp.statusCode,
      data: rooms,
      success: resp.success,
    );
  }

  Future<ApiResponse<List<ChatMessage>>> fetchMessages(
    String roomId,
    String token,
  ) async {
    final resp = await _service.fetchMessages(roomId, token);
    final dtos = resp.data ?? [];
    final messages = dtos.map((dto) => ChatMessageMapper.fromDto(dto)).toList();

    return ApiResponse<List<ChatMessage>>(
      message: resp.message,
      statusCode: resp.statusCode,
      data: messages,
      success: resp.success,
    );
  }

  Future<ApiResponse<String>> createChatRoom(String participantEmail, String token) async {
    final resp = await _service.createChatRoom(participantEmail, token);
    return ApiResponse<String>(
      message: resp.message,
      statusCode: resp.statusCode,
      data: resp.data,
      success: resp.success,
    );
  }

  Future<ApiResponse<void>> markMessagesAsRead(String roomId, String token) async {
    final resp = await _service.markMessagesAsRead(roomId, token);
    return ApiResponse<void>(
      message: resp.message,
      statusCode: resp.statusCode,
      data: null,
      success: resp.success,
    );
  }

  Future<ApiResponse<String>> getChatRoomId(String otherUserEmail, String token) async {
    final resp = await _service.getChatRoomId(otherUserEmail, token);
    return ApiResponse<String>(
      message: resp.message,
      statusCode: resp.statusCode,
      data: resp.data,
      success: resp.success,
    );
  }

  Future<ApiResponse<ChatMessage>> sendMessage(
    String roomId,
    ChatMessage message,
    String token,
  ) async {
    final dto = ChatMessageMapper.toDto(message);
    final resp = await _service.sendMessage(roomId, dto, token);
    final entity = resp.data != null ? ChatMessageMapper.fromDto(resp.data!) : null;
    return ApiResponse<ChatMessage>(
      message: resp.message,
      statusCode: resp.statusCode,
      data: entity,
      success: resp.success,
    );
  }

  Future<ApiResponse<ChatMessage>> sendTestMessage(
    String roomId,
    Map<String, dynamic> messageData,
    String token,
  ) async {
    final resp = await _service.sendTestMessage(roomId, messageData, token);
    final entity = resp.data != null ? ChatMessageMapper.fromDto(resp.data!) : null;
    return ApiResponse<ChatMessage>(
      message: resp.message,
      statusCode: resp.statusCode,
      data: entity,
      success: resp.success,
    );
  }
}
