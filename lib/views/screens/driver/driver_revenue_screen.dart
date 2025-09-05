import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/home/home_driver_cubit.dart';
// HomeDriverState is imported via part directive in cubit
import 'package:sharexev2/config/theme.dart';

/// Driver Revenue Screen - Doanh thu và thống kê (demo)
class DriverRevenueScreen extends StatefulWidget {
  const DriverRevenueScreen({super.key});

  @override
  State<DriverRevenueScreen> createState() => _DriverRevenueScreenState();
}

class _DriverRevenueScreenState extends State<DriverRevenueScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  String _selectedPeriod = 'today';

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
    // Handle scroll if needed
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocProvider(
      create: (_) => HomeDriverCubit(
        rideRepository: ServiceLocator.get(),
        bookingRepository: ServiceLocator.get(),
        userRepository: ServiceLocator.get(),
      )..init(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildPeriodSelector(),
            Expanded(
              child: BlocBuilder<HomeDriverCubit, HomeDriverState>(
                builder: (context, state) {
                  return _buildRevenueContent(state);
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
        'Doanh thu',
        style: AppTextStyles.headingMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<HomeDriverCubit>().init();
          },
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _exportRevenue(),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPeriodChip('Hôm nay', 'today'),
          const SizedBox(width: 8),
          _buildPeriodChip('Tuần này', 'week'),
          const SizedBox(width: 8),
          _buildPeriodChip('Tháng này', 'month'),
          const SizedBox(width: 8),
          _buildPeriodChip('Năm nay', 'year'),
          const SizedBox(width: 8),
          _buildPeriodChip('Tất cả', 'all'),
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

  Widget _buildRevenueContent(HomeDriverState state) {
    if (state.status == HomeDriverStatus.loading) {
      return _buildLoadingState();
    }

    if (state.status == HomeDriverStatus.error) {
      return _buildErrorState(state.error);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeDriverCubit>().init();
      },
      color: AppColors.driverPrimary,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRevenueSummary(state),
            const SizedBox(height: 16),
            _buildRevenueChart(),
            const SizedBox(height: 16),
            _buildDetailedStats(state),
            const SizedBox(height: 16),
            _buildRecentTrips(state),
            const SizedBox(height: 16),
            _buildGoalsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSummary(HomeDriverState state) {
    final revenue = _getRevenueForPeriod(state);
    final rides = _getRidesForPeriod(state);
    final passengers = _getPassengersForPeriod(state);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.driverPrimary,
            AppColors.driverPrimary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.driverPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _getPeriodTitle(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${revenue.toStringAsFixed(0)}₫',
            style: AppTextStyles.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Chuyến đi',
                  rides.toString(),
                  Icons.directions_car,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Hành khách',
                  passengers.toString(),
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Trung bình',
                  '${(revenue / (rides > 0 ? rides : 1)).toStringAsFixed(0)}₫',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biểu đồ doanh thu',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Biểu đồ doanh thu',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '(Đang phát triển)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(HomeDriverState state) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê chi tiết',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Tổng doanh thu', '${state.totalEarnings.toStringAsFixed(0)}₫', AppColors.driverPrimary),
          _buildStatRow('Chuyến hoàn thành', '${state.completedTrips}', AppColors.success),
          _buildStatRow('Thời gian lái xe', '${_formatDriveTime(state.todayDriveTime)}', AppColors.info),
          _buildStatRow('Đánh giá trung bình', '4.8/5.0', AppColors.warning),
          _buildStatRow('Tỷ lệ hoàn thành', '95%', AppColors.success),
          _buildStatRow('Hành khách hài lòng', '98%', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTrips(HomeDriverState state) {
    final recentRides = state.recentRides.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Chuyến đi gần đây',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _viewAllTrips(),
                child: Text(
                  'Xem tất cả',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.driverPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentRides.isEmpty)
            _buildEmptyTripsState()
          else
            ...recentRides.map((ride) => _buildTripItem(ride)).toList(),
        ],
      ),
    );
  }

  Widget _buildTripItem(dynamic ride) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ride['departure'] ?? 'Điểm đi'} → ${ride['destination'] ?? 'Điểm đến'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatDate(ride['startTime'] ?? DateTime.now()),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${ride['totalPrice']?.toStringAsFixed(0) ?? '0'}₫',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.driverPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTripsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có chuyến đi nào',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mục tiêu tháng này',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildGoalItem('Doanh thu', 5000000, 3500000, '₫'),
          _buildGoalItem('Chuyến đi', 100, 75, ''),
          _buildGoalItem('Hành khách', 200, 150, ''),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String label, int target, int current, String unit) {
    final progress = current / target;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium,
              ),
              const Spacer(),
              Text(
                '$current$unit / $target$unit',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? AppColors.success : AppColors.driverPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% hoàn thành',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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
            'Đang tải dữ liệu doanh thu...',
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
              error ?? 'Không thể tải dữ liệu doanh thu',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<HomeDriverCubit>().init();
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

  double _getRevenueForPeriod(HomeDriverState state) {
    switch (_selectedPeriod) {
      case 'today':
        return state.todayEarnings;
      case 'week':
        return state.weeklyEarnings;
      case 'month':
        return state.monthlyEarnings;
      case 'year':
        return state.totalEarnings * 0.8; // Demo data
      case 'all':
        return state.totalEarnings;
      default:
        return state.todayEarnings;
    }
  }

  int _getRidesForPeriod(HomeDriverState state) {
    switch (_selectedPeriod) {
      case 'today':
        return state.todayRides;
      case 'week':
        return state.weeklyRides;
      case 'month':
        return state.monthlyRides;
      case 'year':
        return (state.totalEarnings / 50000).round(); // Demo data
      case 'all':
        return state.completedTrips;
      default:
        return state.todayRides;
    }
  }

  int _getPassengersForPeriod(HomeDriverState state) {
    switch (_selectedPeriod) {
      case 'today':
        return state.todayPassengers;
      case 'week':
        return state.weeklyPassengers;
      case 'month':
        return state.monthlyPassengers;
      case 'year':
        return (state.totalEarnings / 25000).round(); // Demo data
      case 'all':
        return state.completedTrips * 2; // Demo data
      default:
        return state.todayPassengers;
    }
  }

  String _getPeriodTitle() {
    switch (_selectedPeriod) {
      case 'today':
        return 'Doanh thu hôm nay';
      case 'week':
        return 'Doanh thu tuần này';
      case 'month':
        return 'Doanh thu tháng này';
      case 'year':
        return 'Doanh thu năm nay';
      case 'all':
        return 'Tổng doanh thu';
      default:
        return 'Doanh thu hôm nay';
    }
  }

  String _formatDriveTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
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

  void _viewAllTrips() {
    // Navigate to driver history screen to view all trips
    Navigator.pushNamed(
      context,
      '/driver-history',
    );
  }

  void _exportRevenue() {
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
                'Xuất báo cáo doanh thu',
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
}
