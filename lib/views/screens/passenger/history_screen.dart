import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/history/history_cubit.dart';
// import 'package:sharexev2/logic/history/history_state.dart'; // Part file
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/views/widgets/sharexe_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Lịch sử chuyến đi của hành khách với SharedPreferences
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<BookingEntity> _localHistory = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLocalHistory();
    _searchController.addListener(_onSearchChanged);
  }


  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadLocalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('passenger_history') ?? [];
      
      setState(() {
        _localHistory = historyJson
            .map((json) => BookingEntity.fromJson(jsonDecode(json)))
            .toList();
      });
    } catch (e) {
      print('Error loading local history: $e');
      setState(() {
        _localHistory = [];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocProvider(
      create: (_) => HistoryCubit(bookingRepository: ServiceLocator.get())
        ..loadHistory(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFilterTabs(),
            Expanded(
              child: BlocBuilder<HistoryCubit, HistoryState>(
                builder: (context, state) {
                  return _buildHistoryList(state);
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
      backgroundColor: AppColors.passengerPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Lịch sử chuyến đi',
        style: AppTextStyles.headingMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<HistoryCubit>().loadHistory();
          },
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _showExportOptions(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo địa điểm, tài xế...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.passengerPrimary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
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

  Widget _buildFilterTabs() {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(
                'Tất cả',
                HistoryFilter.all,
                state.currentFilter == HistoryFilter.all,
                () => context.read<HistoryCubit>().filterBookings(HistoryFilter.all),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Hoàn thành',
                HistoryFilter.completed,
                state.currentFilter == HistoryFilter.completed,
                () => context.read<HistoryCubit>().filterBookings(HistoryFilter.completed),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Đã hủy',
                HistoryFilter.cancelled,
                state.currentFilter == HistoryFilter.cancelled,
                () => context.read<HistoryCubit>().filterBookings(HistoryFilter.cancelled),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    HistoryFilter filter,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.passengerPrimary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.passengerPrimary : AppColors.borderLight,
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

  Widget _buildHistoryList(HistoryState state) {
    if (state.status == HistoryStatus.loading) {
      return _buildLoadingState();
    }

    if (state.status == HistoryStatus.error) {
      return _buildErrorState(state.error);
    }

    // Combine API data with local history
    final allBookings = [...state.filteredBookings, ..._localHistory];
    final filteredBookings = _searchQuery.isEmpty
        ? allBookings
        : allBookings.where((booking) {
            return booking.departure.toLowerCase().contains(_searchQuery) ||
                booking.destination.toLowerCase().contains(_searchQuery) ||
                booking.driverName.toLowerCase().contains(_searchQuery);
          }).toList();

    if (filteredBookings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HistoryCubit>().loadHistory();
        await _loadLocalHistory();
      },
      color: AppColors.passengerPrimary,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredBookings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return _buildHistoryCard(booking);
        },
      ),
    );
  }

  Widget _buildHistoryCard(BookingEntity booking) {
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
                // Header with status and date
                Row(
                  children: [
                    _buildStatusChip(booking.status),
                    const Spacer(),
                    Text(
                      _formatDate(booking.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
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
                        color: AppColors.passengerPrimary,
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
                const SizedBox(height: 12),
                
                // Driver and vehicle info
                if (booking.driverName.isNotEmpty) ...[
                  Row(
                    children: [
                      ShareXeUserAvatar(
                        name: booking.driverName,
                        radius: 16,
                        showRoleBadge: false,
                        role: 'DRIVER',
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.driverName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (booking.vehicle != null)
                              Text(
                                booking.vehicle!.fullInfo,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _openChatWithDriver(booking),
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.passengerPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Trip details
                Row(
                  children: [
                    _buildDetailItem(
                      Icons.access_time,
                      booking.formattedStartTime,
                      'Thời gian',
                    ),
                    const SizedBox(width: 16),
                    _buildDetailItem(
                      Icons.people,
                      '${booking.seatsBooked} ghế',
                      'Số ghế',
                    ),
                    const Spacer(),
                    Text(
                      '${booking.totalPrice.toStringAsFixed(0)}₫',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.passengerPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // Action buttons
                if (booking.isCompleted) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rateTrip(booking),
                          icon: const Icon(Icons.star_outline),
                          label: const Text('Đánh giá'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.passengerPrimary,
                            side: BorderSide(color: AppColors.passengerPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _bookAgain(booking),
                          icon: const Icon(Icons.repeat),
                          label: const Text('Đặt lại'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: BorderSide(color: AppColors.success),
                          ),
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

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case BookingStatus.pending:
        color = AppColors.warning;
        text = 'Chờ xác nhận';
        break;
      case BookingStatus.accepted:
        color = AppColors.info;
        text = 'Đã xác nhận';
        break;
      case BookingStatus.inProgress:
        color = AppColors.passengerPrimary;
        text = 'Đang di chuyển';
        break;
      case BookingStatus.completed:
        color = AppColors.success;
        text = 'Hoàn thành';
        break;
      case BookingStatus.cancelled:
        color = AppColors.error;
        text = 'Đã hủy';
        break;
      case BookingStatus.rejected:
        color = AppColors.error;
        text = 'Đã từ chối';
        break;
      case BookingStatus.passengerConfirmed:
        color = AppColors.info;
        text = 'Hành khách xác nhận';
        break;
      case BookingStatus.driverConfirmed:
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

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.passengerPrimary),
          const SizedBox(height: 16),
          Text(
            'Đang tải lịch sử...',
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
              error ?? 'Không thể tải lịch sử chuyến đi',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<HistoryCubit>().loadHistory();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.passengerPrimary,
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
              Icons.history,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có lịch sử chuyến đi',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Các chuyến đi của bạn sẽ hiển thị ở đây',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.passengerPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.search),
              label: const Text('Tìm chuyến đi'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildBookingDetails(BookingEntity booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Route information
        _buildDetailSection(
          'Thông tin chuyến đi',
          [
            _buildDetailRow('Điểm đi', booking.departure),
            _buildDetailRow('Điểm đến', booking.destination),
            _buildDetailRow('Thời gian khởi hành', _formatTime(booking.startTime)),
            _buildDetailRow('Ngày đặt', _formatDate(booking.createdAt)),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Driver information
        if (booking.driverName.isNotEmpty)
          _buildDetailSection(
            'Thông tin tài xế',
            [
              _buildDetailRow('Tên tài xế', booking.driverName),
              _buildDetailRow('Số điện thoại', booking.driverPhone),
              _buildDetailRow('Email', booking.driverEmail),
              if (booking.vehicle != null)
                _buildDetailRow('Phương tiện', booking.vehicle!.fullInfo),
            ],
          ),
        
        const SizedBox(height: 16),
        
        // Booking information
        _buildDetailSection(
          'Thông tin đặt chỗ',
          [
            _buildDetailRow('Số ghế đặt', '${booking.seatsBooked} ghế'),
            _buildDetailRow('Giá mỗi ghế', '${booking.pricePerSeat.toStringAsFixed(0)}₫'),
            _buildDetailRow('Tổng tiền', '${booking.totalPrice.toStringAsFixed(0)}₫'),
            _buildDetailRow('Trạng thái', _getStatusText(booking.status)),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Fellow passengers
        if (booking.fellowPassengers.isNotEmpty)
          _buildDetailSection(
            'Hành khách cùng chuyến',
            booking.fellowPassengers.map((passenger) => 
              _buildDetailRow('Hành khách', '${passenger.name} (${passenger.seatsBooked} ghế)')
            ).toList(),
          ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.passengerPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
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
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Chờ xác nhận';
      case BookingStatus.accepted:
        return 'Đã xác nhận';
      case BookingStatus.inProgress:
        return 'Đang di chuyển';
      case BookingStatus.completed:
        return 'Hoàn thành';
      case BookingStatus.cancelled:
        return 'Đã hủy';
      case BookingStatus.rejected:
        return 'Đã từ chối';
      case BookingStatus.passengerConfirmed:
        return 'Hành khách xác nhận';
      case BookingStatus.driverConfirmed:
        return 'Tài xế xác nhận';
    }
  }

  void _showBookingDetails(BookingEntity booking) {
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
                      'Chi tiết chuyến đi',
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

  void _openChatWithDriver(BookingEntity booking) {
    if (booking.driverName.isNotEmpty && booking.driverEmail.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'roomId': 'room_${booking.id}',
          'participantName': booking.driverName,
          'participantEmail': booking.driverEmail,
        },
      );
    }
  }

  void _rateTrip(BookingEntity booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đánh giá chuyến đi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chuyến đi: ${booking.departure} → ${booking.destination}'),
            const SizedBox(height: 16),
            const Text('Chức năng đánh giá sẽ được phát triển trong phiên bản tiếp theo'),
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

  void _bookAgain(BookingEntity booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đặt lại chuyến đi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chuyến đi: ${booking.departure} → ${booking.destination}'),
            const SizedBox(height: 8),
            Text('Tài xế: ${booking.driverName}'),
            const SizedBox(height: 8),
            Text('Giá: ${booking.pricePerSeat.toStringAsFixed(0)}₫/ghế'),
            const SizedBox(height: 16),
            const Text('Chức năng đặt lại sẽ được phát triển trong phiên bản tiếp theo'),
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

  void _showExportOptions() {
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
                'Xuất lịch sử',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.file_download, color: AppColors.passengerPrimary),
              title: const Text('Xuất PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Chức năng xuất PDF đang được phát triển'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: AppColors.passengerPrimary),
              title: const Text('Xuất Excel'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Chức năng xuất Excel đang được phát triển'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
