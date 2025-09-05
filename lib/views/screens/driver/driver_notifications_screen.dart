import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/booking/booking_cubit.dart';
import 'package:sharexev2/logic/booking/booking_state.dart';
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart' as booking_entity;
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/views/widgets/sharexe_widgets.dart';
import 'package:sharexev2/routes/app_routes.dart';

/// Thông báo tài xế - Duyệt/từ chối booking requests
class DriverNotificationsScreen extends StatefulWidget {
  const DriverNotificationsScreen({super.key});

  @override
  State<DriverNotificationsScreen> createState() => _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';

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
      final state = context.read<BookingCubit>().state;
      if (state.status == BookingStatus.loaded && 
          state.bookings != null && 
          state.bookings!.isNotEmpty &&
          state.hasMoreBookings &&
          !state.isLoadingMore) {
        context.read<BookingCubit>().loadMoreBookings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocProvider(
      create: (_) => BookingCubit(ServiceLocator.get())..loadBookings(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildFilterTabs(),
            Expanded(
              child: _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.driverPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Thông báo',
        style: AppTextStyles.headingMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<BookingCubit>().loadBookings();
          },
        ),
        IconButton(
          icon: const Icon(Icons.mark_email_read),
          onPressed: () => _markAllAsRead(),
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
          _buildFilterChip('Chờ duyệt', 'pending'),
          const SizedBox(width: 8),
          _buildFilterChip('Đã duyệt', 'accepted'),
          const SizedBox(width: 8),
          _buildFilterChip('Đã từ chối', 'rejected'),
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
          color: isSelected ? AppColors.driverPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.driverPrimary : AppColors.borderLight,
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

  Widget _buildNotificationsList() {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        if (state.status == BookingStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == BookingStatus.error) {
          return _buildErrorState(state.error);
        }

        final bookings = state.bookings ?? [];
        final filteredBookings = _filterBookings(bookings);

        if (filteredBookings.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<BookingCubit>().loadBookings();
          },
          color: AppColors.driverPrimary,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: filteredBookings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = filteredBookings[index];
              return _buildNotificationCard(booking);
            },
          ),
        );
      },
    );
  }

  // Mock data removed - using real API data from BookingCubit

  List<booking_entity.BookingEntity> _filterBookings(List<booking_entity.BookingEntity> bookings) {
    switch (_selectedFilter) {
      case 'pending':
        return bookings.where((b) => b.status == booking_entity.BookingStatus.pending).toList();
      case 'accepted':
        return bookings.where((b) => b.status == booking_entity.BookingStatus.accepted).toList();
      case 'rejected':
        return bookings.where((b) => b.status == booking_entity.BookingStatus.rejected).toList();
      default:
        return bookings;
    }
  }

  Widget _buildNotificationCard(booking_entity.BookingEntity booking) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
          onTap: () => _showBookingDetails(booking),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status and time
                Row(
                  children: [
                    _buildStatusChip(booking.status),
                    const Spacer(),
                    Text(
                      _formatTime(booking.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Passenger info
                Row(
                  children: [
                    ShareXeUserAvatar(
                      name: booking.passengerName,
                      imageUrl: booking.passengerAvatarUrl,
                      role: 'PASSENGER',
                      status: UserStatus.online,
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.passengerName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${booking.seatsBooked} ghế • ${booking.formattedPricePerSeat}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      booking.formattedTotalPrice,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.driverPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Route information
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.driverPrimary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.departure,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.arrow_downward,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.destination,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Action buttons
                if (booking.status == booking_entity.BookingStatus.pending) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptBooking(booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text('Chấp nhận'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rejectBooking(booking),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: AppColors.error),
                          ),
                          icon: const Icon(Icons.close),
                          label: const Text('Từ chối'),
                        ),
                      ),
                    ],
                  ),
                ] else if (booking.status == booking_entity.BookingStatus.accepted) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _startRide(booking),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.driverPrimary,
                            side: BorderSide(color: AppColors.driverPrimary),
                          ),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Bắt đầu chuyến'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openChat(booking),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.info,
                            side: BorderSide(color: AppColors.info),
                          ),
                          icon: const Icon(Icons.chat),
                          label: const Text('Nhắn tin'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(booking_entity.BookingStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case booking_entity.BookingStatus.pending:
        color = AppColors.warning;
        text = 'Chờ duyệt';
        break;
      case booking_entity.BookingStatus.accepted:
        color = AppColors.success;
        text = 'Đã chấp nhận';
        break;
      case booking_entity.BookingStatus.inProgress:
        color = AppColors.info;
        text = 'Đang di chuyển';
        break;
      case booking_entity.BookingStatus.completed:
        color = AppColors.textSecondary;
        text = 'Hoàn thành';
        break;
      case booking_entity.BookingStatus.cancelled:
        color = AppColors.error;
        text = 'Đã hủy';
        break;
      case booking_entity.BookingStatus.rejected:
        color = AppColors.error;
        text = 'Đã từ chối';
        break;
      case booking_entity.BookingStatus.passengerConfirmed:
        color = AppColors.info;
        text = 'Hành khách xác nhận';
        break;
      case booking_entity.BookingStatus.driverConfirmed:
        color = AppColors.success;
        text = 'Tài xế xác nhận';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // _buildLoadingState method removed - not used

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
                context.read<BookingCubit>().loadBookings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.driverPrimary,
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
              'Các yêu cầu đặt chuyến sẽ hiển thị ở đây',
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
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showBookingDetails(booking_entity.BookingEntity booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiết đặt chuyến',
                      style: AppTextStyles.headingMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Detailed booking information
                    _buildBookingDetails(booking),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _acceptBooking(booking_entity.BookingEntity booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Chấp nhận đặt chuyến'),
        content: Text('Bạn có chắc chắn muốn chấp nhận đặt chuyến từ ${booking.passengerName}?'),
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
              // Use BookingCubit to accept booking
              context.read<BookingCubit>().acceptBooking(booking.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã chấp nhận đặt chuyến'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Chấp nhận'),
          ),
        ],
      ),
    );
  }

  void _rejectBooking(booking_entity.BookingEntity booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Từ chối đặt chuyến'),
        content: Text('Bạn có chắc chắn muốn từ chối đặt chuyến từ ${booking.passengerName}?'),
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
              // Use BookingCubit to reject booking
              context.read<BookingCubit>().rejectBooking(booking.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã từ chối đặt chuyến'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  void _startRide(booking_entity.BookingEntity booking) {
    // Navigate to driver tracking screen
    Navigator.pushNamed(
      context,
      '/driver-tracking',
      arguments: booking,
    );
  }

  void _openChat(booking_entity.BookingEntity booking) {
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: {
        'roomId': 'room_${booking.id}',
        'participantName': booking.passengerName,
        'participantEmail': booking.passengerEmail,
      },
    );
  }

  void _markAllAsRead() {
    // Use NotificationCubit to mark all as read
    // context.read<NotificationCubit>().markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã đánh dấu tất cả là đã đọc'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Widget _buildBookingDetails(booking_entity.BookingEntity booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Điểm đi', booking.departure),
        _buildDetailRow('Điểm đến', booking.destination),
        _buildDetailRow('Thời gian', _formatDateTime(booking.startTime)),
        _buildDetailRow('Số ghế đặt', '${booking.seatsBooked}'),
        _buildDetailRow('Giá mỗi ghế', '${booking.pricePerSeat.toStringAsFixed(0)} VNĐ'),
        _buildDetailRow('Tổng tiền', '${booking.totalPrice.toStringAsFixed(0)} VNĐ'),
        _buildDetailRow('Trạng thái', _getStatusText(booking.status)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText(booking_entity.BookingStatus status) {
    switch (status) {
      case booking_entity.BookingStatus.pending:
        return 'Chờ xác nhận';
      case booking_entity.BookingStatus.accepted:
        return 'Đã chấp nhận';
      case booking_entity.BookingStatus.inProgress:
        return 'Đang thực hiện';
      case booking_entity.BookingStatus.passengerConfirmed:
        return 'Hành khách xác nhận';
      case booking_entity.BookingStatus.driverConfirmed:
        return 'Tài xế xác nhận';
      case booking_entity.BookingStatus.completed:
        return 'Hoàn thành';
      case booking_entity.BookingStatus.cancelled:
        return 'Đã hủy';
      case booking_entity.BookingStatus.rejected:
        return 'Đã từ chối';
    }
  }
}
