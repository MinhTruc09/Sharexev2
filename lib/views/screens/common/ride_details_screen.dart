import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/booking/booking_cubit.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart' as ride_entity;
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/views/widgets/map/map_tracking_widget.dart';
// import 'package:sharexev2/views/widgets/sharexe_widgets.dart'; // Unused
// import 'package:sharexev2/routes/app_routes.dart'; // Unused

class RideDetailsScreen extends StatefulWidget {
  final ride_entity.RideEntity ride;
  final String userRole; // 'PASSENGER' or 'DRIVER'

  const RideDetailsScreen({
    super.key,
    required this.ride,
    required this.userRole,
  });

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  int _selectedSeats = 1;
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingCubit(
        ServiceLocator.get(),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: BlocListener<BookingCubit, dynamic>(
          listener: (context, state) {
            // Implement proper state handling with BookingCubit when available
            // For now, use simple state checking
            if (state.toString().contains('loading')) {
              setState(() => _isBooking = true);
            } else if (state.toString().contains('success')) {
              setState(() => _isBooking = false);
              _showBookingSuccessDialog();
            } else if (state.toString().contains('error')) {
              setState(() => _isBooking = false);
              _showErrorDialog('Có lỗi xảy ra khi đặt chuyến');
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildMapSection(),
                _buildRideInfoSection(),
                if (widget.userRole == 'PASSENGER') _buildSeatSelectionSection(),
                if (widget.userRole == 'PASSENGER') _buildBookingSection(),
                if (widget.userRole == 'DRIVER') _buildDriverActionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: widget.userRole == 'DRIVER' 
          ? AppColors.driverPrimary 
          : AppColors.passengerPrimary,
      foregroundColor: Colors.white,
      title: Text(
        'Chi tiết chuyến đi',
        style: AppTextStyles.headingMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareRide(),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
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
            // Route map
            MapTrackingWidget(
              rideId: widget.ride.id.toString(),
              isDriverTracking: false,
              initialPosition: LatLng(widget.ride.startLat, widget.ride.startLng),
              destinationPosition: LatLng(widget.ride.endLat, widget.ride.endLng),
            ),
            // Route info overlay
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
                      Icons.route,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.ride.departure} → ${widget.ride.destination}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildRideInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: widget.userRole == 'DRIVER' 
                    ? AppColors.driverPrimary 
                    : AppColors.passengerPrimary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Thông tin chuyến đi',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Tài xế', widget.ride.driverName, Icons.person),
          _buildInfoRow('Thời gian', _formatDateTime(widget.ride.startTime), Icons.schedule),
          _buildInfoRow('Giá vé', '${widget.ride.pricePerSeat.toStringAsFixed(0)}₫/ghế', Icons.money),
          _buildInfoRow('Ghế trống', '${widget.ride.availableSeats}/${widget.ride.totalSeat}', Icons.people),
          _buildInfoRow('Trạng thái', _getStatusText(widget.ride.status), Icons.info),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatSelectionSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_seat,
                color: AppColors.passengerPrimary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Chọn số ghế',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Số ghế muốn đặt:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              _buildSeatCounter(),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceSummary(),
        ],
      ),
    );
  }

  Widget _buildSeatCounter() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _selectedSeats > 1 ? () => setState(() => _selectedSeats--) : null,
            icon: const Icon(Icons.remove),
          ),
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '$_selectedSeats',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _selectedSeats < (widget.ride.availableSeats ?? 0) 
                ? () => setState(() => _selectedSeats++) 
                : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final totalPrice = _selectedSeats * widget.ride.pricePerSeat;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.passengerPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.passengerPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tổng cộng:',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${totalPrice.toStringAsFixed(0)}₫',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.passengerPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isBooking ? null : _bookRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.passengerPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isBooking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Đặt chuyến',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _contactDriver(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.passengerPrimary,
                side: BorderSide(color: AppColors.passengerPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.chat),
              label: const Text('Nhắn tin với tài xế'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverActionsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _editRide(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.driverPrimary,
                side: BorderSide(color: AppColors.driverPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.edit),
              label: const Text('Chỉnh sửa chuyến đi'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _viewPassengers(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                side: BorderSide(color: AppColors.info),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.people),
              label: const Text('Xem hành khách'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText(ride_entity.RideStatus status) {
    switch (status) {
      case ride_entity.RideStatus.active:
        return 'Đang hoạt động';
      case ride_entity.RideStatus.completed:
        return 'Hoàn thành';
      case ride_entity.RideStatus.cancelled:
        return 'Đã hủy';
      case ride_entity.RideStatus.driverConfirmed:
        return 'Tài xế đã xác nhận';
      case ride_entity.RideStatus.inProgress:
        return 'Đang di chuyển';
    }
  }

  void _bookRide() {
    // Implement booking with BookingCubit when methods are available
    // context.read<BookingCubit>().selectSeats(_selectedSeats);
    // context.read<BookingCubit>().createBooking(widget.ride.id);
    
    // For now, show success dialog directly
    _showBookingSuccessDialog();
  }

  void _contactDriver() {
    // Navigate to chat with driver using AppRouter
    final driverEmail = widget.ride.driverEmail;
    Navigator.pushNamed(
      context,
      '/chat/room/$driverEmail',
      arguments: {
        'name': widget.ride.driverName,
        'email': driverEmail,
      },
    );
  }

  void _editRide() {
    // Navigate to edit ride screen
    Navigator.pushNamed(
      context,
      '/driver/edit-ride',
      arguments: widget.ride,
    );
  }

  void _viewPassengers() {
    // Navigate to passengers list
    Navigator.pushNamed(
      context,
      '/driver/passengers',
      arguments: widget.ride.id,
    );
  }

  void _shareRide() {
    // Share ride functionality - will integrate with Share plugin later
    // final shareText = 'Chia sẻ chuyến đi: ${widget.ride.departure} → ${widget.ride.destination}\n'
    //     'Thời gian: ${_formatDateTime(widget.ride.startTime)}\n'
    //     'Giá: ${widget.ride.pricePerSeat.toInt()}k VNĐ/chỗ\n'
    //     'Chỗ trống: ${widget.ride.availableSeats}';
    
    // Use Share plugin when available
    // Share.share(shareText);
    
    // For now, show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chia sẻ: ${widget.ride.departure} → ${widget.ride.destination}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showBookingSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 12),
            const Text('Đặt chuyến thành công'),
          ],
        ),
        content: const Text('Chuyến đi của bạn đã được đặt. Tài xế sẽ xác nhận trong thời gian sớm nhất.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Về trang chủ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.passengerPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xem lịch sử'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String? error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            const Text('Lỗi đặt chuyến'),
          ],
        ),
        content: Text(error ?? 'Có lỗi xảy ra khi đặt chuyến. Vui lòng thử lại.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
