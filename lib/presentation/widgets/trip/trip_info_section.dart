import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/routes/app_routes.dart';

class TripInfoSection extends StatelessWidget {
  final Map<String, dynamic> tripData;

  const TripInfoSection({
    super.key,
    required this.tripData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin chuyến đi',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Trip details
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Điểm đi',
            value: tripData['origin'] ?? 'Chưa xác định',
          ),
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Điểm đến',
            value: tripData['destination'] ?? 'Chưa xác định',
            iconColor: const Color(0xFF38A169),
          ),
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Thời gian khởi hành',
            value: tripData['departureTime'] ?? 'Chưa xác định',
          ),
          _buildInfoRow(
            icon: Icons.event_seat,
            label: 'Số ghế trống',
            value: '${tripData['availableSeats'] ?? 0} chỗ',
          ),
          _buildInfoRow(
            icon: Icons.attach_money,
            label: 'Giá vé',
            value: '${tripData['price'] ?? 0}k VNĐ',
            valueColor: ThemeManager.getPrimaryColorForRole('PASSENGER'),
            fontWeight: FontWeight.bold,
          ),
          
          const SizedBox(height: 16),
          
          // Driver info
          _buildDriverInfo(context),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    Color? valueColor,
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? const Color(0xFF757575),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757575),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ).copyWith(
              color: valueColor ?? Colors.black87,
              fontWeight: fontWeight ?? FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeManager.getPrimaryColorForRole('PASSENGER').withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeManager.getPrimaryColorForRole('PASSENGER').withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: ThemeManager.getPrimaryColorForRole('PASSENGER'),
            child: Text(
              tripData['driverInitials'] ?? 'TX',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tripData['driverName'] ?? 'Tài xế',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tripData['rating'] ?? 0.0}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tripData['vehicleType'] ?? 'Xe hơi',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoute.chat,
                arguments: {
                  'roomId': 'trip_${tripData['id']}',
                  'participantName': tripData['driverName'] ?? 'Tài xế',
                  'participantEmail': 'driver@example.com',
                },
              );
            },
            icon: const Icon(Icons.chat),
            color: ThemeManager.getPrimaryColorForRole('PASSENGER'),
          ),
        ],
      ),
    );
  }
}
