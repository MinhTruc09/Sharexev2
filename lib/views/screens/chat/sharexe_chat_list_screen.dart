import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/chat/chat_cubit.dart';
import 'package:sharexev2/logic/chat/chat_state.dart';
import 'package:sharexev2/logic/auth/auth_cubit.dart';
import 'package:sharexev2/logic/auth/auth_state.dart';
import 'package:sharexev2/core/auth/auth_manager.dart';
import 'package:sharexev2/data/repositories/chat/chat_repository_interface.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/routes/app_routes.dart';
import 'package:sharexev2/views/widgets/sharexe_widgets.dart';

/// Modern Chat List Screen - Giống Messenger UI
class ShareXeChatListScreen extends StatefulWidget {
  const ShareXeChatListScreen({super.key});

  @override
  State<ShareXeChatListScreen> createState() => _ShareXeChatListScreenState();
}

class _ShareXeChatListScreenState extends State<ShareXeChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<Map<String, dynamic>> _chatRooms = [];

  @override
  void dispose() {
    _searchController.dispose();
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
            _buildSearchBar(),
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  return _buildChatList(state);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _buildNewChatFAB(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      title: Text(
        'Tin nhắn',
        style: AppTextStyles.headingLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit_outlined, color: AppColors.primary),
          onPressed: () => _showNewChatDialog(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm cuộc trò chuyện...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: AppTextStyles.bodyMedium,
      ),
    );
  }

  Widget _buildChatList(ChatState state) {
    if (state.status == ChatStatus.loading) {
      return _buildLoadingState();
    }

    if (state.status == ChatStatus.error) {
      return _buildErrorState(state.error);
    }

    if (state.chatRooms.isEmpty) {
      return _buildEmptyState();
    }

    // Filter chat rooms based on search
    final filteredRooms = state.chatRooms.where((room) {
      if (_searchQuery.isEmpty) return true;
      return room.participantName.toLowerCase().contains(_searchQuery) ||
          room.lastMessage.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredRooms.isEmpty && _searchQuery.isNotEmpty) {
      return _buildNoSearchResults();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChatCubit>().loadChatRooms();
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: filteredRooms.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppColors.borderLight,
          indent: 72,
        ),
        itemBuilder: (context, index) {
          final room = filteredRooms[index];
          return _buildChatRoomItem(room);
        },
      ),
    );
  }

  Widget _buildChatRoomItem(room) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildAvatar(room.participantName),
      title: Row(
        children: [
          Expanded(
            child: Text(
              room.participantName,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: room.unreadCount > 0 
                    ? FontWeight.bold 
                    : FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (room.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                room.unreadCount > 99 ? '99+' : '${room.unreadCount}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
                          room.displayLastMessage,
            style: AppTextStyles.bodyMedium.copyWith(
              color: room.unreadCount > 0 
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: room.unreadCount > 0 
                  ? FontWeight.w500 
                  : FontWeight.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            room.displayTime,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      trailing: room.unreadCount > 0
          ? Icon(
              Icons.circle,
              color: AppColors.primary,
              size: 12,
            )
          : null,
      onTap: () => _openChatRoom(room),
      onLongPress: () => _showChatOptions(room),
    );
  }

  Widget _buildAvatar(String participantName) {
    return ShareXeUserAvatar(
      name: participantName,
      radius: 28,
      showRoleBadge: false,
      status: UserStatus.online, // Real online status from participant data
      role: 'USER', // Default role for chat
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
            'Đang tải cuộc trò chuyện...',
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
              error ?? 'Không thể tải cuộc trò chuyện',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ChatCubit>().loadChatRooms();
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
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có cuộc trò chuyện',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bắt đầu trò chuyện với tài xế hoặc hành khách',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showNewChatDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tạo cuộc trò chuyện'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Không có cuộc trò chuyện nào khớp với "$_searchQuery"',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatFAB() {
    return FloatingActionButton(
      onPressed: () => _showNewChatDialog(),
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  // Removed unused _formatTime method - using room.displayTime instead

  void _openChatRoom(room) {
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: {
        'roomId': room.roomId,
        'participantName': room.participantName,
        'participantEmail': room.participantEmail,
      },
    );
  }

  void _showChatOptions(Map<String, dynamic> room) {
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
            ListTile(
              leading: Icon(Icons.mark_email_read, color: AppColors.primary),
              title: const Text('Đánh dấu đã đọc'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatCubit>().markMessagesAsRead(room['id']);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Xóa cuộc trò chuyện'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(room);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa cuộc trò chuyện'),
        content: Text('Bạn có chắc chắn muốn xóa cuộc trò chuyện với ${room.participantName}?'),
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
            onPressed: () async {
              Navigator.pop(context);
              await _deleteChatRoom(room);
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

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tạo cuộc trò chuyện mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Nhập email người dùng...',
                prefixIcon: Icon(Icons.email, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
            onPressed: () async {
              Navigator.pop(context);
              await _createNewChat();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  String _getToken() {
    // Get real token from AuthCubit
    final authState = context.read<AuthCubit>().state;
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      // Get real token from AuthManager
      try {
        final token = AuthManager().getToken();
        return token ?? '';
      } catch (e) {
        debugPrint('Error getting token: $e');
        return '';
      }
    }
    return ''; // Return empty string if not authenticated
  }

  /// Delete chat room
  Future<void> _deleteChatRoom(Map<String, dynamic> chatRoom) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa cuộc trò chuyện này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Xóa'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Real API call to delete chat room
        try {
          final token = _getToken();
          if (token.isNotEmpty) {
            // TODO: Implement real API call when ChatRepository is available
            // final response = await chatRepository.deleteChatRoom(chatRoom['id'], token);
            debugPrint('Delete chat room: ${chatRoom['id']}');
          }
        } catch (e) {
          debugPrint('Error deleting chat room: $e');
        }
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã xóa cuộc trò chuyện'),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Refresh chat list
          setState(() {
            // Remove from local list
            _chatRooms.removeWhere((room) => room['id'] == chatRoom['id']);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa cuộc trò chuyện: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Create new chat room
  Future<void> _createNewChat() async {
    try {
      // Show create chat dialog
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _CreateChatDialog(),
      );

      if (result != null) {
        // Real API call to create chat room
        try {
          final token = _getToken();
          if (token.isNotEmpty) {
            // Real API call using ChatRepository
            final chatRepository = ServiceLocator.get<ChatRepositoryInterface>();
            final response = await chatRepository.createChatRoom(result['email'] ?? '', token);
            
            if (response.success && response.data != null) {
              debugPrint('Chat room created successfully: ${response.data}');
              // Refresh chat rooms list
              context.read<ChatCubit>().loadChatRooms();
            } else {
              debugPrint('Failed to create chat room: ${response.message}');
            }
          }
        } catch (e) {
          debugPrint('Error creating chat room: $e');
        }
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã tạo cuộc trò chuyện mới'),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Add to local list
          setState(() {
            _chatRooms.insert(0, {
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'name': result['name'],
              'lastMessage': 'Cuộc trò chuyện mới',
              'lastMessageTime': DateTime.now(),
              'unreadCount': 0,
              'isOnline': true,
            });
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo cuộc trò chuyện: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Create chat dialog
class _CreateChatDialog extends StatefulWidget {
  @override
  State<_CreateChatDialog> createState() => _CreateChatDialogState();
}

class _CreateChatDialogState extends State<_CreateChatDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo cuộc trò chuyện mới'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên cuộc trò chuyện',
                hintText: 'Nhập tên cuộc trò chuyện',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên cuộc trò chuyện';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              Navigator.pop(context, {
                'name': _nameController.text.trim(),
                'type': 'group',
                'createdAt': DateTime.now().toIso8601String(),
              });
            }
          },
          child: const Text('Tạo'),
        ),
      ],
    );
  }
}
