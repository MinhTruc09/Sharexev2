import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/home/home_passenger_cubit.dart';
import 'package:sharexev2/logic/location/location_cubit.dart';
import 'package:sharexev2/logic/notification/notification_cubit.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/views/widgets/ride/ride_card_widget.dart';
import 'package:sharexev2/views/widgets/skeleton_loader.dart';

/// Trang chủ hành khách
class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

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
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomePassengerCubit(
            rideRepository: ServiceLocator.get(),
            bookingRepository: ServiceLocator.get(),
            locationRepository: ServiceLocator.get(),
          )..loadInitialData(),
        ),
        BlocProvider(
          create: (_) => LocationCubit(
            locationRepository: ServiceLocator.get(),
          )..getCurrentLocation(),
        ),
        BlocProvider(
          create: (_) => NotificationCubit(
            notificationRepository: ServiceLocator.get(),
          )..loadNotifications(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.passengerPrimary,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildSearchSection()),
              SliverToBoxAdapter(child: _buildCurrentRideBanner()),
              SliverToBoxAdapter(child: _buildQuickActions()),
              SliverToBoxAdapter(child: _buildNearbyRidesHeader()),
              SliverFillRemaining(child: _buildNearbyRidesList()),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.passengerPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào!',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white70,
            ),
          ),
          BlocBuilder<LocationCubit, LocationState>(
            builder: (context, state) {
              return Text(
                state.currentLocation?.address ?? 'Đang tải vị trí...',
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
        BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
                if (state.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${state.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          onTap: () {
            Navigator.pushNamed(context, '/search-rides');
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.passengerPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.search,
                    color: AppColors.passengerPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bạn muốn đi đâu?',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tìm kiếm chuyến đi phù hợp',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentRideBanner() {
    return BlocBuilder<HomePassengerCubit, HomePassengerState>(
      builder: (context, state) {
        // Check for current booking when state is available
        // For now, always show no ride banner until real booking data is integrated
        return _buildNoRideBanner();
      },
    );
  }

  Widget _buildNoRideBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.passengerPrimary,
            AppColors.passengerPrimary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car_outlined,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Chưa có chuyến đi nào',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tìm kiếm và đặt chuyến đi phù hợp với bạn',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/search-rides');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.passengerPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.search),
              label: const Text('Tìm chuyến đi'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thao tác nhanh',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQuickActionCard(
                icon: Icons.bookmark_outline,
                label: 'Đặt chỗ',
                color: AppColors.passengerPrimary,
                onTap: () => Navigator.pushNamed(context, '/bookings'),
              ),
              const SizedBox(width: 12),
              _buildQuickActionCard(
                icon: Icons.history,
                label: 'Lịch sử',
                color: AppColors.info,
                onTap: () => Navigator.pushNamed(context, '/history'),
              ),
              const SizedBox(width: 12),
              _buildQuickActionCard(
                icon: Icons.favorite_outline,
                label: 'Yêu thích',
                color: AppColors.error,
                onTap: () => Navigator.pushNamed(context, '/favorites'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyRidesHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Text(
            'Chuyến đi gần bạn',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/search-rides');
            },
            child: Text(
              'Xem tất cả',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.passengerPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyRidesList() {
    return BlocBuilder<HomePassengerCubit, HomePassengerState>(
      builder: (context, state) {
        if (state.status == HomePassengerStatus.loading) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RideCardSkeleton(),
            ),
          );
        }

        if (state.nearbyRides.isEmpty) {
          return _buildEmptyRidesList();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.nearbyRides.length,
          itemBuilder: (context, index) {
            final ride = state.nearbyRides[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RideCardWidget(
                ride: ride,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/ride-detail',
                    arguments: ride,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyRidesList() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy chuyến đi nào',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử tìm kiếm với địa điểm khác',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/search-rides');
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
    );
  }

  Future<void> _handleRefresh() async {
    // Refresh all data
    context.read<HomePassengerCubit>().loadInitialData();
    context.read<LocationCubit>().getCurrentLocation();
    context.read<NotificationCubit>().loadNotifications();
  }
}
