import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/chat/chat_cubit.dart';
import 'package:sharexev2/logic/chat/chat_state.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/presentation/pages/chat/chat_page.dart';
import 'package:sharexev2/data/services/chat_service.dart';
import 'package:sharexev2/data/repositories/real_auth_repository.dart';

class ChatRoomsPage extends StatefulWidget {
  const ChatRoomsPage({super.key});

  @override
  State<ChatRoomsPage> createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  @override
  void initState() {
    super.initState();
    // Initialize chat with mock token
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Try to load a real token from the RealAuthRepository.
      RealAuthRepository().getAuthToken().then((token) {
        final useToken = token ?? 'no_token_available';
        context.read<ChatCubit>().initialize(useToken);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.passengerPrimary,
        foregroundColor: Colors.white,
        title: Text(
          'Messages',
          style: AppTheme.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showNewChatDialog();
            },
          ),
        ],
      ),
      body: BlocListener<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<ChatCubit>().clearError();
                    context.read<ChatCubit>().loadChatRooms();
                  },
                ),
              ),
            );
          }
        },
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state.status == ChatStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.chatRooms.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatCubit>().loadChatRooms();
              },
              child: ListView.builder(
                itemCount: state.chatRooms.length,
                itemBuilder: (context, index) {
                  final room = state.chatRooms[index];
                  return _buildChatRoomTile(room);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            'No conversations yet',
            style: AppTheme.headingSmall.copyWith(color: Colors.grey.shade600),
          ),
          SizedBox(height: AppTheme.spacingS),
          Text(
            'Start chatting with drivers or passengers',
            style: AppTheme.bodyMedium.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spacingL),
          ElevatedButton.icon(
            onPressed: () {
              _showNewChatDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.passengerPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Start New Chat',
              style: AppTheme.labelMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomTile(Map<String, dynamic> room) {
    final participantName = room['participantName'] ?? 'Unknown';
    final lastMessage = room['lastMessage'] ?? '';
    final lastMessageTime =
        room['lastMessageTime'] != null
            ? DateTime.parse(room['lastMessageTime'])
            : DateTime.now();
    final unreadCount = room['unreadCount'] ?? 0;
    final roomId = room['roomId'] ?? '';

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: AppTheme.shadowLight,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(AppTheme.spacingM),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.driverPrimary,
              child: Text(
                participantName.isNotEmpty
                    ? participantName[0].toUpperCase()
                    : '?',
                style: AppTheme.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          participantName,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppTheme.spacingXs),
            Text(
              lastMessage.isNotEmpty ? lastMessage : 'No messages yet',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                fontWeight:
                    unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppTheme.spacingXs),
            Text(
              ChatService.formatTimestamp(lastMessageTime),
              style: AppTheme.bodySmall.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: () {
          _openChatRoom(roomId, participantName, room['participantEmail']);
        },
      ),
    );
  }

  void _openChatRoom(
    String roomId,
    String participantName,
    String? participantEmail,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BlocProvider.value(
              value: context.read<ChatCubit>(),
              child: ChatPage(
                roomId: roomId,
                participantName: participantName,
                participantEmail: participantEmail,
              ),
            ),
      ),
    ).then((_) {
      // Refresh chat rooms when returning from chat
      context.read<ChatCubit>().loadChatRooms();
    });
  }

  void _showNewChatDialog() {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Start New Chat'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter email to start chat',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  if (email.isNotEmpty && email.contains('@')) {
                    try {
                      Navigator.pop(context);

                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      final roomId = await context
                          .read<ChatCubit>()
                          .createChatRoom(email);

                      if (mounted) {
                        Navigator.pop(context); // Close loading
                        _openChatRoom(roomId, email.split('@')[0], email);
                      }
                    } catch (e) {
                      if (mounted) {
                        Navigator.pop(context); // Close loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to create chat: $e')),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid email'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.passengerPrimary,
                ),
                child: const Text(
                  'Start Chat',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
