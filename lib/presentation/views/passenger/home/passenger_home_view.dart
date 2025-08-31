import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/home/home_passenger_cubit.dart';
import 'package:sharexev2/presentation/widgets/passenger/passenger_search_widget.dart';
import 'package:sharexev2/presentation/widgets/passenger/passenger_trip_card.dart';
import 'package:sharexev2/presentation/widgets/common/auth_button.dart';

/// Passenger Home View - UI only, no business logic
class PassengerHomeView extends StatelessWidget {
  const PassengerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePassengerCubit, HomePassengerState>(
      builder: (context, state) {
        if (state.status == HomePassengerStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == HomePassengerStatus.error) {
          return _buildErrorState(context, state.error);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context),
              const SizedBox(height: 20),
              
              // Search Widget
              const PassengerSearchWidget(),
              const SizedBox(height: 20),
              
              // Quick Actions
              _buildQuickActions(context),
              const SizedBox(height: 20),
              
              // Recent Trips
              if (state.rideHistory.isNotEmpty) ...[
                _buildRecentTrips(context, state),
                const SizedBox(height: 20),
              ],
              
              // Nearby Trips
              _buildNearbyTrips(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(error ?? 'Có lỗi xảy ra'),
          const SizedBox(height: 16),
          AuthButton(
            text: 'Thử lại',
            role: 'PASSENGER',
            onPressed: () {
              context.read<HomePassengerCubit>().init();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.passengerPrimary, AppColors.passengerSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xin chào!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn muốn đi đâu hôm nay?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Vị trí hiện tại: ',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Text(
                'Quận 1, TP.HCM',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Đặt ngay',
                'Tìm chuyến đi ngay lập tức',
                Icons.search,
                AppColors.passengerPrimary,
                () => _onQuickBook(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Đặt trước',
                'Lên lịch chuyến đi',
                Icons.schedule,
                AppColors.grabOrange,
                () => _onScheduleBook(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToHistory(context),
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...state.rideHistory.take(3).map((ride) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PassengerTripCard(
              ride: ride,
              onTap: () => _navigateToTripDetail(context, ride.id),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNearbyTrips(BuildContext context, HomePassengerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chuyến đi gần bạn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (state.nearbyTrips.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Không có chuyến đi nào gần bạn',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ...state.nearbyTrips.take(5).map((trip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PassengerTripCard(
                trip: trip,
                onTap: () => _navigateToTripDetail(context, trip['id']),
              ),
            );
          }),
      ],
    );
  }

  void _onQuickBook(BuildContext context) {
    // Trigger search bottom sheet
    context.read<HomePassengerCubit>().showSearchBottomSheet();
  }

  void _onScheduleBook(BuildContext context) {
    // Navigate to schedule booking
    Navigator.pushNamed(context, '/passenger/schedule-booking');
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.pushNamed(context, '/passenger/history');
  }

  void _navigateToTripDetail(BuildContext context, int tripId) {
    Navigator.pushNamed(
      context,
      '/passenger/trip-detail',
      arguments: {'tripId': tripId},
    );
  }
}
