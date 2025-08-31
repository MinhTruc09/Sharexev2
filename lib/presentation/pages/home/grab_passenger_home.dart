import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/home/home_passenger_cubit.dart';
import 'package:sharexev2/presentation/widgets/common/grab_app_bar.dart';
import 'package:sharexev2/presentation/widgets/common/grab_cards.dart';

class GrabPassengerHome extends StatefulWidget {
  const GrabPassengerHome({super.key});

  @override
  State<GrabPassengerHome> createState() => _GrabPassengerHomeState();
}

class _GrabPassengerHomeState extends State<GrabPassengerHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GrabAppBar(
        title: _getPageTitle(_currentIndex),
        userRole: 'PASSENGER',
        onProfileTap: () {
          // Navigate to profile
        },
        onNotificationTap: () {
          // Show notifications
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          _HistoryTab(),
          _FavoritesTab(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: GrabBottomNavBar(
        currentIndex: _currentIndex,
        userRole: 'PASSENGER',
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Xin chào!';
      case 1:
        return 'Lịch sử chuyến đi';
      case 2:
        return 'Địa điểm yêu thích';
      case 3:
        return 'Cài đặt';
      default:
        return 'ShareXe';
    }
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePassengerCubit, HomePassengerState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context, state),
              const SizedBox(height: AppSpacing.lg),
              
              // Quick Booking Section
              _buildQuickBookingSection(context),
              const SizedBox(height: AppSpacing.lg),
              
              // Quick Actions
              _buildQuickActions(context),
              const SizedBox(height: AppSpacing.lg),
              
              // Recent Trips
              if (state.rideHistory.isNotEmpty) ...[
                _buildRecentTrips(context, state),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              // Promotions
              _buildPromotions(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context, HomePassengerState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppGradients.grabPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chào mừng trở lại!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Khách hàng ShareXe', // Mock user name since currentUser not available
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Bạn muốn đi đâu hôm nay?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBookingSection(BuildContext context) {
    return GrabCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đặt chuyến đi',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // From location
          _buildLocationInput(
            icon: Icons.radio_button_checked,
            iconColor: AppColors.grabGreen,
            hint: 'Điểm đón',
            onTap: () {
              // Open location picker
            },
          ),
          const SizedBox(height: AppSpacing.md),
          
          // To location
          _buildLocationInput(
            icon: Icons.location_on,
            iconColor: AppColors.grabOrange,
            hint: 'Điểm đến',
            onTap: () {
              // Open location picker
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Search button
          GrabActionButton(
            text: 'Tìm chuyến đi',
            userRole: 'PASSENGER',
            icon: Icons.search,
            onPressed: () {
              // Search for rides
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput({
    required IconData icon,
    required Color iconColor,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                hint,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dịch vụ',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.schedule,
                title: 'Đặt trước',
                subtitle: 'Lên lịch chuyến đi',
                userRole: 'PASSENGER',
                onTap: () {
                  // Schedule ride
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: QuickActionCard(
                icon: Icons.group,
                title: 'Đi chung',
                subtitle: 'Tiết kiệm chi phí',
                userRole: 'PASSENGER',
                onTap: () {
                  // Shared ride
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTrips(BuildContext context, HomePassengerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Chuyến đi gần đây',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // View all history
              },
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  color: AppColors.passengerPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...state.rideHistory.take(3).map((ride) {
          return TripHistoryCard(
            fromLocation: ride.departure,
            toLocation: ride.destination,
            date: '${ride.startTime.day}/${ride.startTime.month}',
            time: '${ride.startTime.hour}:${ride.startTime.minute.toString().padLeft(2, '0')}',
            price: '${ride.pricePerSeat.toStringAsFixed(0)}đ/ghế',
            status: ride.status.name,
            driverName: ride.driverName,
            vehicleInfo: '${ride.availableSeats}/${ride.totalSeat} ghế',
            userRole: 'PASSENGER',
            onTap: () {
              // View trip details
            },
          );
        }),
      ],
    );
  }

  Widget _buildPromotions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ưu đãi dành cho bạn',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.grabOrange, Color(0xFFFF8A50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giảm 50% chuyến đầu tiên',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Áp dụng cho khách hàng mới',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                Text(
                  'Mã: WELCOME50',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Lịch sử chuyến đi'),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Địa điểm yêu thích'),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Cài đặt'),
    );
  }
}
