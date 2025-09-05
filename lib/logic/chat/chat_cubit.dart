import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/chat/chat_repository_interface.dart';
import 'package:sharexev2/logic/chat/chat_state.dart';
import 'package:sharexev2/data/models/chat/entities/chat_message_entity.dart';
import 'package:sharexev2/data/models/chat/entities/chat_room.dart';
import 'package:sharexev2/core/auth/auth_manager.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepositoryInterface? _chatRepository;
  Timer? _typingTimer;
  String? _currentToken;

  ChatCubit({required ChatRepositoryInterface? chatRepository})
    : _chatRepository = chatRepository,
      super(const ChatState()) {
    // Chat API implementation - no WebSocket needed
  }

  void _setupWebSocketCallbacks() {
    // Not needed for Chat API implementation
    // All communication goes through HTTP API calls
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

      final roomsResp = await _chatRepository?.getChatRooms(_currentToken!);
      final rooms = roomsResp?.data ?? [];

      // Use ChatRoom directly (from chat_room.dart)
      final roomEntities = rooms;

      final totalUnread = rooms.fold<int>(
        0,
        (sum, room) => sum + (room.unreadCount),
      );

      emit(
        state.copyWith(
          status: ChatStatus.loaded,
          chatRooms: roomEntities,
          unreadCount: totalUnread,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.error, error: e.toString()));
    }
  }

  // Join chat room
  Future<void> joinRoom(String roomId) async {
    if (_currentToken == null) return;

    try {
      emit(state.copyWith(status: ChatStatus.loading));

      // Load message history
      final resp = await _chatRepository?.fetchMessages(roomId, _currentToken!);
      final messages = resp?.data ?? [];

      // Chat API implementation - no WebSocket connection needed
      // Messages are fetched via HTTP API calls

      // Mark messages as read
      await _chatRepository?.markMessagesAsRead(roomId, _currentToken!);

      emit(
        state.copyWith(
          status: ChatStatus.loaded,
          messages: messages,
          currentRoomId: roomId,
          isConnected: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.error, error: e.toString()));
    }
  }

  // Send message
  Future<void> sendMessage(String content, {String? receiverEmail}) async {
    if (_currentToken == null || state.currentRoomId == null) return;

    if (content.trim().isEmpty || content.length > 2000) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          error: 'Invalid message content',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(status: ChatStatus.sending));

      final message = ChatMessageEntity(
        senderEmail: _getCurrentUserEmail(), // Get from auth service
        receiverEmail: receiverEmail ?? _getCurrentRoomParticipantEmail(),
        senderName: _getCurrentUserName(), // Get from auth service
        content: content,
        roomId: state.currentRoomId!,
        timestamp: DateTime.now(),
        read: false,
      );

      // Add message optimistically to UI
      final updatedMessages = [...state.messages, message];
      emit(
        state.copyWith(status: ChatStatus.loaded, messages: updatedMessages),
      );

      // Send message via Chat API (POST /api/chat/test/{roomId})
      if (_chatRepository != null) {
        final response = await _chatRepository!.sendMessage(
          state.currentRoomId!,
          message,
          _currentToken!,
        );

        if (response.success && response.data != null) {
          // Message sent successfully, update with server response
          final updatedMessages = [...state.messages];
          final lastIndex = updatedMessages.length - 1;
          if (lastIndex >= 0) {
            updatedMessages[lastIndex] = response.data!;
          }

          emit(
            state.copyWith(
              status: ChatStatus.loaded,
              messages: updatedMessages,
            ),
          );

          // Mark messages as read after sending (PUT /api/chat/{roomId}/mark-read)
          await _chatRepository!.markMessagesAsRead(
            state.currentRoomId!,
            _currentToken!,
          );
        } else {
          // Failed to send message
          emit(
            state.copyWith(
              status: ChatStatus.error,
              error: response.message ?? 'Failed to send message',
            ),
          );
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          error: 'Failed to send message: $e',
        ),
      );
    }
  }

  // Handle new message from Chat API (polling or push notification)
  void _handleNewMessage(ChatMessageEntity message) {
    // Check if message already exists to avoid duplicates
    final existingIndex = state.messages.indexWhere(
      (msg) =>
          msg.content == message.content && msg.timestamp == message.timestamp,
    );

    List<ChatMessageEntity> updatedMessages;
    if (existingIndex != -1) {
      // Update existing message (e.g., temp message with real ID)
      updatedMessages = [...state.messages];
      updatedMessages[existingIndex] = message;
    } else {
      // Add new message
      updatedMessages = [...state.messages, message];
    }

    emit(state.copyWith(messages: updatedMessages, status: ChatStatus.loaded));
  }

  // Handle API connection status
  void _handleConnected() {
    emit(state.copyWith(isConnected: true));
  }

  // Handle API disconnection status
  void _handleDisconnected() {
    emit(state.copyWith(isConnected: false));
  }

  // Handle API errors
  void _handleError(String error) {
    emit(
      state.copyWith(
        status: ChatStatus.error,
        error: error,
        isConnected: false,
      ),
    );
  }

  // Start typing indicator
  void startTyping() {
    if (!state.isTyping) {
      emit(state.copyWith(isTyping: true));
      // Local typing indicator only - backend API doesn't support real-time typing
    }

    // Reset typing timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), stopTyping);
  }

  // Stop typing indicator
  void stopTyping() {
    if (state.isTyping) {
      emit(state.copyWith(isTyping: false));
      // Local typing indicator only
    }
    _typingTimer?.cancel();
  }

  // Create new chat room
  Future<String> createChatRoom(String participantEmail) async {
    if (_currentToken == null) throw Exception('No authentication token');

    try {
      final response = await _chatRepository?.createChatRoom(
        participantEmail,
        _currentToken!,
      );
      await loadChatRooms(); // Refresh chat rooms list
      return response?.data ?? '';
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          error: 'Failed to create chat room: $e',
        ),
      );
      rethrow;
    }
  }

  // Leave current room
  void leaveRoom() {
    // No WebSocket to disconnect - just clear local state
    emit(state.copyWith(currentRoomId: null, messages: [], isConnected: false));
  }

  // Clear error
  void clearError() {
    emit(state.copyWith(error: null));
  }

  // Refresh messages from Chat API
  Future<void> refreshMessages() async {
    if (state.currentRoomId != null && _currentToken != null) {
      await joinRoom(state.currentRoomId!);
    }
  }

  // Poll for new messages (alternative to WebSocket)
  Future<void> pollForNewMessages() async {
    if (state.currentRoomId == null || _currentToken == null) return;

    try {
      final response = await _chatRepository?.fetchMessages(
        state.currentRoomId!,
        _currentToken!,
      );

      if (response?.success == true && response?.data != null) {
        final newMessages = response!.data!;

        // Check for new messages
        if (newMessages.length > state.messages.length) {
          // Add only new messages
          final existingIds =
              state.messages
                  .map((m) => m.content + m.timestamp.toString())
                  .toSet();
          final messagesToAdd =
              newMessages
                  .where(
                    (msg) =>
                        !existingIds.contains(
                          msg.content + msg.timestamp.toString(),
                        ),
                  )
                  .toList();

          if (messagesToAdd.isNotEmpty) {
            final updatedMessages = [...state.messages, ...messagesToAdd];
            emit(
              state.copyWith(
                messages: updatedMessages,
                status: ChatStatus.loaded,
              ),
            );
          }
        }
      }
    } catch (e) {
      // Silent fail for polling - don't show error to user
      print('Polling failed: $e');
    }
  }

  // Search messages
  List<ChatMessageEntity> searchMessages(String query) {
    if (query.isEmpty) return state.messages;

    final lower = query.toLowerCase();
    final results = <ChatMessageEntity>[];
    for (final message in state.messages) {
      final content = message.content.toLowerCase();
      final sender = message.senderName.toLowerCase();
      if (content.contains(lower) || sender.contains(lower)) {
        results.add(message);
      }
    }
    return results;
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String roomId) async {
    if (_currentToken == null) return;

    try {
      await _chatRepository?.markMessagesAsRead(roomId, _currentToken!);
      
      // Update UI to mark messages as read
      final updatedMessages = state.messages.map((msg) {
        if (msg.roomId == roomId) {
          return ChatMessageEntity(
            senderEmail: msg.senderEmail,
            receiverEmail: msg.receiverEmail,
            senderName: msg.senderName,
            content: msg.content,
            roomId: msg.roomId,
            timestamp: msg.timestamp,
            read: true,
          );
        }
        return msg;
      }).toList();

      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      // Silent fail - don't show error for mark as read
      print('Failed to mark messages as read: $e');
    }
  }

  // Helper methods for getting user information
  String _getCurrentUserEmail() {
    // Get from AuthManager
    final currentUser = AuthManager.instance.currentUser;
    return currentUser?.email.value ?? 'user@sharexe.com';
  }

  String _getCurrentUserName() {
    // Get from AuthManager
    final currentUser = AuthManager.instance.currentUser;
    return currentUser?.fullName ?? 'User';
  }

  // Start real-time polling for new messages
  void startPolling() {
    // Poll every 3 seconds for new messages
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (state.currentRoomId != null && _currentToken != null) {
        pollForNewMessages();
      } else {
        timer.cancel();
      }
    });
  }

  String _getCurrentRoomParticipantEmail() {
    // Get participant email from current chat room
    if (state.currentRoomId != null) {
      final currentRoom = state.chatRooms.firstWhere(
        (room) => room.roomId == state.currentRoomId,
        orElse:
            () => ChatRoom(
              roomId: '',
              participantName: '',
              participantEmail: '',
              lastMessage: '',
              lastMessageTime: null,
              unreadCount: 0,
            ),
      );
      return currentRoom.participantEmail;
    }
    return '';
  }

  @override
  Future<void> close() {
    _typingTimer?.cancel();
    // No WebSocket to disconnect - using Chat API
    return super.close();
  }
}
