import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/home/home_driver_cubit.dart';
import 'package:sharexev2/presentation/views/driver/home/driver_home_view.dart';
import 'package:sharexev2/presentation/views/driver/trips/driver_trips_view.dart';
import 'package:sharexev2/presentation/views/driver/earnings/driver_earnings_view.dart';
import 'package:sharexev2/presentation/views/driver/settings/driver_settings_view.dart';
import 'package:sharexev2/presentation/widgets/common/custom_bottom_nav.dart';

/// Driver Home Page - Controls navigation and provides cubit
class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeDriverCubit(
        rideRepository: ServiceLocator.get(),
        bookingRepository: ServiceLocator.get(),
        userRepository: ServiceLocator.get(),
      )..init(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: const [
            DriverHomeView(),
            DriverTripsView(),
            DriverEarningsView(),
            DriverSettingsView(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          role: 'DRIVER',
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final titles = ['Trang chủ', 'Chuyến đi', 'Thu nhập', 'Cài đặt'];
    
    return AppBar(
      title: Text(titles[_currentIndex]),
      backgroundColor: AppColors.driverPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Notifications
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.grabOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => _showNotifications(context),
        ),
        
        // Profile
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => _navigateToProfile(context),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationBottomSheet(),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/driver/profile');
  }
}

class _NotificationBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Có chuyến đi mới',
      'message': 'Hành khách đã đặt chuyến đi của bạn',
      'time': '5 phút trước',
      'type': 'booking',
    },
    {
      'title': 'Thanh toán thành công',
      'message': 'Bạn đã nhận được 150k VNĐ',
      'time': '1 giờ trước',
      'type': 'payment',
    },
    {
      'title': 'Đánh giá mới',
      'message': 'Hành khách đã đánh giá chuyến đi',
      'time': '2 giờ trước',
      'type': 'review',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông báo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Mark all as read
                  },
                  child: const Text('Đánh dấu đã đọc'),
                ),
              ],
            ),
          ),
          
          // Notifications list
          Expanded(
            child: ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationItem(notification);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    IconData icon;
    Color iconColor;
    
    switch (notification['type']) {
      case 'booking':
        icon = Icons.directions_car;
        iconColor = AppColors.driverPrimary;
        break;
      case 'payment':
        icon = Icons.account_balance_wallet;
        iconColor = AppColors.success;
        break;
      case 'review':
        icon = Icons.star;
        iconColor = AppColors.warning;
        break;
      default:
        icon = Icons.info;
        iconColor = AppColors.info;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        notification['title'],
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification['message']),
          const SizedBox(height: 4),
          Text(
            notification['time'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      onTap: () {
        // Handle notification tap
      },
    );
  }
}
