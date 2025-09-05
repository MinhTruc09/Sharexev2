import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/views/widgets/sharexe_widgets.dart';

/// Widget card hiển thị thông tin chuyến đi
class RideCardWidget extends StatelessWidget {
  final dynamic ride; // RideEntity from your data models
  final VoidCallback? onTap;
  final bool showBookButton;
  final bool showDriverInfo;
  final VoidCallback? onBookTap;

  const RideCardWidget({
    super.key,
    required this.ride,
    this.onTap,
    this.showBookButton = false,
    this.showDriverInfo = true,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildRouteInfo(),
                  const SizedBox(height: 12),
                  _buildTimeAndPriceInfo(),
                  if (showDriverInfo) ...[
                    const SizedBox(height: 12),
                    _buildDriverInfo(),
                  ],
                ],
              ),
            ),
            if (showBookButton) _buildBookingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo() {
    return Row(
      children: [
        // Route visualization
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 24,
              color: AppColors.borderMedium,
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Route details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ride.departure ?? 'Điểm đi',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                ride.startAddress ?? '',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Text(
                ride.destination ?? 'Điểm đến',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                ride.endAddress ?? '',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // Status and seats
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusText(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.airline_seat_recline_normal,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${ride.availableSeats}/${ride.totalSeat} ghế',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeAndPriceInfo() {
    return Row(
      children: [
        // Time info
        Expanded(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatTime(ride.startTime),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDate(ride.startTime),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Price info
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${ride.pricePerSeat?.toStringAsFixed(0) ?? '0'}₫',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'mỗi ghế',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          ShareXeUserAvatar(
            imageUrl: ride.driverAvatarUrl,
            name: ride.driverName,
            role: 'DRIVER',
            status: UserStatus.online,
            radius: 20,
            showRoleBadge: false,
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.driverName ?? 'Tài xế',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 12,
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      '4.0 (25 đánh giá)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Vehicle info
          if (ride.vehicle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.driverPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${ride.vehicle.brand} ${ride.vehicle.model}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.driverPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Còn ${ride.availableSeats} ghế trống',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Khởi hành ${_getTimeUntilDeparture()}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          ElevatedButton(
            onPressed: ride.availableSeats > 0 ? (onBookTap ?? onTap) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.passengerPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              ride.availableSeats > 0 ? 'Đặt chỗ' : 'Hết chỗ',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    final status = ride.status?.toUpperCase() ?? '';
    switch (status) {
      case 'ACTIVE':
        return AppColors.success;
      case 'COMPLETED':
        return AppColors.info;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _getStatusText() {
    final status = ride.status?.toUpperCase() ?? '';
    switch (status) {
      case 'ACTIVE':
        return 'Đang hoạt động';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return 'Chờ xác nhận';
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;
    
    if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Ngày mai';
    } else if (difference == -1) {
      return 'Hôm qua';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  String _getTimeUntilDeparture() {
    if (ride.startTime == null) return '';
    
    final now = DateTime.now();
    final difference = ride.startTime.difference(now);
    
    if (difference.inDays > 0) {
      return 'sau ${difference.inDays} ngày';
    } else if (difference.inHours > 0) {
      return 'sau ${difference.inHours} giờ';
    } else if (difference.inMinutes > 0) {
      return 'sau ${difference.inMinutes} phút';
    } else {
      return 'sắp khởi hành';
    }
  }
}
