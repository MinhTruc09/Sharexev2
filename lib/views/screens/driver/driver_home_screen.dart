import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/home/home_driver_cubit.dart';
// HomeDriverState is imported via part directive in cubit
import 'package:sharexev2/logic/ride/ride_cubit.dart';
// RideState is imported via part directive in cubit
import 'package:sharexev2/logic/tracking/tracking_cubit.dart';
// TrackingState is imported via part directive in cubit
import 'package:sharexev2/routes/app_routes.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/views/widgets/sharexe_widgets.dart';
import 'package:sharexev2/logic/notification/notification_cubit.dart';

/// Trang chủ tài xế ShareXe
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0;

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
      // Load more rides when available
      // context.read<HomeDriverCubit>().loadMoreRides();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeDriverCubit(
            rideRepository: ServiceLocator.get(),
            bookingRepository: ServiceLocator.get(),
            userRepository: ServiceLocator.get(),
          )..init(),
        ),
        BlocProvider(
          create: (_) => RideCubit(
            rideRepository: ServiceLocator.get(),
            bookingRepository: ServiceLocator.get(),
          ),
        ),
        BlocProvider(
          create: (_) => TrackingCubit(
            ServiceLocator.get(),
          ),
        ),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        body: Column(
          children: [
            _buildStatsSection(),
            _buildTabBar(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
        floatingActionButton: _buildCreateRideButton(),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.driverPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào!',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white70,
            ),
          ),
          BlocBuilder<HomeDriverCubit, HomeDriverState>(
            builder: (context, state) {
              return Text(
                state.driverProfile?.fullName ?? 'Tài xế ShareXe',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        // Notifications
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.pushNamed(context, '/driver-notifications');
              },
            ),
            // Get notification count from NotificationCubit
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                final unreadCount = state.unreadCount;
                return unreadCount > 0
                    ? Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
        // Chat
        IconButton(
          icon: const Icon(Icons.chat_outlined),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.chatRooms);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.driverPrimary,
                  AppColors.driverPrimary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<HomeDriverCubit, HomeDriverState>(
                      builder: (context, state) {
                        return ShareXeUserAvatar(
                          name: state.driverProfile?.fullName ?? 'Tài xế',
                          imageUrl: state.driverProfile?.avatarUrl,
                          role: 'DRIVER',
                          status: UserStatus.online,
                          radius: 40,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<HomeDriverCubit, HomeDriverState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.driverProfile?.fullName ?? 'Tài xế ShareXe',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.driverProfile?.email ?? 'driver@sharexe.vn',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Tài xế chuyên nghiệp',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'Trang chủ',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: 'Lịch sử chuyến đi',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedTabIndex = 1);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.analytics,
                  title: 'Doanh thu',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedTabIndex = 2);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Cài đặt',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Trợ giúp',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'Về chúng tôi',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/about');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  onTap: () {
                    Navigator.pop(context);
                    // Implement logout
                    // context.read<AuthCubit>().logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium,
      ),
      onTap: onTap,
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.driverPrimary,
            AppColors.driverPrimary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.driverPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: BlocBuilder<HomeDriverCubit, HomeDriverState>(
        builder: (context, state) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Hôm nay',
                      '${state.todayEarnings.toStringAsFixed(0)}₫',
                      '${state.todayRides} chuyến',
                      Icons.today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      'Tuần này',
                      '${state.weeklyEarnings.toStringAsFixed(0)}₫',
                      '${state.weeklyRides} chuyến',
                      Icons.date_range,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Tổng doanh thu',
                      '${state.totalEarnings.toStringAsFixed(0)}₫',
                      '${state.completedTrips} chuyến hoàn thành',
                      Icons.attach_money,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      'Đánh giá',
                      '4.8',
                      'Tuyệt vời',
                      Icons.star,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Row(
        children: [
          _buildTabItem('Chuyến của tôi', 0),
          _buildTabItem('Lịch sử', 1),
          _buildTabItem('Doanh thu', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.driverPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildMyRidesTab();
      case 1:
        return _buildHistoryTab();
      case 2:
        return _buildRevenueTab();
      default:
        return _buildMyRidesTab();
    }
  }

  Widget _buildMyRidesTab() {
    return BlocBuilder<HomeDriverCubit, HomeDriverState>(
      builder: (context, state) {
        if (state.status == HomeDriverStatus.loading) {
          return _buildLoadingState();
        }

        if (state.status == HomeDriverStatus.error) {
          return _buildErrorState(state.error);
        }

        final rides = state.myRides;
        if (rides.isEmpty) {
          return _buildEmptyRidesState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<HomeDriverCubit>().init();
          },
          color: AppColors.driverPrimary,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ride = rides[index];
              return _buildRideCard(ride);
            },
          ),
        );
      },
    );
  }

  Widget _buildRideCard(dynamic ride) {
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
                // Header with status
                Row(
                  children: [
                    _buildStatusChip(ride['status'] ?? 'ACTIVE'),
                    const Spacer(),
                    Text(
                      _formatDate(ride['startTime'] ?? DateTime.now()),
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
                            ride['departure'] ?? 'Điểm đi',
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
                            ride['destination'] ?? 'Điểm đến',
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
                      _formatTime(ride['startTime'] ?? DateTime.now()),
                      'Thời gian',
                    ),
                    const SizedBox(width: 16),
                    _buildDetailItem(
                      Icons.people,
                      '${ride['availableSeats'] ?? 0}/${ride['totalSeats'] ?? 0} ghế',
                      'Ghế trống',
                    ),
                    const Spacer(),
                    Text(
                      '${ride['pricePerSeat']?.toStringAsFixed(0) ?? '0'}₫/ghế',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.driverPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // Action buttons
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _startTracking(ride),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Bắt đầu'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: BorderSide(color: AppColors.success),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editRide(ride),
                        icon: const Icon(Icons.edit),
                        label: const Text('Chỉnh sửa'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.driverPrimary,
                          side: BorderSide(color: AppColors.driverPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        color = AppColors.success;
        text = 'Đang hoạt động';
        break;
      case 'IN_PROGRESS':
        color = AppColors.info;
        text = 'Đang di chuyển';
        break;
      case 'COMPLETED':
        color = AppColors.textSecondary;
        text = 'Hoàn thành';
        break;
      case 'CANCELLED':
        color = AppColors.error;
        text = 'Đã hủy';
        break;
      default:
        color = AppColors.warning;
        text = 'Chờ xác nhận';
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

  Widget _buildHistoryTab() {
    return BlocBuilder<HomeDriverCubit, HomeDriverState>(
      builder: (context, state) {
        final completedRides = state.completedTripsList;
        
        if (completedRides.isEmpty) {
          return _buildEmptyHistoryState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: completedRides.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ride = completedRides[index];
            return _buildHistoryCard(ride);
          },
        );
      },
    );
  }

  Widget _buildHistoryCard(dynamic ride) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 24,
          ),
        ),
        title: Text(
          '${ride['departure'] ?? 'Điểm đi'} → ${ride['destination'] ?? 'Điểm đến'}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(ride['startTime'] ?? DateTime.now()),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${ride['totalSeats'] ?? 0} ghế • ${ride['pricePerSeat']?.toStringAsFixed(0) ?? '0'}₫/ghế',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${ride['totalPrice']?.toStringAsFixed(0) ?? '0'}₫',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.driverPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _showRideDetails(ride),
      ),
    );
  }

  Widget _buildRevenueTab() {
    return BlocBuilder<HomeDriverCubit, HomeDriverState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Revenue summary
              _buildRevenueCard(
                'Tổng doanh thu',
                '${state.totalEarnings.toStringAsFixed(0)}₫',
                Icons.attach_money,
                AppColors.driverPrimary,
              ),
              const SizedBox(height: 16),
              
              // Time period stats
              Row(
                children: [
                  Expanded(
                    child: _buildRevenueCard(
                      'Hôm nay',
                      '${state.todayEarnings.toStringAsFixed(0)}₫',
                      Icons.today,
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRevenueCard(
                      'Tuần này',
                      '${state.weeklyEarnings.toStringAsFixed(0)}₫',
                      Icons.date_range,
                      AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Monthly revenue
              _buildRevenueCard(
                'Tháng này',
                '${state.monthlyEarnings.toStringAsFixed(0)}₫',
                Icons.calendar_month,
                AppColors.warning,
              ),
              const SizedBox(height: 24),
              
              // Chart placeholder
              Container(
                height: 200,
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
      },
    );
  }

  Widget _buildRevenueCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: AppTextStyles.headingMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
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
            'Đang tải dữ liệu...',
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
              error ?? 'Không thể tải dữ liệu',
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

  Widget _buildEmptyRidesState() {
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
              'Tạo chuyến đi đầu tiên của bạn',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateRideDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.driverPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tạo chuyến đi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
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
              'Các chuyến đi hoàn thành sẽ hiển thị ở đây',
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

  Widget _buildCreateRideButton() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, '/create-ride'),
      backgroundColor: AppColors.driverPrimary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Tạo chuyến'),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.driverPrimary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Doanh thu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
        onTap: (index) {
          setState(() => _selectedTabIndex = index);
        },
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

  void _showRideDetails(dynamic ride) {
    // Navigate to ride details screen
    Navigator.pushNamed(
      context,
      '/ride-details',
      arguments: ride,
    );
  }

  void _startTracking(dynamic ride) {
    // Navigate to tracking screen
    Navigator.pushNamed(
      context,
      '/driver/tracking',
      arguments: ride,
    );
  }

  void _editRide(dynamic ride) {
    // Navigate to edit ride screen
    Navigator.pushNamed(
      context,
      '/driver/edit-ride',
      arguments: ride,
    );
  }

  void _showCreateRideDialog() {
    // Navigate to create ride screen
    Navigator.pushNamed(
      context,
      '/driver/create-ride',
    );
  }
}
