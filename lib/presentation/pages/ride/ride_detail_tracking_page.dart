import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/tracking/tracking_cubit.dart';
import 'package:sharexev2/presentation/widgets/common/auth_button.dart';

class RideDetailTrackingPage extends StatelessWidget {
  final int rideId;
  final String role;

  const RideDetailTrackingPage({
    super.key,
    required this.rideId,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrackingCubit(
        trackingRepository: ServiceLocator.get(),
      )..startTracking(rideId),
      child: RideDetailTrackingView(rideId: rideId, role: role),
    );
  }
}

class RideDetailTrackingView extends StatefulWidget {
  final int rideId;
  final String role;

  const RideDetailTrackingView({
    super.key,
    required this.rideId,
    required this.role,
  });

  @override
  State<RideDetailTrackingView> createState() => _RideDetailTrackingViewState();
}

class _RideDetailTrackingViewState extends State<RideDetailTrackingView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isMapExpanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPassenger = widget.role == 'PASSENGER';
    final primaryColor = isPassenger ? AppColors.passengerPrimary : AppColors.driverPrimary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Theo dõi chuyến đi'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TrackingCubit>().refreshLocation();
            },
          ),
        ],
      ),
      body: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          if (state.status == TrackingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TrackingStatus.error) {
            return _buildErrorState(context, state.error);
          }

          return Column(
            children: [
              // Map Section
              Expanded(
                flex: _isMapExpanded ? 3 : 2,
                child: _buildMapSection(context, state),
              ),
              
              // Trip Info Section
              Expanded(
                flex: _isMapExpanded ? 1 : 2,
                child: _buildTripInfoSection(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(error ?? 'Không thể tải thông tin chuyến đi'),
          const SizedBox(height: 16),
          AuthButton(
            text: 'Thử lại',
            role: widget.role,
            onPressed: () {
              context.read<TrackingCubit>().startTracking(widget.rideId);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, TrackingState state) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // Mock Map (replace with real map widget)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade300,
                  Colors.green.shade300,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                // Route line
                Positioned(
                  left: 50,
                  top: 100,
                  right: 50,
                  bottom: 100,
                  child: CustomPaint(
                    painter: RoutePainter(),
                  ),
                ),
                
                // Start point
                Positioned(
                  left: 60,
                  top: 110,
                  child: _buildMapMarker(
                    Icons.radio_button_checked,
                    AppColors.grabGreen,
                    'Điểm đón',
                  ),
                ),
                
                // End point
                Positioned(
                  right: 60,
                  bottom: 110,
                  child: _buildMapMarker(
                    Icons.location_on,
                    AppColors.grabOrange,
                    'Điểm đến',
                  ),
                ),
                
                // Vehicle position (animated)
                if (state.currentLocation != null)
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.4,
                    top: MediaQuery.of(context).size.height * 0.3,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: _buildVehicleMarker(),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          
          // Map controls
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "expand",
                  onPressed: () {
                    setState(() {
                      _isMapExpanded = !_isMapExpanded;
                    });
                  },
                  backgroundColor: Colors.white,
                  child: Icon(
                    _isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "location",
                  onPressed: () {
                    context.read<TrackingCubit>().centerOnVehicle();
                  },
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.my_location,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          // Trip status overlay
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(state.tripStatus),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(state.tripStatus),
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getStatusText(state.tripStatus),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker(IconData icon, Color color, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleMarker() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.driverPrimary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.driverPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.directions_car,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildTripInfoSection(BuildContext context, TrackingState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip progress
          _buildProgressIndicator(state),
          const SizedBox(height: 20),
          
          // Trip details
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Thời gian còn lại', '${state.estimatedTime ?? 15} phút'),
                  _buildInfoRow('Khoảng cách', '${state.remainingDistance ?? 5.2} km'),
                  _buildInfoRow('Tài xế', state.driverName ?? 'Nguyễn Văn B'),
                  _buildInfoRow('Biển số xe', state.vehiclePlate ?? '29A-12345'),
                  _buildInfoRow('Loại xe', state.vehicleType ?? 'Toyota Vios'),
                  
                  const SizedBox(height: 20),
                  
                  // Action buttons
                  if (widget.role == 'PASSENGER') ...[
                    AuthButton(
                      text: 'Gọi tài xế',
                      role: widget.role,
                      icon: Icons.phone,
                      onPressed: () => _callDriver(),
                    ),
                    const SizedBox(height: 12),
                    AuthButton(
                      text: 'Nhắn tin',
                      role: widget.role,
                      isOutlined: true,
                      icon: Icons.message,
                      onPressed: () => _messageDriver(),
                    ),
                  ] else ...[
                    AuthButton(
                      text: 'Gọi hành khách',
                      role: widget.role,
                      icon: Icons.phone,
                      onPressed: () => _callPassenger(),
                    ),
                    const SizedBox(height: 12),
                    AuthButton(
                      text: 'Hoàn thành chuyến',
                      role: widget.role,
                      onPressed: () => _completeTrip(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(TrackingState state) {
    final progress = state.tripProgress ?? 0.3;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tiến độ chuyến đi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.role == 'PASSENGER' ? AppColors.passengerPrimary : AppColors.driverPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'in_progress':
        return AppColors.grabGreen;
      case 'waiting':
        return AppColors.warning;
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'in_progress':
        return Icons.directions_car;
      case 'waiting':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'in_progress':
        return 'Đang di chuyển';
      case 'waiting':
        return 'Đang chờ';
      case 'completed':
        return 'Hoàn thành';
      default:
        return 'Đang cập nhật';
    }
  }

  void _callDriver() {
    // TODO: Implement call driver
  }

  void _messageDriver() {
    // TODO: Navigate to chat
  }

  void _callPassenger() {
    // TODO: Implement call passenger
  }

  void _completeTrip() {
    // TODO: Complete trip logic
  }
}

// Custom painter for route line
class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.driverPrimary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.3, size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
