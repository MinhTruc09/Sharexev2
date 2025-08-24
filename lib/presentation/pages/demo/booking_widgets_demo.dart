import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/presentation/widgets/booking/vehicle_seat_selection.dart';
import 'package:sharexev2/presentation/widgets/common/profile_avatar_picker.dart';
import 'package:sharexev2/presentation/widgets/booking/trip_review_stepper.dart';

class BookingWidgetsDemoPage extends StatefulWidget {
  final String role;

  const BookingWidgetsDemoPage({
    super.key,
    this.role = 'PASSENGER',
  });

  @override
  State<BookingWidgetsDemoPage> createState() => _BookingWidgetsDemoPageState();
}

class _BookingWidgetsDemoPageState extends State<BookingWidgetsDemoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<int> selectedSeats = [];
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Booking Widgets Demo',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: ThemeManager.getPrimaryColorForRole(widget.role),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Chọn chỗ', icon: Icon(Icons.event_seat)),
            Tab(text: 'Avatar', icon: Icon(Icons.person)),
            Tab(text: 'Đánh giá', icon: Icon(Icons.star)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSeatSelectionDemo(),
          _buildAvatarDemo(),
          _buildReviewDemo(),
        ],
      ),
    );
  }

  Widget _buildSeatSelectionDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Seat Selection Demo',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          
          // Car demo
          Text(
            'Xe hơi (4 chỗ)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          VehicleSeatSelection(
            vehicleType: 'car',
            totalSeats: 4,
            reservedSeats: [2],
            pricePerSeat: 50,
            onSeatsSelected: (seats, price) {
              setState(() {
                selectedSeats = seats;
                totalPrice = price;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Van demo
          Text(
            'Xe van (7 chỗ)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          VehicleSeatSelection(
            vehicleType: 'van',
            totalSeats: 7,
            reservedSeats: [1, 4],
            pricePerSeat: 35,
            onSeatsSelected: (seats, price) {
              print('Van - Selected seats: $seats, Total: $price');
            },
          ),
          
          const SizedBox(height: 24),
          
          // Bus demo
          Text(
            'Xe bus (16 chỗ)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          VehicleSeatSelection(
            vehicleType: 'bus',
            totalSeats: 16,
            reservedSeats: [3, 7, 12],
            pricePerSeat: 25,
            onSeatsSelected: (seats, price) {
              print('Bus - Selected seats: $seats, Total: $price');
            },
          ),
          
          if (selectedSeats.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeManager.getPrimaryColorForRole(widget.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Đã chọn: ${selectedSeats.join(', ')} - Tổng: ${totalPrice.toStringAsFixed(0)}k',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Avatar Demo',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          
          // Large avatar picker
          Center(
            child: Column(
              children: [
                Text(
                  'Avatar Picker (Large)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ProfileAvatarPicker(
                  initials: 'AB',
                  role: widget.role,
                  size: 150,
                  onImageSelected: (imageBytes) {
                    print('Image selected: ${imageBytes?.length} bytes');
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Medium avatar picker
          Center(
            child: Column(
              children: [
                Text(
                  'Avatar Picker (Medium)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ProfileAvatarPicker(
                  initials: 'CD',
                  role: widget.role,
                  size: 100,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Status avatars row
          Text(
            'Status Avatars',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  StatusAvatar(
                    initials: 'ON',
                    statusColor: Colors.green,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text('Online', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              ),
              Column(
                children: [
                  StatusAvatar(
                    initials: 'OF',
                    statusColor: Colors.grey,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text('Offline', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              ),
              Column(
                children: [
                  StatusAvatar(
                    initials: 'BS',
                    statusColor: Colors.orange,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text('Busy', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // With network image
          Text(
            'With Network Image',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: StatusAvatar(
              imageUrl: 'https://picsum.photos/200/200?random=1',
              initials: 'NI',
              statusColor: Colors.green,
              size: 60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Review Demo',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          
          TripReviewStepper(
            role: widget.role,
            tripData: {
              'tripId': 'TRIP_001',
              'driverName': 'Nguyễn Văn A',
              'passengerName': 'Trần Thị B',
              'from': 'Quận 1, TP.HCM',
              'to': 'Quận 7, TP.HCM',
              'duration': '45 phút',
              'totalPrice': '150',
            },
            onReviewCompleted: (reviewData) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Đánh giá hoàn thành'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rating: ${reviewData['rating']} sao'),
                      Text('Tags: ${reviewData['tags'].join(', ')}'),
                      Text('Comment: ${reviewData['comment']}'),
                      Text('Recommend: ${reviewData['wouldRecommend']}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
