import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/chat/chat_state.dart';
import 'package:sharexev2/data/models/chat_message.dart';
import 'package:sharexev2/data/services/chat_service.dart';
import 'package:sharexev2/data/services/websocket_service.dart';

class ChatCubit extends Cubit<ChatState> {
  final WebSocketService _webSocketService = WebSocketService();
  Timer? _typingTimer;
  String? _currentToken;

  ChatCubit() : super(const ChatState()) {
    _setupWebSocketCallbacks();
  }

  void _setupWebSocketCallbacks() {
    _webSocketService.onMessageReceived = _handleNewMessage;
    _webSocketService.onConnected = _handleConnected;
    _webSocketService.onDisconnected = _handleDisconnected;
    _webSocketService.onError = _handleError;
  }

  // Initialize chat with token
  Future<void> initialize(String token) async {
    _currentToken = token;
    await loadChatRooms();
  }

  // Load chat rooms
  Future<void> loadChatRooms() async {
    if (_currentToken == null) return;

    try {
      emit(state.copyWith(status: ChatStatus.loading));
      
      final rooms = await ChatService.getChatRooms(_currentToken!);
      final totalUnread = rooms.fold<int>(
        0, 
        (sum, room) => sum + (room['unreadCount'] as int? ?? 0),
      );
      
      emit(state.copyWith(
        status: ChatStatus.loaded,
        chatRooms: rooms,
        unreadCount: totalUnread,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: e.toString(),
      ));
    }
  }

  // Join chat room
  Future<void> joinRoom(String roomId) async {
    if (_currentToken == null) return;

    try {
      emit(state.copyWith(status: ChatStatus.loading));
      
      // Load message history
      final messages = await ChatService.fetchMessages(roomId, _currentToken!);
      
      // Connect to WebSocket
      await _webSocketService.connect(_currentToken!, roomId);
      
      // Mark messages as read
      await ChatService.markAsRead(roomId, _currentToken!);
      
      emit(state.copyWith(
        status: ChatStatus.loaded,
        messages: messages,
        currentRoomId: roomId,
        isConnected: true,
      ));
      
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: e.toString(),
      ));
    }
  }

  // Send message
  Future<void> sendMessage(String content, {String? receiverEmail}) async {
    if (_currentToken == null || state.currentRoomId == null) return;
    
    if (!ChatService.isValidMessage(content)) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: 'Invalid message content',
      ));
      return;
    }

    try {
      emit(state.copyWith(status: ChatStatus.sending));
      
      final message = ChatMessage(
        roomId: state.currentRoomId!,
        senderEmail: ChatMessage.getCurrentUserEmail(),
        senderName: 'Current User', // Should come from auth service
        receiverEmail: receiverEmail ?? '',
        content: content,
        timestamp: DateTime.now(),
        messageId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      // Add message optimistically to UI
      final updatedMessages = [...state.messages, message];
      emit(state.copyWith(
        status: ChatStatus.loaded,
        messages: updatedMessages,
      ));
      
      // Send via WebSocket
      _webSocketService.sendMessage(message);
      
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: 'Failed to send message: $e',
      ));
    }
  }

  // Handle new message from WebSocket
  void _handleNewMessage(ChatMessage message) {
    // Avoid duplicate messages
    final existingIndex = state.messages.indexWhere(
      (msg) => msg.messageId == message.messageId,
    );
    
    List<ChatMessage> updatedMessages;
    if (existingIndex != -1) {
      // Update existing message (e.g., temp message with real ID)
      updatedMessages = [...state.messages];
      updatedMessages[existingIndex] = message;
    } else {
      // Add new message
      updatedMessages = [...state.messages, message];
    }
    
    emit(state.copyWith(
      messages: updatedMessages,
      status: ChatStatus.loaded,
    ));
  }

  // Handle WebSocket connection
  void _handleConnected() {
    emit(state.copyWith(isConnected: true));
  }

  // Handle WebSocket disconnection
  void _handleDisconnected() {
    emit(state.copyWith(isConnected: false));
    
    // Attempt to reconnect
    _webSocketService.reconnect();
  }

  // Handle WebSocket errors
  void _handleError(String error) {
    emit(state.copyWith(
      status: ChatStatus.error,
      error: error,
      isConnected: false,
    ));
  }

  // Start typing indicator
  void startTyping() {
    if (!state.isTyping) {
      emit(state.copyWith(isTyping: true));
      _webSocketService.sendTypingIndicator(true);
    }
    
    // Reset typing timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), stopTyping);
  }

  // Stop typing indicator
  void stopTyping() {
    if (state.isTyping) {
      emit(state.copyWith(isTyping: false));
      _webSocketService.sendTypingIndicator(false);
    }
    _typingTimer?.cancel();
  }

  // Create new chat room
  Future<String> createChatRoom(String participantEmail) async {
    if (_currentToken == null) throw Exception('No authentication token');
    
    try {
      final roomId = await ChatService.createChatRoom(participantEmail, _currentToken!);
      await loadChatRooms(); // Refresh chat rooms list
      return roomId;
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        error: 'Failed to create chat room: $e',
      ));
      rethrow;
    }
  }

  // Leave current room
  void leaveRoom() {
    _webSocketService.leaveRoom();
    emit(state.copyWith(
      currentRoomId: null,
      messages: [],
      isConnected: false,
    ));
  }

  // Clear error
  void clearError() {
    emit(state.copyWith(error: null));
  }

  // Refresh messages
  Future<void> refreshMessages() async {
    if (state.currentRoomId != null && _currentToken != null) {
      await joinRoom(state.currentRoomId!);
    }
  }

  // Search messages
  List<ChatMessage> searchMessages(String query) {
    if (query.isEmpty) return state.messages;
    
    return state.messages.where((message) =>
      message.content.toLowerCase().contains(query.toLowerCase()) ||
      message.senderName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  @override
  Future<void> close() {
    _typingTimer?.cancel();
    _webSocketService.dispose();
    return super.close();
  }
}
