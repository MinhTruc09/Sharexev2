import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/home/home_passenger_cubit.dart';
import 'package:sharexev2/presentation/widgets/home/ride_card.dart';
import 'package:sharexev2/presentation/widgets/common/auth_button.dart';

class HistoryPage extends StatelessWidget {
  final String role;

  const HistoryPage({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomePassengerCubit(
        rideRepository: ServiceLocator.get(),
        bookingRepository: ServiceLocator.get(),
        userRepository: ServiceLocator.get(),
      )..init(),
      child: HistoryView(role: role),
    );
  }
}

class HistoryView extends StatefulWidget {
  final String role;

  const HistoryView({super.key, required this.role});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPassenger = widget.role == 'PASSENGER';
    final primaryColor = isPassenger ? AppColors.passengerPrimary : AppColors.driverPrimary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isPassenger ? 'Lịch sử chuyến đi' : 'Lịch sử chuyến xe'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Hoàn thành'),
            Tab(text: 'Đã hủy'),
            Tab(text: 'Đang chờ'),
          ],
        ),
      ),
      body: BlocBuilder<HomePassengerCubit, HomePassengerState>(
        builder: (context, state) {
          if (state.status == HomePassengerStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == HomePassengerStatus.error) {
            return _buildErrorState(context, state.error);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildHistoryList(context, state, 'all'),
              _buildHistoryList(context, state, 'completed'),
              _buildHistoryList(context, state, 'cancelled'),
              _buildHistoryList(context, state, 'pending'),
            ],
          );
        },
      ),
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
            role: widget.role,
            onPressed: () {
              context.read<HomePassengerCubit>().init();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, HomePassengerState state, String filter) {
    final rides = _filterRides(state.rideHistory, filter);

    if (rides.isEmpty) {
      return _buildEmptyState(filter);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomePassengerCubit>().init();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RideCard(
              ride: ride,
              onTap: () {
                _navigateToRideDetail(context, ride.id);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    String message;
    IconData icon;

    switch (filter) {
      case 'completed':
        message = 'Chưa có chuyến đi nào hoàn thành';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        message = 'Chưa có chuyến đi nào bị hủy';
        icon = Icons.cancel_outlined;
        break;
      case 'pending':
        message = 'Chưa có chuyến đi nào đang chờ';
        icon = Icons.schedule_outlined;
        break;
      default:
        message = 'Chưa có lịch sử chuyến đi';
        icon = Icons.history;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: widget.role == 'PASSENGER' ? 'Tìm chuyến đi' : 'Tạo chuyến đi',
            role: widget.role,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterRides(List<dynamic> rides, String filter) {
    switch (filter) {
      case 'completed':
        return rides.where((ride) => ride.status.name == 'completed').toList();
      case 'cancelled':
        return rides.where((ride) => ride.status.name == 'cancelled').toList();
      case 'pending':
        return rides.where((ride) => ride.status.name == 'pending').toList();
      default:
        return rides;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lọc theo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('all', 'Tất cả'),
            _buildFilterOption('completed', 'Hoàn thành'),
            _buildFilterOption('cancelled', 'Đã hủy'),
            _buildFilterOption('pending', 'Đang chờ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedFilter,
      onChanged: (String? newValue) {
        setState(() {
          _selectedFilter = newValue ?? 'all';
        });
        Navigator.of(context).pop();
        // Apply filter logic here
      },
    );
  }

  void _navigateToRideDetail(BuildContext context, int rideId) {
    Navigator.pushNamed(
      context,
      '/ride-detail',
      arguments: {
        'rideId': rideId,
        'role': widget.role,
      },
    );
  }
}
