import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/ride/ride_cubit.dart';
// RideState is imported via part directive in cubit
import 'package:sharexev2/logic/booking/booking_cubit.dart';
import 'package:sharexev2/logic/booking/booking_state.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart' as ride_entity;
import 'package:sharexev2/config/theme.dart';

/// Driver History Screen - Lịch sử chuyến đi của tài xế
class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  String _selectedPeriod = 'all';

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
    // Load more rides when near bottom
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
      create: (_) => RideCubit(
        rideRepository: ServiceLocator.get(),
        bookingRepository: ServiceLocator.get(),
      )..loadDriverRides(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildFilterTabs(),
            _buildPeriodSelector(),
            Expanded(
              child: BlocBuilder<RideCubit, RideState>(
                builder: (context, state) {
                  return _buildRidesList(state);
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
      backgroundColor: AppColors.driverPrimary,
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
            context.read<RideCubit>().loadDriverRides();
          },
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _exportHistory(),
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
          _buildFilterChip('Đang hoạt động', 'active'),
          const SizedBox(width: 8),
          _buildFilterChip('Hoàn thành', 'completed'),
          const SizedBox(width: 8),
          _buildFilterChip('Đã hủy', 'cancelled'),
          const SizedBox(width: 8),
          _buildFilterChip('Sắp tới', 'upcoming'),
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

  Widget _buildPeriodSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPeriodChip('Tất cả', 'all'),
          const SizedBox(width: 8),
          _buildPeriodChip('Hôm nay', 'today'),
          const SizedBox(width: 8),
          _buildPeriodChip('Tuần này', 'week'),
          const SizedBox(width: 8),
          _buildPeriodChip('Tháng này', 'month'),
          const SizedBox(width: 8),
          _buildPeriodChip('Năm nay', 'year'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.info : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.info : AppColors.borderLight,
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

  Widget _buildRidesList(RideState state) {
    if (state.status == RideStatus.loading) {
      return _buildLoadingState();
    }

    if (state.status == RideStatus.error) {
      return _buildErrorState(state.error);
    }

    // Filter rides based on selected filters
    final filteredRides = _filterRides(state.rides);

    if (filteredRides.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<RideCubit>().loadDriverRides();
      },
      color: AppColors.driverPrimary,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredRides.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ride = filteredRides[index];
          return _buildRideCard(ride);
        },
      ),
    );
  }

  List<ride_entity.RideEntity> _filterRides(List<ride_entity.RideEntity> rides) {
    var filteredRides = rides;

    // Filter by status
    switch (_selectedFilter) {
      case 'active':
        filteredRides = rides.where((r) => r.status == ride_entity.RideStatus.active).toList();
        break;
      case 'completed':
        filteredRides = rides.where((r) => r.status == ride_entity.RideStatus.completed).toList();
        break;
      case 'cancelled':
        filteredRides = rides.where((r) => r.status == ride_entity.RideStatus.cancelled).toList();
        break;
      case 'upcoming':
        filteredRides = rides.where((r) => 
          r.status == ride_entity.RideStatus.active && r.startTime.isAfter(DateTime.now())).toList();
        break;
      default:
        // All rides
        break;
    }

    // Filter by period
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'today':
        filteredRides = filteredRides.where((r) => 
          r.startTime.year == now.year &&
          r.startTime.month == now.month &&
          r.startTime.day == now.day).toList();
        break;
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        filteredRides = filteredRides.where((r) => 
          r.startTime.isAfter(weekAgo)).toList();
        break;
      case 'month':
        final monthAgo = now.subtract(const Duration(days: 30));
        filteredRides = filteredRides.where((r) => 
          r.startTime.isAfter(monthAgo)).toList();
        break;
      case 'year':
        final yearAgo = now.subtract(const Duration(days: 365));
        filteredRides = filteredRides.where((r) => 
          r.startTime.isAfter(yearAgo)).toList();
        break;
      default:
        // All periods
        break;
    }

    // Sort by start time (newest first)
    filteredRides.sort((a, b) => b.startTime.compareTo(a.startTime));

    return filteredRides;
  }

  Widget _buildRideCard(ride_entity.RideEntity ride) {
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
          onTap: () => _showRideDetails(ride),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status and time
                Row(
                  children: [
                    _buildStatusChip(ride.status),
                    const Spacer(),
                    Text(
                      _formatDate(ride.startTime),
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
                            ride.departure,
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
                            ride.destination,
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
                
                // Ride details
                Row(
                  children: [
                    _buildDetailItem(
                      Icons.access_time,
                      _formatTime(ride.startTime),
                      'Thời gian',
                    ),
                    const SizedBox(width: 16),
                    _buildDetailItem(
                      Icons.people,
                      '${ride.availableSeats}/${ride.totalSeat} ghế',
                      'Ghế trống',
                    ),
                    const Spacer(),
                    Text(
                      '${ride.pricePerSeat.toStringAsFixed(0)}₫/ghế',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.driverPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // Stats row
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatItem('Hành khách', '${ride.totalSeat - (ride.availableSeats ?? 0)}'),
                    const SizedBox(width: 16),
                    _buildStatItem('Doanh thu', '${_calculateRevenue(ride).toStringAsFixed(0)}₫'),
                    const Spacer(),
                    _buildActionButtons(ride),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ride_entity.RideStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case ride_entity.RideStatus.active:
        color = AppColors.success;
        text = 'Đang hoạt động';
        break;
      case ride_entity.RideStatus.completed:
        color = AppColors.info;
        text = 'Hoàn thành';
        break;
      case ride_entity.RideStatus.cancelled:
        color = AppColors.error;
        text = 'Đã hủy';
        break;
      case ride_entity.RideStatus.driverConfirmed:
        color = AppColors.warning;
        text = 'Tài xế đã xác nhận';
        break;
      case ride_entity.RideStatus.inProgress:
        color = AppColors.info;
        text = 'Đang di chuyển';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.driverPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ride_entity.RideEntity ride) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ride.status == ride_entity.RideStatus.active) ...[
          IconButton(
            onPressed: () => _startTracking(ride),
            icon: Icon(
              Icons.play_arrow,
              color: AppColors.success,
              size: 20,
            ),
            tooltip: 'Bắt đầu tracking',
          ),
        ],
        IconButton(
          onPressed: () => _viewPassengers(ride),
          icon: Icon(
            Icons.people,
            color: AppColors.info,
            size: 20,
          ),
          tooltip: 'Xem hành khách',
        ),
        IconButton(
          onPressed: () => _showRideDetails(ride),
          icon: Icon(
            Icons.info_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
          tooltip: 'Chi tiết',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.driverPrimary),
          const SizedBox(height: 16),
          Text(
            'Đang tải lịch sử chuyến đi...',
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
                context.read<RideCubit>().loadDriverRides();
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
              Icons.directions_car_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có chuyến đi nào',
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
              onPressed: () => _createNewRide(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.driverPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tạo chuyến đi mới'),
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

  double _calculateRevenue(ride_entity.RideEntity ride) {
    final bookedSeats = ride.totalSeat - (ride.availableSeats ?? 0);
    return bookedSeats * ride.pricePerSeat;
  }

  void _showRideDetails(ride_entity.RideEntity ride) {
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
                    // Add detailed ride information
                    _buildRideDetails(ride),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startTracking(ride_entity.RideEntity ride) {
    Navigator.pushNamed(
      context,
      '/map-tracking',
      arguments: {
        'rideId': ride.id,
        'userRole': 'DRIVER',
        'isDriverTracking': true,
      },
    );
  }

  void _viewPassengers(ride_entity.RideEntity ride) {
    // Navigate to passengers list screen
    Navigator.pushNamed(
      context,
      '/driver/passengers-list',
      arguments: ride,
    );
  }

  void _createNewRide() {
    // Navigate to create ride screen
    Navigator.pushNamed(
      context,
      '/driver/create-ride',
    );
  }

  void _exportHistory() {
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
                'Xuất lịch sử chuyến đi',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.file_download, color: AppColors.driverPrimary),
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
              leading: Icon(Icons.table_chart, color: AppColors.driverPrimary),
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

  /// Build detailed ride information
  Widget _buildRideDetails(ride) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Điểm đón:', ride.pickupLocation ?? 'Chưa xác định'),
        const SizedBox(height: 8),
        _buildDetailRow('Điểm đến:', ride.dropoffLocation ?? 'Chưa xác định'),
        const SizedBox(height: 8),
        _buildDetailRow('Thời gian:', _formatDateTime(ride.pickupTime)),
        const SizedBox(height: 8),
        _buildDetailRow('Số hành khách:', '${ride.passengerCount ?? 1} người'),
        const SizedBox(height: 8),
        _buildDetailRow('Trạng thái:', _getStatusText(ride.status)),
        const SizedBox(height: 8),
        _buildDetailRow('Giá:', '${ride.fare ?? 0} VNĐ'),
        const SizedBox(height: 16),
        if (ride.notes != null && ride.notes!.isNotEmpty) ...[
          Text(
            'Ghi chú:',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ride.notes!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  /// Build detail row widget
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// Format date time
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Chưa xác định';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get status text
  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      case 'in_progress':
        return 'Đang thực hiện';
      case 'pending':
        return 'Chờ xác nhận';
      default:
        return 'Không xác định';
    }
  }
}
