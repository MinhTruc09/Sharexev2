import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sharexev2/data/models/chat/entities/chat_message_entity.dart';

Future<List<ChatMessageEntity>> fetchChatMessages(String roomId, String token) async {
  final response = await http.get(
    Uri.parse("http://localhost:8080/api/chat/$roomId"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Note: This would need to be updated to properly map from JSON to ChatMessageEntity
    // For now, returning empty list as placeholder
    return [];
  } else {
    throw Exception('Failed to fetch chat messages');
  }
}
