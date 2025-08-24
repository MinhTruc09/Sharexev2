import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:sharexev2/data/models/chat_message.dart';

class WebSocketService {
  static const String wsUrl = 'ws://localhost:8080/ws';
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
      
      // Create WebSocket connection with authentication
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
      print('❌ Cannot send message: WebSocket not connected');
      onError?.call('WebSocket not connected');
      return;
    }

    try {
      final messageData = {
        'type': 'chat_message',
        'data': message.toJson(),
        'token': _currentToken,
      };
      
      _channel!.sink.add(jsonEncode(messageData));
      print('📤 Message sent: ${message.content}');
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
        'type': 'typing_indicator',
        'data': {
          'roomId': _currentRoomId,
          'isTyping': isTyping,
        },
        'token': _currentToken,
      };
      
      _channel!.sink.add(jsonEncode(typingData));
    } catch (e) {
      print('❌ Error sending typing indicator: $e');
    }
  }

  // Join room (if not already connected)
  void joinRoom(String roomId) {
    if (!_isConnected || _channel == null) return;

    try {
      final joinData = {
        'type': 'join_room',
        'data': {
          'roomId': roomId,
        },
        'token': _currentToken,
      };
      
      _channel!.sink.add(jsonEncode(joinData));
      _currentRoomId = roomId;
      print('🚪 Joined room: $roomId');
    } catch (e) {
      print('❌ Error joining room: $e');
    }
  }

  // Leave room
  void leaveRoom() {
    if (!_isConnected || _channel == null) return;

    try {
      final leaveData = {
        'type': 'leave_room',
        'data': {
          'roomId': _currentRoomId,
        },
        'token': _currentToken,
      };
      
      _channel!.sink.add(jsonEncode(leaveData));
      print('🚪 Left room: $_currentRoomId');
    } catch (e) {
      print('❌ Error leaving room: $e');
    }
  }

  // Disconnect WebSocket
  void disconnect() {
    try {
      if (_isConnected && _channel != null) {
        leaveRoom(); // Leave current room before disconnecting
        _channel!.sink.close(status.goingAway);
      }
      _isConnected = false;
      _currentToken = null;
      _currentRoomId = null;
      print('🔌 WebSocket disconnected');
    } catch (e) {
      print('❌ Error disconnecting: $e');
    }
  }

  // Reconnect with exponential backoff
  Future<void> reconnect() async {
    if (_currentToken == null || _currentRoomId == null) {
      print('❌ Cannot reconnect: Missing token or room ID');
      return;
    }

    int retryCount = 0;
    const maxRetries = 5;
    
    while (retryCount < maxRetries && !_isConnected) {
      try {
        await Future.delayed(Duration(seconds: 2 << retryCount)); // Exponential backoff
        await connect(_currentToken!, _currentRoomId!);
        break;
      } catch (e) {
        retryCount++;
        print('🔄 Reconnection attempt $retryCount failed: $e');
        if (retryCount >= maxRetries) {
          onError?.call('Failed to reconnect after $maxRetries attempts');
        }
      }
    }
  }

  // Check connection health
  void ping() {
    if (!_isConnected || _channel == null) return;

    try {
      final pingData = {
        'type': 'ping',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _channel!.sink.add(jsonEncode(pingData));
    } catch (e) {
      print('❌ Error sending ping: $e');
    }
  }

  // Dispose resources
  void dispose() {
    disconnect();
    onMessageReceived = null;
    onConnected = null;
    onDisconnected = null;
    onError = null;
  }
}
