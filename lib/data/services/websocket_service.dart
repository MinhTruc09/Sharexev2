import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:sharexev2/data/models/chat_message.dart';
import 'package:sharexev2/config/app_config.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _currentToken;
  String? _currentRoomId;
  
  // Callbacks
  Function(ChatMessage)? onMessageReceived;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String)? onError;

  bool get isConnected => _isConnected;

  // Connect to WebSocket with authentication
  Future<void> connect(String token, String roomId) async {
    try {
      _currentToken = token;
      _currentRoomId = roomId;
      
      // Create WebSocket connection with authentication using config URL
      final wsUrl = AppConfig.I.webSocketUrl;
      final uri = Uri.parse('$wsUrl?token=$token&roomId=$roomId');
      _channel = WebSocketChannel.connect(uri);
      
      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
      
      _isConnected = true;
      onConnected?.call();
      print('✅ WebSocket connected to room: $roomId');
      
    } catch (e) {
      print('❌ WebSocket connection error: $e');
      onError?.call(e.toString());
    }
  }

  // Handle incoming messages
  void _handleMessage(dynamic data) {
    try {
      final messageData = jsonDecode(data);
      
      // Check message type
      switch (messageData['type']) {
        case 'chat_message':
          final message = ChatMessage.fromJson(messageData['data']);
          onMessageReceived?.call(message);
          break;
        case 'user_typing':
          // Handle typing indicator
          _handleTypingIndicator(messageData['data']);
          break;
        case 'user_joined':
          print('User joined: ${messageData['data']['userEmail']}');
          break;
        case 'user_left':
          print('User left: ${messageData['data']['userEmail']}');
          break;
        default:
          print('Unknown message type: ${messageData['type']}');
      }
    } catch (e) {
      print('Error parsing message: $e');
      onError?.call('Failed to parse message: $e');
    }
  }

  // Handle typing indicator
  void _handleTypingIndicator(Map<String, dynamic> data) {
    // Implement typing indicator logic
    print('User typing: ${data['userEmail']}');
  }

  // Handle connection errors
  void _handleError(error) {
    print('❌ WebSocket error: $error');
    _isConnected = false;
    onError?.call(error.toString());
  }

  // Handle disconnection
  void _handleDisconnection() {
    print('🔌 WebSocket disconnected');
    _isConnected = false;
    onDisconnected?.call();
  }

  // Send chat message
  void sendMessage(ChatMessage message) {
    if (!_isConnected || _channel == null) {
      print('❌ WebSocket not connected');
      return;
    }

    try {
      final messageData = {
        'type': 'chat_message',
        'data': message.toJson(),
        'roomId': _currentRoomId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _channel!.sink.add(jsonEncode(messageData));
      print('✅ Message sent via WebSocket');
    } catch (e) {
      print('❌ Error sending message: $e');
      onError?.call('Failed to send message: $e');
    }
  }

  // Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    if (!_isConnected || _channel == null) return;

    try {
      final typingData = {
        'type': 'user_typing',
        'data': {
          'userEmail': _currentToken, // Use token as user identifier
          'isTyping': isTyping,
          'roomId': _currentRoomId,
        },
      };

      _channel!.sink.add(jsonEncode(typingData));
    } catch (e) {
      print('Error sending typing indicator: $e');
    }
  }

  // Disconnect from WebSocket
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }
    _isConnected = false;
    _currentToken = null;
    _currentRoomId = null;
    print('🔌 WebSocket disconnected manually');
  }

  // Reconnect to WebSocket
  Future<void> reconnect() async {
    if (_currentToken != null && _currentRoomId != null) {
      disconnect();
      await Future.delayed(const Duration(seconds: 1));
      await connect(_currentToken!, _currentRoomId!);
    }
  }

  // Check connection health
  bool get isHealthy => _isConnected && _channel != null;

  // Get current room ID
  String? get currentRoomId => _currentRoomId;

  // Get current token
  String? get currentToken => _currentToken;
}
