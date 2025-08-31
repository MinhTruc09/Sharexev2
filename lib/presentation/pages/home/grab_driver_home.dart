import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/home/home_driver_cubit.dart';
// Use existing widgets
import 'package:sharexev2/presentation/widgets/common/custom_bottom_nav.dart';
import 'package:sharexev2/presentation/widgets/home/ride_card.dart';
import 'package:sharexev2/presentation/widgets/common/auth_button.dart';

class GrabDriverHome extends StatefulWidget {
  const GrabDriverHome({super.key});

  @override
  State<GrabDriverHome> createState() => _GrabDriverHomeState();
}

class _GrabDriverHomeState extends State<GrabDriverHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_getPageTitle(_currentIndex)),
        backgroundColor: AppColors.driverPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          _TripsTab(),
          _EarningsTab(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        role: 'DRIVER',
        currentIndex: _currentIndex,
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
        return 'Tài xế ShareXe';
      case 1:
        return 'Chuyến đi';
      case 2:
        return 'Thu nhập';
      case 3:
        return 'Cài đặt';
      default:
        return 'ShareXe Driver';
    }
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDriverCubit, HomeDriverState>(
      builder: (context, state) {
        if (state.status == HomeDriverStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == HomeDriverStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.error ?? 'Có lỗi xảy ra'),
                const SizedBox(height: 16),
                AuthButton(
                  text: 'Thử lại',
                  role: 'DRIVER',
                  onPressed: () {
                    context.read<HomeDriverCubit>().init();
                  },
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Status Card
              _buildDriverStatusCard(context, state),
              const SizedBox(height: 20),

              // Stats Overview
              _buildStatsOverview(context, state),
              const SizedBox(height: 20),

              // My Rides Section
              _buildMyRidesSection(context, state),
              const SizedBox(height: 20),

              // Quick Actions
              _buildQuickActionsSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDriverStatusCard(BuildContext context, HomeDriverState state) {
    final isOnline = state.status == HomeDriverStatus.ready;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppColors.driverPrimary, AppColors.driverPrimary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trạng thái hoạt động',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isOnline ? 'Đang hoạt động' : 'Ngoại tuyến',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOnline
                        ? 'Sẵn sàng nhận chuyến đi'
                        : 'Bật để nhận chuyến',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isOnline,
              onChanged: (value) {
                // TODO: Implement toggle driver status
                // context.read<HomeDriverCubit>().toggleOnlineStatus();
              },
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.grabGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, HomeDriverState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thống kê hôm nay',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Chuyến đi',
                '${state.completedTrips}',
                'Hoàn thành',
                Icons.directions_car,
                AppColors.driverPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Thu nhập',
                '${state.totalEarnings.toStringAsFixed(0)}K',
                'VNĐ',
                Icons.account_balance_wallet,
                AppColors.grabGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRidesSection(BuildContext context, HomeDriverState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Chuyến đi của tôi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all rides
              },
              child: Text(
                'Xem tất cả',
                style: TextStyle(
                  color: AppColors.driverPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.myRides.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.directions_car_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Chưa có chuyến đi nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...state.myRides.take(3).map((ride) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RideCard(
              ride: ride,
              onTap: () {
                // Navigate to ride details
              },
            ),
          )),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thao tác nhanh',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        AuthButton(
          text: 'Tạo chuyến đi mới',
          role: 'DRIVER',
          onPressed: () {
            // Navigate to create ride
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // View schedule
                },
                icon: const Icon(Icons.schedule),
                label: const Text('Lịch trình'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // View earnings
                },
                icon: const Icon(Icons.analytics),
                label: const Text('Thống kê'),
              ),
            ),
          ],
        ),
      ],
    );
  }

}

class _TripsTab extends StatelessWidget {
  const _TripsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Quản lý chuyến đi'),
    );
  }
}

class _EarningsTab extends StatelessWidget {
  const _EarningsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Thu nhập'),
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
