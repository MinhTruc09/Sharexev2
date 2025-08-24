import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sharexev2/data/models/chat_message.dart';

Future<List<ChatMessage>> fetchChatMessages(String roomId, String token) async {
  final response = await http.get(
    Uri.parse("http://localhost:8080/api/chat/$roomId"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final messages =
        (data['data'] as List).map((e) => ChatMessage.fromJson(e)).toList();
    return messages;
  } else {
    throw Exception('Failed to fetch chat messages');
  }
}
