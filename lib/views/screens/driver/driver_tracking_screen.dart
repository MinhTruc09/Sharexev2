import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/tracking/tracking_cubit.dart';
// TrackingState is imported via part directive in cubit
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/views/widgets/sharexe_widgets.dart';
import 'package:sharexev2/views/widgets/map/map_tracking_widget.dart';

enum TripPhase {
  waiting,
  driverEnRoute,
  arrived,
  pickup,
  inProgress,
  completed,
  cancelled,
}

/// Driver Tracking Screen - Real-time location tracking
class DriverTrackingScreen extends StatefulWidget {
  final BookingEntity booking;
  
  const DriverTrackingScreen({
    super.key,
    required this.booking,
  });

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  TripPhase _currentPhase = TripPhase.driverEnRoute;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Handle scroll if needed
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocProvider(
      create: (_) => TrackingCubit(
        ServiceLocator.get(),
      )..startTracking(widget.booking.rideId.toString()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildTripPhaseIndicator(),
            _buildMapSection(),
            _buildPassengerInfo(),
            _buildTripDetails(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.driverPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theo dõi chuyến đi',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          Text(
            '${widget.booking.departure} → ${widget.booking.destination}',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat),
          onPressed: () => _openChat(),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreOptions(),
        ),
      ],
    );
  }

  Widget _buildTripPhaseIndicator() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(
                _getPhaseIcon(_currentPhase),
                color: _getPhaseColor(_currentPhase),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getPhaseTitle(_currentPhase),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _getPhaseTime(_currentPhase),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressStep(TripPhase.driverEnRoute, 'Đang đến'),
        _buildProgressLine(),
        _buildProgressStep(TripPhase.arrived, 'Đã đến'),
        _buildProgressLine(),
        _buildProgressStep(TripPhase.inProgress, 'Đang di chuyển'),
        _buildProgressLine(),
        _buildProgressStep(TripPhase.completed, 'Hoàn thành'),
      ],
    );
  }

  Widget _buildProgressStep(TripPhase phase, String label) {
    final isActive = _currentPhase == phase;
    final isCompleted = _isPhaseCompleted(phase);
    
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted 
                ? AppColors.success 
                : isActive 
                    ? _getPhaseColor(phase)
                    : AppColors.borderLight,
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : isActive
                  ? Icon(Icons.circle, color: Colors.white, size: 16)
                  : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isActive || isCompleted 
                ? AppColors.textPrimary 
                : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: AppColors.borderLight,
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Real-time tracking map
            MapTrackingWidget(
              rideId: widget.booking.id.toString(),
              isDriverTracking: true,
              initialPosition: const LatLng(21.0285, 105.8542), // Default to Hanoi
              destinationPosition: const LatLng(21.0245, 105.8412), // Default destination
            ),
            // Current location indicator
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.driverPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            // ETA indicator
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ETA: 15 phút',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '2.5 km',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          ShareXeUserAvatar(
            name: widget.booking.passengerName,
            imageUrl: widget.booking.passengerAvatarUrl,
            role: 'PASSENGER',
            status: UserStatus.online,
            radius: 25,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.passengerName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.booking.seatsBooked} ghế • ${widget.booking.formattedPricePerSeat}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.booking.passengerPhone,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openChat(),
            icon: Icon(
              Icons.chat_bubble_outline,
              color: AppColors.driverPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
          _buildDetailRow(
            Icons.location_on,
            'Điểm đón',
            widget.booking.departure,
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.flag,
            'Điểm đến',
            widget.booking.destination,
            AppColors.error,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.access_time,
                  'Thời gian',
                  widget.booking.formattedStartTime,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.people,
                  'Ghế',
                  '${widget.booking.seatsBooked} ghế',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.attach_money,
                  'Giá/ghế',
                  widget.booking.formattedPricePerSeat,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.payments,
                  'Tổng tiền',
                  widget.booking.formattedTotalPrice,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          return Column(
            children: [
              if (_currentPhase == TripPhase.driverEnRoute) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _markAsArrived(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.location_on),
                    label: const Text('Đã đến điểm đón'),
                  ),
                ),
              ] else if (_currentPhase == TripPhase.arrived) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _startTrip(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.driverPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Bắt đầu chuyến đi'),
                  ),
                ),
              ] else if (_currentPhase == TripPhase.inProgress) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _completeTrip(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Hoàn thành chuyến đi'),
                  ),
                ),
              ] else if (_currentPhase == TripPhase.completed) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showReviewDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.star),
                    label: const Text('Đánh giá chuyến đi'),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openChat(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.driverPrimary,
                        side: BorderSide(color: AppColors.driverPrimary),
                      ),
                      icon: const Icon(Icons.chat),
                      label: const Text('Nhắn tin'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _callPassenger(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: BorderSide(color: AppColors.success),
                      ),
                      icon: const Icon(Icons.phone),
                      label: const Text('Gọi'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getPhaseIcon(TripPhase phase) {
    switch (phase) {
      case TripPhase.driverEnRoute:
        return Icons.directions_car;
      case TripPhase.arrived:
        return Icons.location_on;
      case TripPhase.inProgress:
        return Icons.play_arrow;
      case TripPhase.completed:
        return Icons.check_circle;
      case TripPhase.cancelled:
        return Icons.cancel;
      default:
        return Icons.access_time;
    }
  }

  Color _getPhaseColor(TripPhase phase) {
    switch (phase) {
      case TripPhase.driverEnRoute:
        return AppColors.info;
      case TripPhase.arrived:
        return AppColors.warning;
      case TripPhase.inProgress:
        return AppColors.driverPrimary;
      case TripPhase.completed:
        return AppColors.success;
      case TripPhase.cancelled:
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  String _getPhaseTitle(TripPhase phase) {
    switch (phase) {
      case TripPhase.driverEnRoute:
        return 'Đang đến điểm đón';
      case TripPhase.arrived:
        return 'Đã đến điểm đón';
      case TripPhase.inProgress:
        return 'Đang di chuyển';
      case TripPhase.completed:
        return 'Chuyến đi hoàn thành';
      case TripPhase.cancelled:
        return 'Chuyến đi đã hủy';
      default:
        return 'Chờ xử lý';
    }
  }

  String _getPhaseTime(TripPhase phase) {
    switch (phase) {
      case TripPhase.driverEnRoute:
        return '15 phút';
      case TripPhase.arrived:
        return 'Đã đến';
      case TripPhase.inProgress:
        return '25 phút';
      case TripPhase.completed:
        return 'Hoàn thành';
      case TripPhase.cancelled:
        return 'Đã hủy';
      default:
        return 'Chờ xử lý';
    }
  }

  bool _isPhaseCompleted(TripPhase phase) {
    switch (_currentPhase) {
      case TripPhase.driverEnRoute:
        return false;
      case TripPhase.arrived:
        return phase == TripPhase.driverEnRoute;
      case TripPhase.inProgress:
        return phase == TripPhase.driverEnRoute || phase == TripPhase.arrived;
      case TripPhase.completed:
        return phase != TripPhase.cancelled;
      case TripPhase.cancelled:
        return false;
      default:
        return false;
    }
  }

  void _markAsArrived() {
    setState(() {
      _currentPhase = TripPhase.arrived;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã cập nhật trạng thái: Đã đến điểm đón'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _startTrip() {
    setState(() {
      _currentPhase = TripPhase.inProgress;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã bắt đầu chuyến đi'),
        backgroundColor: AppColors.driverPrimary,
      ),
    );
  }

  void _completeTrip() {
    setState(() {
      _currentPhase = TripPhase.completed;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chuyến đi đã hoàn thành'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đánh giá chuyến đi'),
        content: const Text('Chức năng đánh giá đang được phát triển'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _openChat() {
    // Navigate to chat with passenger
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'roomId': 'driver_${widget.booking.id}_passenger',
        'otherUserEmail': 'passenger@example.com', // Get from ride data
        'otherUserName': 'Hành khách',
      },
    );
  }

  void _callPassenger() {
    // Implement phone call functionality using url_launcher
    // final phoneNumber = 'tel:+84123456789'; // Get from ride data
    // if (await canLaunchUrl(Uri.parse(phoneNumber))) {
    //   await launchUrl(Uri.parse(phoneNumber));
    // }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tính năng gọi điện sẽ được tích hợp'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Thông tin chuyến đi'),
              onTap: () {
                Navigator.pop(context);
                // Show trip info
                _showTripInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Báo cáo vấn đề'),
              onTap: () {
                Navigator.pop(context);
                // Report issue
                _reportIssue();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Hủy chuyến đi'),
              onTap: () {
                Navigator.pop(context);
                _cancelTrip();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _cancelTrip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hủy chuyến đi'),
        content: const Text('Bạn có chắc chắn muốn hủy chuyến đi này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentPhase = TripPhase.cancelled;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hủy chuyến'),
          ),
        ],
      ),
    );
  }

  void _showTripInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin chuyến đi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${widget.booking.id}'),
            const Text('Điểm đi: Hà Nội'),
            const Text('Điểm đến: TP.HCM'),
            const Text('Thời gian: 08:00'),
            const Text('Số ghế: 4'),
            const Text('Giá: 500,000 VNĐ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo cáo vấn đề'),
        content: const Text('Tính năng báo cáo vấn đề sẽ được tích hợp'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
