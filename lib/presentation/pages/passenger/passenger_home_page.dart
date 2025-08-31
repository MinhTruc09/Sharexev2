import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/home/home_passenger_cubit.dart';
import 'package:sharexev2/presentation/views/passenger/home/passenger_home_view.dart';
import 'package:sharexev2/presentation/views/passenger/history/passenger_history_view.dart';
import 'package:sharexev2/presentation/views/passenger/favorites/passenger_favorites_view.dart';
import 'package:sharexev2/presentation/views/passenger/settings/passenger_settings_view.dart';
import 'package:sharexev2/presentation/widgets/common/custom_bottom_nav.dart';

/// Passenger Home Page - Controls navigation and provides cubit
class PassengerHomePage extends StatefulWidget {
  const PassengerHomePage({super.key});

  @override
  State<PassengerHomePage> createState() => _PassengerHomePageState();
}

class _PassengerHomePageState extends State<PassengerHomePage> {
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
      create: (_) => HomePassengerCubit(
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
            PassengerHomeView(),
            PassengerHistoryView(),
            PassengerFavoritesView(),
            PassengerSettingsView(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          role: 'PASSENGER',
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final titles = ['Trang chủ', 'Lịch sử', 'Yêu thích', 'Cài đặt'];
    
    return AppBar(
      title: Text(titles[_currentIndex]),
      backgroundColor: AppColors.passengerPrimary,
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
    Navigator.pushNamed(context, '/passenger/profile');
  }
}

class _NotificationBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Chuyến đi được xác nhận',
      'message': 'Tài xế đã xác nhận chuyến đi của bạn',
      'time': '5 phút trước',
      'type': 'success',
    },
    {
      'title': 'Khuyến mãi mới',
      'message': 'Giảm 20% cho chuyến đi tiếp theo',
      'time': '1 giờ trước',
      'type': 'promotion',
    },
    {
      'title': 'Nhắc nhở đánh giá',
      'message': 'Hãy đánh giá chuyến đi vừa hoàn thành',
      'time': '2 giờ trước',
      'type': 'reminder',
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
      case 'success':
        icon = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      case 'promotion':
        icon = Icons.local_offer;
        iconColor = AppColors.grabOrange;
        break;
      case 'reminder':
        icon = Icons.schedule;
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
