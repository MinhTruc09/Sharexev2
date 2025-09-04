import 'package:flutter/material.dart';

import '../../../app_route.dart';
import '../../../models/ride.dart';
import '../../../services/auth_service.dart';
import '../../../services/ride_service.dart';
import '../../widgets/date_picker.dart';
import '../../widgets/location_picker.dart';
import '../../widgets/passenger_counter.dart';
import '../../widgets/ride_card.dart';
// import các widget custom của bạn
// import các service
// import các route

class HomePscreen extends StatefulWidget {
  const HomePscreen({super.key});

  @override
  State<HomePscreen> createState() => _HomePscreenState();
}

class _HomePscreenState extends State<HomePscreen> {
  bool _isRefreshing = false;
  bool _isLoading = false;

  String _departure = '';
  String _destination = '';
  DateTime? _departureDate;
  int _passengerCount = 1;

  List<Ride> _availableRides = [];

  final _rideService = RideService();
  final _authService = AuthService();

  Future<void> _refreshRides() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      print('🔄 Refreshing available rides from API...');
      final rides = await _rideService.getAvailableRides();

      print('✅ Successfully refreshed ${rides.length} rides from API');

      if (mounted) {
        setState(() {
          _availableRides = rides;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật danh sách chuyến xe')),
        );
      }
    } catch (e) {
      print('❌ Error refreshing rides: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể cập nhật danh sách: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _searchRides() async {
    if (_departure.isEmpty && _destination.isEmpty && _departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập ít nhất một điều kiện tìm kiếm'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final rides = await _rideService.searchRides(
        departure: _departure,
        destination: _destination,
        startTime: _departureDate,
        passengerCount: _passengerCount,
      );

      setState(() {
        _availableRides = rides;
        _isLoading = false;
      });

      if (rides.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy chuyến xe phù hợp')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tìm thấy ${rides.length} chuyến đi phù hợp')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tìm kiếm: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoute.role);
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 3) {
      Navigator.pushNamed(context, PassengerRoutes.profile);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoute.chatList);
    }
  }

  Widget _buildSearchCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LocationPicker(
              title: 'Điểm đi',
              icon: Icons.circle_outlined,
              hintText: 'Xuất phát từ',
              onLocationSelected: (location) {
                setState(() {
                  _departure = location;
                });
              },
            ),
            const Divider(height: 1),
            LocationPicker(
              title: 'Điểm đến',
              icon: Icons.location_on_outlined,
              hintText: 'Điểm đến',
              onLocationSelected: (location) {
                setState(() {
                  _destination = location;
                });
              },
            ),
            const Divider(height: 1),
            DatePickerField(
              icon: Icons.access_time,
              hintText: 'Thời gian xuất phát',
              onDateSelected: (date) {
                setState(() {
                  _departureDate = date;
                });
              },
            ),
            const Divider(height: 1),
            PassengerCounter(
              icon: Icons.people_outline,
              hintText: 'Số lượng',
              onCountChanged: (count) {
                setState(() {
                  _passengerCount = count;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchRides,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002D62),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Tìm chuyến', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRidesList() {
    if (_availableRides.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Không có chuyến xe nào phù hợp với tìm kiếm của bạn',
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _availableRides.length,
      itemBuilder: (context, index) {
        try {
          return RideCard(
            ride: _availableRides[index],
            onTap: () async {
              final rideId = _availableRides[index].id;
              final rideDetails = await _rideService.getRideDetails(rideId);

              if (mounted && rideDetails != null) {
                final result = await Navigator.pushNamed(
                  context,
                  AppRoute.rideDetails,
                  arguments: rideDetails,
                );

                if (result == true && mounted) {
                  print('🔄 Booking đã hủy, làm mới danh sách chuyến đi');
                  _refreshRides();
                }
              }
            },
          );
        } catch (e) {
          print('Error rendering ride card at index $index: $e');
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.red.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Lỗi hiển thị chuyến xe: $e',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00AEEF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshRides,
          color: const Color(0xFF002D62),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Khám phá chuyến\nxe mới',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Tài khoản'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.person),
                                    title: const Text('Hồ sơ'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(
                                        context,
                                        PassengerRoutes.profile,
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.logout),
                                    title: const Text('Đăng xuất'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _logout();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Color(0xFF00AEEF)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSearchCard(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chuyến xe có sẵn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (_isRefreshing)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                      : _buildRidesList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00AEEF),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Chuyến đi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Tin nhắn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}
