import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/chat/chat_cubit.dart';
import 'package:sharexev2/logic/chat/chat_state.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/presentation/widgets/chat/chat_bubble.dart';
import 'package:sharexev2/presentation/widgets/chat/chat_input.dart';

class ChatPage extends StatefulWidget {
  final String roomId;
  final String participantName;
  final String? participantEmail;

  const ChatPage({
    super.key,
    required this.roomId,
    required this.participantName,
    this.participantEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Join the chat room when page loads
    context.read<ChatCubit>().joinRoom(widget.roomId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
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
                    context.read<ChatCubit>().joinRoom(widget.roomId);
                  },
                ),
              ),
            );
          }

          // Auto-scroll to bottom when new messages arrive
          if (state.messages.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          }
        },
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.status == ChatStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.messages.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildMessagesList(state);
                },
              ),
            ),

            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                return ChatInput(
                  onSendMessage: (message) {
                    context.read<ChatCubit>().sendMessage(
                      message,
                      receiverEmail: widget.participantEmail,
                    );
                  },
                  onStartTyping: () {
                    context.read<ChatCubit>().startTyping();
                  },
                  onStopTyping: () {
                    context.read<ChatCubit>().stopTyping();
                  },
                  isConnected: state.isConnected,
                  isSending: state.status == ChatStatus.sending,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.passengerPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Text(
              widget.participantName.isNotEmpty
                  ? widget.participantName[0].toUpperCase()
                  : '?',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.passengerPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.participantName,
                  style: AppTheme.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state.typingUser != null) {
                      return Text(
                        'typing...',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }

                    return Text(
                      state.isConnected ? 'Online' : 'Connecting...',
                      style: AppTheme.bodySmall.copyWith(
                        color:
                            state.isConnected
                                ? Colors.green.shade300
                                : Colors.white70,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () {
            // TODO: Implement voice call
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Voice call feature coming soon')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            _showChatOptions();
          },
        ),
      ],
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
            'No messages yet',
            style: AppTheme.headingSmall.copyWith(color: Colors.grey.shade600),
          ),
          SizedBox(height: AppTheme.spacingS),
          Text(
            'Start a conversation with ${widget.participantName}',
            style: AppTheme.bodyMedium.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChatCubit>().refreshMessages();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
        itemCount:
            state.sortedMessages.length + (state.typingUser != null ? 1 : 0),
        itemBuilder: (context, index) {
          // Show typing indicator at the end
          if (index == state.sortedMessages.length &&
              state.typingUser != null) {
            return TypingIndicator(userName: state.typingUser!);
          }

          final message = state.sortedMessages[index];
          final previousMessage =
              index > 0 ? state.sortedMessages[index - 1] : null;

          // Group messages from same sender
          final showAvatar =
              previousMessage == null ||
              previousMessage.senderEmail != message.senderEmail;

          // Show timestamp for first message or if time gap > 5 minutes
          final showTimestamp =
              previousMessage == null ||
              message.timestamp
                      .difference(previousMessage.timestamp)
                      .inMinutes >
                  5;

          return ChatBubble(
            message: message,
            showAvatar: showAvatar,
            showTimestamp: showTimestamp,
          );
        },
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusL),
                topRight: Radius.circular(AppTheme.radiusL),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(top: AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text('Search Messages'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement search
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text('Block User'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement block user
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('Report'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Implement report
                  },
                ),

                SizedBox(height: AppTheme.spacingL),
              ],
            ),
          ),
    );
  }
}
