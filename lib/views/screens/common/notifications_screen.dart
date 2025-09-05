import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/notification/notification_cubit.dart';
// NotificationState is imported via part directive in cubit
import 'package:sharexev2/data/models/notification/entities/notification_entity.dart';
import 'package:sharexev2/config/theme.dart';
// import 'package:sharexev2/views/widgets/sharexe_widgets.dart'; // Unused
// import 'package:sharexev2/routes/app_routes.dart'; // Unused

/// Notifications Screen - Real-time notifications cho cả Passenger và Driver
class NotificationsScreen extends StatefulWidget {
  final String userRole; // 'PASSENGER' or 'DRIVER'
  
  const NotificationsScreen({
    super.key,
    required this.userRole,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  bool _isMarkingAllAsRead = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more notifications when near bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Implement load more when available
      final state = context.read<NotificationCubit>().state;
      if (state.status == NotificationStatus.loaded && 
          state.notifications.isNotEmpty) {
        // TODO: Implement loadMoreNotifications method in NotificationCubit
        // context.read<NotificationCubit>().loadMoreNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocProvider(
      create: (_) => NotificationCubit(
        notificationRepository: ServiceLocator.get(),
      )..loadNotifications(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildFilterTabs(),
            _buildQuickActions(),
            Expanded(
              child: BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  return _buildNotificationsList(state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: widget.userRole == 'DRIVER' 
          ? AppColors.driverPrimary 
          : AppColors.passengerPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông báo',
            style: AppTextStyles.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.userRole == 'DRIVER' ? 'Tài xế' : 'Hành khách',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<NotificationCubit>().loadNotifications();
          },
        ),
        IconButton(
          icon: _isMarkingAllAsRead 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.mark_email_read),
          onPressed: _isMarkingAllAsRead ? null : _markAllAsRead,
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Tất cả', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Chưa đọc', 'unread'),
          const SizedBox(width: 8),
          _buildFilterChip('Đã đọc', 'read'),
          const SizedBox(width: 8),
          if (widget.userRole == 'DRIVER') ...[
            _buildFilterChip('Đặt chuyến', 'booking'),
            const SizedBox(width: 8),
            _buildFilterChip('Hệ thống', 'system'),
          ] else ...[
            _buildFilterChip('Chuyến đi', 'ride'),
            const SizedBox(width: 8),
            _buildFilterChip('Khuyến mãi', 'promotion'),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (widget.userRole == 'DRIVER' 
                  ? AppColors.driverPrimary 
                  : AppColors.passengerPrimary)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? (widget.userRole == 'DRIVER' 
                    ? AppColors.driverPrimary 
                    : AppColors.passengerPrimary)
                : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              'Đánh dấu tất cả đã đọc',
              Icons.mark_email_read,
              () => _markAllAsRead(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickActionButton(
              'Xóa tất cả',
              Icons.delete_sweep,
              () => _deleteAllNotifications(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(NotificationState state) {
    if (state.status == NotificationStatus.loading) {
      return _buildLoadingState();
    }

    if (state.status == NotificationStatus.error) {
      return _buildErrorState(state.error);
    }

    // Filter notifications based on selected filter
    final filteredNotifications = _filterNotifications(state.notifications);

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationCubit>().loadNotifications();
      },
      color: widget.userRole == 'DRIVER' 
          ? AppColors.driverPrimary 
          : AppColors.passengerPrimary,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredNotifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  List<NotificationEntity> _filterNotifications(List<NotificationEntity> notifications) {
    switch (_selectedFilter) {
      case 'unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'read':
        return notifications.where((n) => n.isRead).toList();
      case 'booking':
        return notifications.where((n) => n.type == 'booking').toList();
      case 'ride':
        return notifications.where((n) => n.type == 'ride').toList();
      case 'system':
        return notifications.where((n) => n.type == 'system').toList();
      case 'promotion':
        return notifications.where((n) => n.type == 'promotion').toList();
      default:
        return notifications;
    }
  }

  Widget _buildNotificationCard(NotificationEntity notification) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead ? AppColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: notification.isRead 
            ? Border.all(color: AppColors.borderLight)
            : Border.all(
                color: widget.userRole == 'DRIVER' 
                    ? AppColors.driverPrimary.withOpacity(0.3)
                    : AppColors.passengerPrimary.withOpacity(0.3),
                width: 2,
              ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleNotificationTap(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildNotificationIcon(notification),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: notification.isRead 
                                    ? FontWeight.w600 
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: widget.userRole == 'DRIVER' 
                                    ? AppColors.driverPrimary 
                                    : AppColors.passengerPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(notification.createdAt),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          _buildNotificationTypeChip(notification.type),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteNotification(notification),
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationEntity notification) {
    IconData icon;
    Color color;
    
    switch (notification.type) {
      case 'booking':
        icon = Icons.assignment;
        color = AppColors.info;
        break;
      case 'ride':
        icon = Icons.directions_car;
        color = AppColors.success;
        break;
      case 'system':
        icon = Icons.settings;
        color = AppColors.warning;
        break;
      case 'promotion':
        icon = Icons.local_offer;
        color = AppColors.passengerPrimary;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.textSecondary;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildNotificationTypeChip(String type) {
    String label;
    Color color;
    
    switch (type) {
      case 'booking':
        label = 'Đặt chuyến';
        color = AppColors.info;
        break;
      case 'ride':
        label = 'Chuyến đi';
        color = AppColors.success;
        break;
      case 'system':
        label = 'Hệ thống';
        color = AppColors.warning;
        break;
      case 'promotion':
        label = 'Khuyến mãi';
        color = AppColors.passengerPrimary;
        break;
      default:
        label = 'Thông báo';
        color = AppColors.textSecondary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: widget.userRole == 'DRIVER' 
                ? AppColors.driverPrimary 
                : AppColors.passengerPrimary,
          ),
          const SizedBox(height: 16),
          Text(
            'Đang tải thông báo...',
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
              error ?? 'Không thể tải thông báo',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<NotificationCubit>().loadNotifications();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.userRole == 'DRIVER' 
                    ? AppColors.driverPrimary 
                    : AppColors.passengerPrimary,
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
              Icons.notifications_none,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Không có thông báo nào',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.userRole == 'DRIVER' 
                  ? 'Các thông báo về đặt chuyến sẽ hiển thị ở đây'
                  : 'Các thông báo về chuyến đi sẽ hiển thị ở đây',
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

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _handleNotificationTap(NotificationEntity notification) {
    // Mark as read
    if (!notification.isRead) {
      context.read<NotificationCubit>().markAsRead(notification.id);
    }
    
    // Navigate based on notification type
    switch (notification.type) {
      case 'booking':
        if (widget.userRole == 'DRIVER') {
          Navigator.pushNamed(context, '/driver-notifications');
        } else {
          Navigator.pushNamed(context, '/history');
        }
        break;
      case 'ride':
        Navigator.pushNamed(context, '/history');
        break;
      case 'promotion':
        // Navigate to promotions screen
        Navigator.pushNamed(
          context,
          '/notification/promotions',
        );
        break;
      default:
        // No specific navigation
        break;
    }
  }

  void _markAllAsRead() async {
    setState(() {
      _isMarkingAllAsRead = true;
    });
    
    try {
      await context.read<NotificationCubit>().markAllAsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã đánh dấu tất cả là đã đọc'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAllAsRead = false;
        });
      }
    }
  }

  void _deleteAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa tất cả thông báo'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả thông báo?'),
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
              context.read<NotificationCubit>().deleteAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã xóa tất cả thông báo'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }

  void _deleteNotification(NotificationEntity notification) {
    context.read<NotificationCubit>().deleteNotification(notification.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã xóa thông báo'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
