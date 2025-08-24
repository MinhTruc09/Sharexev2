import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sharexev2/data/models/chat_message.dart';
import 'package:sharexev2/config/env.dart';

class ChatService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Load chat history from API
  static Future<List<ChatMessage>> fetchMessages(String roomId, String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/chat/$roomId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = (data['data'] as List)
            .map((e) => ChatMessage.fromJson(e))
            .toList();
        return messages;
      } else {
        throw Exception("Failed to load chat history: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching messages: $e");
      // Return mock data for development
      return _getMockMessages(roomId);
    }
  }

  // Create chat room
  static Future<String> createChatRoom(String participantEmail, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat/room"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "participantEmail": participantEmail,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['roomId'];
      } else {
        throw Exception("Failed to create chat room: ${response.statusCode}");
      }
    } catch (e) {
      print("Error creating chat room: $e");
      // Return mock room ID for development
      return "room_${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  // Get chat rooms for user
  static Future<List<Map<String, dynamic>>> getChatRooms(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/chat/rooms"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception("Failed to load chat rooms: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching chat rooms: $e");
      // Return mock data for development
      return _getMockChatRooms();
    }
  }

  // Mark messages as read
  static Future<void> markAsRead(String roomId, String token) async {
    try {
      await http.put(
        Uri.parse("$baseUrl/chat/$roomId/read"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  // Mock data for development
  static List<ChatMessage> _getMockMessages(String roomId) {
    return [
      ChatMessage(
        roomId: roomId,
        senderEmail: 'driver@test.com',
        senderName: 'Driver A',
        receiverEmail: 'passenger@test.com',
        content: 'Hello! I am your driver for today.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        read: true,
        messageId: 'msg_1',
      ),
      ChatMessage(
        roomId: roomId,
        senderEmail: 'passenger@test.com',
        senderName: 'Passenger B',
        receiverEmail: 'driver@test.com',
        content: 'Hi! Where are you now?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        read: true,
        messageId: 'msg_2',
      ),
      ChatMessage(
        roomId: roomId,
        senderEmail: 'driver@test.com',
        senderName: 'Driver A',
        receiverEmail: 'passenger@test.com',
        content: 'I am 5 minutes away from pickup location.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        read: false,
        messageId: 'msg_3',
      ),
    ];
  }

  static List<Map<String, dynamic>> _getMockChatRooms() {
    return [
      {
        'roomId': 'room_1',
        'participantName': 'Driver A',
        'participantEmail': 'driver@test.com',
        'lastMessage': 'I am 5 minutes away from pickup location.',
        'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
        'unreadCount': 1,
        'tripId': 'trip_1',
      },
      {
        'roomId': 'room_2',
        'participantName': 'Passenger B',
        'participantEmail': 'passenger2@test.com',
        'lastMessage': 'Thank you for the ride!',
        'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'unreadCount': 0,
        'tripId': 'trip_2',
      },
    ];
  }

  // Validate message content
  static bool isValidMessage(String content) {
    return content.trim().isNotEmpty && content.length <= 1000;
  }

  // Format timestamp for display
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Generate room ID for two users
  static String generateRoomId(String email1, String email2) {
    final emails = [email1, email2]..sort();
    return 'room_${emails.join('_').replaceAll('@', '_').replaceAll('.', '_')}';
  }
}
