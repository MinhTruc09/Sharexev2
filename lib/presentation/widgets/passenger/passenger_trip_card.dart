import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart';

/// Passenger-specific trip card widget
class PassengerTripCard extends StatelessWidget {
  final RideEntity? ride;
  final Map<String, dynamic>? trip;
  final VoidCallback onTap;

  const PassengerTripCard({
    super.key,
    this.ride,
    this.trip,
    required this.onTap,
  }) : assert(ride != null || trip != null, 'Either ride or trip must be provided');

  @override
  Widget build(BuildContext context) {
    // Use ride data if available, otherwise use trip data
    final departure = ride?.departure ?? trip?['departure'] ?? '';
    final destination = ride?.destination ?? trip?['destination'] ?? '';
    final startTime = ride?.startTime ?? DateTime.now();
    final pricePerSeat = ride?.pricePerSeat ?? trip?['price'] ?? 0.0;
    final availableSeats = ride?.availableSeats ?? trip?['availableSeats'] ?? 0;
    final totalSeats = ride?.totalSeat ?? trip?['totalSeats'] ?? 4;
    final driverName = ride?.driverName ?? trip?['driverName'] ?? 'Tài xế';
    final vehicleInfo = trip?['vehicleInfo'] ?? '${ride?.vehicle?.brand} ${ride?.vehicle?.model}';
    final rating = trip?['rating'] ?? 4.8;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route and time
            Row(
              children: [
                Expanded(
                  child: _buildRouteInfo(departure, destination, startTime),
                ),
                _buildPriceInfo(pricePerSeat, availableSeats, totalSeats),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Driver info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.passengerPrimary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.passengerPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (vehicleInfo.isNotEmpty)
                        Text(
                          vehicleInfo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewDetails(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.passengerPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Chi tiết',
                      style: TextStyle(color: AppColors.passengerPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: availableSeats > 0 ? () => _bookSeat(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.passengerPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      availableSeats > 0 ? 'Đặt chỗ' : 'Hết chỗ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo(String departure, String destination, DateTime startTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Route
        Row(
          children: [
            Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.grabGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: 20,
                  color: Colors.grey.shade300,
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.grabOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    departure,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    destination,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Time
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${startTime.day}/${startTime.month}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInfo(double price, int availableSeats, int totalSeats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${price.toStringAsFixed(0)}đ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.passengerPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: availableSeats > 0 
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$availableSeats/$totalSeats chỗ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: availableSeats > 0 ? AppColors.success : AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  void _viewDetails(BuildContext context) {
    // Navigate to trip details
    onTap();
  }

  void _bookSeat(BuildContext context) {
    // Show booking confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đặt chỗ'),
        content: const Text('Bạn có muốn đặt chỗ cho chuyến đi này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processBooking(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.passengerPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đặt chỗ'),
          ),
        ],
      ),
    );
  }

  void _processBooking(BuildContext context) {
    // TODO: Implement booking logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đặt chỗ thành công!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
