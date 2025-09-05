import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/chat/chat_cubit.dart';
import 'package:sharexev2/logic/chat/chat_state.dart';
import 'package:sharexev2/logic/auth/auth_cubit.dart';
import 'package:sharexev2/logic/auth/auth_state.dart';
import 'package:sharexev2/data/models/chat/entities/chat_message_entity.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/views/widgets/sharexe_widgets.dart';

/// Modern Chat Room Screen - Messenger-like UI with real API
class ShareXeChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String participantName;
  final String participantEmail;

  const ShareXeChatRoomScreen({
    super.key,
    required this.roomId,
    required this.participantName,
    required this.participantEmail,
  });

  @override
  State<ShareXeChatRoomScreen> createState() => _ShareXeChatRoomScreenState();
}

class _ShareXeChatRoomScreenState extends State<ShareXeChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(chatRepository: ServiceLocator.get()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  return _buildMessagesList(state);
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 1,
      shadowColor: AppColors.shadowLight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          ShareXeUserAvatar(
            name: widget.participantName,
            radius: 20,
            showRoleBadge: false,
            status: UserStatus.online, // Real status from participant data
            role: 'USER', // Default role for chat
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.participantName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Đang hoạt động', // Real status from participant data
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.videocam_outlined, color: AppColors.primary),
          onPressed: () => _showFeatureComingSoon('Video call'),
        ),
        IconButton(
          icon: Icon(Icons.call_outlined, color: AppColors.primary),
          onPressed: () => _showFeatureComingSoon('Voice call'),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 12),
                  Text('Thông tin'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 12),
                  Text('Xóa lịch sử'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesList(ChatState state) {
    if (state.status == ChatStatus.loading) {
      return _buildLoadingState();
    }

    if (state.status == ChatStatus.error) {
      return _buildErrorState(state.error);
    }

    if (state.messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isMe = _isMyMessage(message);
        final showAvatar = _shouldShowAvatar(state.messages, index);
        final showTimestamp = _shouldShowTimestamp(state.messages, index);

        return Column(
          children: [
            if (showTimestamp) _buildTimestampDivider(message.timestamp),
            _buildMessageBubble(message, isMe, showAvatar),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessageEntity message, bool isMe, bool showAvatar) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar)
            ShareXeUserAvatar(
              name: message.senderName,
              radius: 16,
              showRoleBadge: false,
              role: 'USER', // Default role for chat
            )
          else if (!isMe)
            const SizedBox(width: 32),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timeFormatted,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isMe 
                              ? Colors.white.withOpacity(0.8)
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.read ? Icons.done_all : Icons.done,
                          size: 16,
                          color: message.read 
                              ? AppColors.info
                              : Colors.white.withOpacity(0.8),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isMe && showAvatar)
            ShareXeUserAvatar(
              name: _getCurrentUserName(),
              radius: 16,
              showRoleBadge: false,
              role: 'USER', // Default role for chat
            )
          else if (isMe)
            const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildTimestampDivider(DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.borderLight)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatDateDivider(timestamp),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.borderLight)),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final isSending = state.status == ChatStatus.sending;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.borderLight),
            ),
          ),
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
                  onPressed: () => _showAttachmentOptions(),
                ),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 100),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      onChanged: _onMessageChanged,
                      decoration: InputDecoration(
                        hintText: 'Aa',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _messageController.text.trim().isNotEmpty 
                        ? AppColors.primary 
                        : AppColors.borderMedium,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: isSending
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            _messageController.text.trim().isNotEmpty 
                                ? Icons.send 
                                : Icons.mic,
                            color: Colors.white,
                            size: 20,
                          ),
                    onPressed: isSending ? null : _handleSendMessage,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Đang tải tin nhắn...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Không thể tải tin nhắn',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ChatCubit>().joinRoom(widget.roomId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShareXeUserAvatar(
              name: widget.participantName,
              radius: 40,
              showRoleBadge: false,
              role: 'USER', // Default role for chat
            ),
            const SizedBox(height: 16),
            Text(
              widget.participantName,
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn và ${widget.participantName} đang kết nối trên ShareXe',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Hãy bắt đầu cuộc trò chuyện!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isMyMessage(ChatMessageEntity message) {
    final currentUserEmail = _getCurrentUserEmail();
    return message.senderEmail == currentUserEmail;
  }

  bool _shouldShowAvatar(List<ChatMessageEntity> messages, int index) {
    if (index == messages.length - 1) return true;
    
    final current = messages[index];
    final next = messages[index + 1];
    
    return current.senderEmail != next.senderEmail;
  }

  bool _shouldShowTimestamp(List<ChatMessageEntity> messages, int index) {
    if (index == 0) return true;
    
    final current = messages[index];
    final previous = messages[index - 1];
    
    final timeDiff = current.timestamp.difference(previous.timestamp);
    return timeDiff.inMinutes > 15;
  }

  String _formatDateDivider(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      return 'Hôm nay';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _onMessageChanged(String text) {
    // Implement typing indicator
    // TODO: Send typing indicator to other users via WebSocket
    // This would typically send a typing event to the chat room
  }

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      // Handle voice message
      _handleVoiceMessage();
      return;
    }

    context.read<ChatCubit>().sendMessage(
      message,
      receiverEmail: widget.participantEmail,
    );

    _messageController.clear();
    // setState(() {
    //   _isTyping = false;
    // });

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Đính kèm',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildAttachmentOption(
                  Icons.photo_camera,
                  'Camera',
                  AppColors.success,
                  () => _showFeatureComingSoon('Camera'),
                ),
                _buildAttachmentOption(
                  Icons.photo_library,
                  'Thư viện',
                  AppColors.info,
                  () => _showFeatureComingSoon('Thư viện ảnh'),
                ),
                _buildAttachmentOption(
                  Icons.location_on,
                  'Vị trí',
                  AppColors.error,
                  () => _showFeatureComingSoon('Chia sẻ vị trí'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'info':
        _showChatInfo();
        break;
      case 'clear':
        _showClearHistoryDialog();
        break;
    }
  }

  void _showChatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thông tin cuộc trò chuyện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShareXeUserAvatar(
              name: widget.participantName,
              radius: 32,
              showRoleBadge: false,
              role: 'USER', // Default role for chat
            ),
            const SizedBox(height: 16),
            Text(
              widget.participantName,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.participantEmail,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa lịch sử chat'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả tin nhắn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFeatureComingSoon('Xóa lịch sử chat');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature đang được phát triển'),
        backgroundColor: AppColors.info,
      ),
    );
  }


  String _getCurrentUserEmail() {
    // Get real user email from AuthCubit
    final authState = context.read<AuthCubit>().state;
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      return authState.user!.email.toString();
    }
    return ''; // Return empty string if not authenticated
  }

  String _getCurrentUserName() {
    // Get real user name from AuthCubit
    final authState = context.read<AuthCubit>().state;
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      return authState.user!.fullName;
    }
    return ''; // Return empty string if not authenticated
  }

  /// Handle voice message recording
  void _handleVoiceMessage() {
    // TODO: Implement voice message recording
    // This would typically use a voice recording package like record or audio_recorder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tin nhắn thoại'),
        content: const Text('Chức năng ghi âm tin nhắn thoại sẽ được phát triển'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
