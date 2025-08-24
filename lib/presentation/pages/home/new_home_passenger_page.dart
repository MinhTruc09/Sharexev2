import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/home/home_passenger_cubit.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/presentation/widgets/common/custom_bottom_nav.dart';
import 'package:sharexev2/presentation/widgets/home/search_bottom_sheet.dart';
import 'package:sharexev2/presentation/widgets/home/trip_card.dart';
import 'package:sharexev2/routes/app_routes.dart';

class NewHomePassengerPage extends StatelessWidget {
  const NewHomePassengerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomePassengerCubit()..init(),
      child: const NewHomePassengerView(),
    );
  }
}

class NewHomePassengerView extends StatefulWidget {
  const NewHomePassengerView({super.key});

  @override
  State<NewHomePassengerView> createState() => _NewHomePassengerViewState();
}

class _NewHomePassengerViewState extends State<NewHomePassengerView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentNavIndex = 0;
  List<Map<String, dynamic>> _nearbyTrips = [];
  bool _hasActiveTrip = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _loadNearbyTrips();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadNearbyTrips() {
    // Mock data for nearby trips
    setState(() {
      _nearbyTrips = [
        {
          'destination': 'Quận 7, TP.HCM',
          'origin': 'Quận 1, TP.HCM',
          'departureTime': '14:30 - Hôm nay',
          'price': 45,
          'availableSeats': 3,
          'driverName': 'Nguyễn Văn A',
          'driverInitials': 'NA',
          'rating': 4.8,
          'vehicleType': 'Xe hơi',
          'notes': 'Xe mới, điều hòa mát',
        },
        {
          'destination': 'Quận Thủ Đức, TP.HCM',
          'origin': 'Quận 3, TP.HCM',
          'departureTime': '15:00 - Hôm nay',
          'price': 35,
          'availableSeats': 2,
          'driverName': 'Trần Thị B',
          'driverInitials': 'TB',
          'rating': 4.9,
          'vehicleType': 'Xe van',
          'notes': 'Đi đúng giờ, an toàn',
        },
        {
          'destination': 'Quận Bình Thạnh, TP.HCM',
          'origin': 'Quận 5, TP.HCM',
          'departureTime': '16:30 - Hôm nay',
          'price': 25,
          'availableSeats': 4,
          'driverName': 'Lê Văn C',
          'driverInitials': 'LC',
          'rating': 4.7,
          'vehicleType': 'Xe hơi',
          'notes': 'Giá rẻ, thân thiện',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              _buildSearchSection(),
              _buildTripStatusSection(),
              _buildNearbyTripsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        role: 'PASSENGER',
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeManager.getPrimaryColorForRole('PASSENGER'),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Text(
            'ShareXe',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            'Xin chào, Khách hàng!',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.widgets),
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoute.bookingDemo,
              arguments: 'PASSENGER',
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thông báo')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: ThemeManager.getPrimaryColorForRole('PASSENGER'),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    'KH',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ThemeManager.getPrimaryColorForRole('PASSENGER'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Khách hàng',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'khachhang@example.com',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Hồ sơ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                AppRoute.passengerProfile,
                arguments: 'PASSENGER',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Lịch sử chuyến đi'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Cài đặt'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeManager.getPrimaryColorForRole('PASSENGER'),
            ThemeManager.getPrimaryColorForRole('PASSENGER').withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Khám phá chuyến đi',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tìm kiếm và đặt chuyến đi một cách dễ dàng',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _showSearchBottomSheet,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeManager.getPrimaryColorForRole('PASSENGER').withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: ThemeManager.getPrimaryColorForRole('PASSENGER'),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tìm kiếm chuyến đi',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Nhấn để tìm kiếm chuyến đi phù hợp',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripStatusSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasActiveTrip) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF38A169).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF38A169).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF38A169),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bạn có chuyến đi đang hoạt động',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Xem chi tiết'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Divider(color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildNearbyTripsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Các chuyến đi gần bạn',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _nearbyTrips.length,
            itemBuilder: (context, index) {
              return TripCard(
                tripData: _nearbyTrips[index],
                role: 'PASSENGER',
                onTap: () {
                  // Navigate directly to trip detail page
                  Navigator.pushNamed(
                    context,
                    AppRoute.tripDetail,
                    arguments: _nearbyTrips[index],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SearchBottomSheet(
        role: 'PASSENGER',
        onSearch: (searchData) {
          print('Search data: $searchData');
          // Handle search results
        },
      ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> tripData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đặt chuyến đi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tuyến: ${tripData['origin']} → ${tripData['destination']}'),
            Text('Thời gian: ${tripData['departureTime']}'),
            Text('Giá: ${tripData['price']}k VNĐ'),
            Text('Chỗ trống: ${tripData['availableSeats']} chỗ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
                              // Navigate to trip detail page
                Navigator.pushNamed(
                  context,
                  AppRoute.tripDetail,
                  arguments: tripData,
                );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeManager.getPrimaryColorForRole('PASSENGER'),
            ),
            child: Text(
              'Xem chi tiết',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
