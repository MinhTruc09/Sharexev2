import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/routes/app_routes.dart';

/// Floating Chat Button cho ShareXe - Liên hệ nhanh với tài xế/hành khách
class ShareXeChatButton extends StatefulWidget {
  final String? chatRoomId;
  final String? participantName;
  final String? participantEmail;
  final String? participantRole; // 'DRIVER' hoặc 'PASSENGER'
  final int unreadCount;
  final bool isOnline;
  
  const ShareXeChatButton({
    super.key,
    this.chatRoomId,
    this.participantName,
    this.participantEmail,
    this.participantRole,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  @override
  State<ShareXeChatButton> createState() => _ShareXeChatButtonState();
}

class _ShareXeChatButtonState extends State<ShareXeChatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _openDirectChat() {
    // Open direct chat with specific participant
    if (widget.chatRoomId != null && 
        widget.participantName != null && 
        widget.participantEmail != null) {
      Navigator.pushNamed(
        context, 
        AppRoutes.chat,
        arguments: {
          'roomId': widget.chatRoomId,
          'participantName': widget.participantName,
          'participantEmail': widget.participantEmail,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không có thông tin chat'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _openChatList() {
    // Navigate to chat rooms list
    Navigator.pushNamed(context, AppRoutes.chatRooms);
  }

  void _openChat() {
    // Main chat button action - if has participant info, open direct chat
    // Otherwise open chat list
    if (widget.participantName != null) {
      _openDirectChat();
    } else {
      _openChatList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expanded options
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? 200 : 0,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.participantName != null) ...[
                    // Direct chat with specific participant
                    _buildQuickActionButton(
                      icon: Icons.chat_bubble,
                      label: 'Chat ${_getRoleText()}',
                      color: AppColors.primary,
                      onTap: _openDirectChat,
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Chat rooms list
                  _buildQuickActionButton(
                    icon: Icons.forum,
                    label: 'Danh sách chat',
                    color: AppColors.passengerPrimary,
                    onTap: _openChatList,
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionButton(
                    icon: Icons.support_agent,
                    label: 'Hỗ trợ ShareXe',
                    color: AppColors.info,
                    onTap: () => _showSupportDialog(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Main chat button
          GestureDetector(
            onTap: widget.participantName != null ? _openChat : _toggleExpanded,
            onLongPress: _toggleExpanded,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.participantName != null 
                                ? Icons.chat_bubble
                                : _isExpanded ? Icons.close : Icons.chat_bubble,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        
                        // Online status indicator
                        if (widget.isOnline)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        
                        // Unread count badge
                        if (widget.unreadCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Text(
                                widget.unreadCount > 99 ? '99+' : '${widget.unreadCount}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Participant info
          if (widget.participantName != null && !_isExpanded)
            Container(
              margin: const EdgeInsets.only(top: 8, right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.participantRole == 'DRIVER' 
                        ? Icons.local_taxi 
                        : Icons.person,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.participantName!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleText() {
    if (widget.participantRole == 'DRIVER') return 'tài xế';
    if (widget.participantRole == 'PASSENGER') return 'hành khách';
    return 'người dùng';
  }


  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.support_agent, color: AppColors.info),
            const SizedBox(width: 8),
            const Text('Hỗ trợ ShareXe'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone, color: AppColors.success),
              title: const Text('Hotline: 1900-SHARE'),
              subtitle: const Text('24/7 hỗ trợ khách hàng'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement call to hotline when url_launcher is added
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Hotline: 1900-SHARE (Demo)'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.email, color: AppColors.info),
              title: const Text('Email: support@sharexe.vn'),
              subtitle: const Text('Gửi phản hồi và góp ý'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement email support when url_launcher is added
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Email: support@sharexe.vn (Demo)'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
