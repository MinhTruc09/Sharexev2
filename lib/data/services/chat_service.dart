import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sharexev2/data/models/chat_message.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/config/app_config.dart';

class ChatService {
  // Load chat history from API
  static Future<ApiResponse<List<ChatMessage>>> fetchMessages(
    String roomId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.I.baseUrl}/chat/$roomId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list =
            (data['data'] as List<dynamic>? ?? [])
                .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
                .toList();

        return ApiResponse<List<ChatMessage>>(
          message: data['message'] ?? '',
          statusCode: data['statusCode'] ?? 0,
          data: list,
          success: data['success'] ?? false,
        );
      } else {
        throw Exception("Failed to load chat history: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching messages: $e");
      // No mock data: return an empty result and surface the error.
      return ApiResponse<List<ChatMessage>>(
        message: 'Failed to fetch messages: $e',
        statusCode: 500,
        data: const [],
        success: false,
      );
    }
  }

  // Create chat room
  static Future<String> createChatRoom(
    String participantEmail,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.I.baseUrl}/chat/room"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"participantEmail": participantEmail}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['roomId'];
      } else {
        throw Exception("Failed to create chat room: ${response.statusCode}");
      }
    } catch (e) {
      print("Error creating chat room: $e");
      rethrow;
    }
  }

  // Get chat rooms for user
  static Future<ApiResponse<List<Map<String, dynamic>>>> getChatRooms(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.I.baseUrl}/chat/rooms"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = List<Map<String, dynamic>>.from(
          data['data'] as List<dynamic>? ?? [],
        );
        return ApiResponse<List<Map<String, dynamic>>>(
          message: data['message'] ?? '',
          statusCode: data['statusCode'] ?? 0,
          data: list,
          success: data['success'] ?? false,
        );
      } else {
        throw Exception("Failed to get chat rooms: ${response.statusCode}");
      }
    } catch (e) {
      print("Error getting chat rooms: $e");
      return ApiResponse<List<Map<String, dynamic>>>(
        message: 'Failed to get chat rooms: $e',
        statusCode: 500,
        data: const [],
        success: false,
      );
    }
  }

  // Get chat room ID by other user email
  static Future<String?> getChatRoomId(
    String otherUserEmail,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.I.baseUrl}/chat/room/$otherUserEmail"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['data'] as String?;
      } else {
        throw Exception("Failed to get chat room ID: ${response.statusCode}");
      }
    } catch (e) {
      print("Error getting chat room ID: $e");
      return null;
    }
  }

  // Mark messages as read
  static Future<bool> markMessagesAsRead(
    String roomId,
    String token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("${AppConfig.I.baseUrl}/chat/$roomId/mark-read"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error marking messages as read: $e");
      return false;
    }
  }

  // Send test message via API (for testing purposes)
  static Future<bool> sendTestMessage(
    String roomId,
    Map<String, dynamic> messageData,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.I.baseUrl}/chat/test/$roomId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(messageData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error sending test message: $e");
      return false;
    }
  }
}
