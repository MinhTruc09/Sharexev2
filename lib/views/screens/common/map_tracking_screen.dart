import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/di/service_locator.dart';
import '../../../logic/tracking/tracking_cubit.dart';
import '../../../config/theme.dart';
import '../../widgets/map/map_tracking_widget.dart';
import '../../widgets/tracking/tracking_info_widget.dart';
import '../../../services/location_service.dart';

/// Map Tracking Screen - Real-time tracking với OpenStreetMap
class MapTrackingScreen extends StatefulWidget {
  final int rideId;
  final String userRole; // 'PASSENGER' or 'DRIVER'
  final bool isDriverTracking; // true for driver, false for passenger
  final LatLng? pickupLocation;
  final LatLng? destinationLocation;
  
  const MapTrackingScreen({
    super.key,
    required this.rideId,
    required this.userRole,
    this.isDriverTracking = false,
    this.pickupLocation,
    this.destinationLocation,
  });

  @override
  State<MapTrackingScreen> createState() => _MapTrackingScreenState();
}

class _MapTrackingScreenState extends State<MapTrackingScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isTracking = false;
  bool _isFullScreen = false;

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
      create: (_) => TrackingCubit(ServiceLocator.get())
        ..startTracking(widget.rideId.toString()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _isFullScreen ? null : _buildAppBar(),
        body: Column(
          children: [
            if (!_isFullScreen) 
              Padding(
                padding: const EdgeInsets.all(16),
                child: TrackingInfoWidget(
                  isCompact: false,
                ),
              ),
            Expanded(
              child: MapTrackingWidget(
                rideId: widget.rideId.toString(),
                isDriverTracking: widget.isDriverTracking,
                initialPosition: widget.pickupLocation,
                destinationPosition: widget.destinationLocation,
              ),
            ),
            if (!_isFullScreen) _buildControlsSection(),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: widget.userRole == 'DRIVER' 
          ? AppColors.driverPrimary 
          : AppColors.passengerPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isDriverTracking ? 'Theo dõi vị trí' : 'Theo dõi tài xế',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          Text(
            'Chuyến đi #${widget.rideId}',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
          onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshLocation(),
        ),
      ],
    );
  }




  Widget _buildMapSection() {
    return Container(
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
              rideId: widget.rideId.toString(),
              isDriverTracking: widget.isDriverTracking,
              initialPosition: widget.pickupLocation,
              destinationPosition: widget.destinationLocation,
            ),
            // Map controls overlay
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  _buildMapControlButton(
                    Icons.my_location,
                    'Vị trí hiện tại',
                    () => _centerOnCurrentLocation(),
                  ),
                  const SizedBox(height: 8),
                  _buildMapControlButton(
                    Icons.zoom_in,
                    'Phóng to',
                    () => _zoomIn(),
                  ),
                  const SizedBox(height: 8),
                  _buildMapControlButton(
                    Icons.zoom_out,
                    'Thu nhỏ',
                    () => _zoomOut(),
                  ),
                ],
              ),
            ),
            // Driver/Passenger location indicator
            if (widget.isDriverTracking)
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_car,
                        color: AppColors.driverPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vị trí tài xế',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        color: AppColors.passengerPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vị trí của bạn',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // ETA and distance info
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ETA: 15 phút',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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

  Widget _buildMapControlButton(IconData icon, String tooltip, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isTracking ? _stopTracking : _startTracking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTracking ? AppColors.error : AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                  label: Text(_isTracking ? 'Dừng theo dõi' : 'Bắt đầu theo dõi'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showTrackingSettings(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.userRole == 'DRIVER' 
                        ? AppColors.driverPrimary 
                        : AppColors.passengerPrimary,
                    side: BorderSide(
                      color: widget.userRole == 'DRIVER' 
                          ? AppColors.driverPrimary 
                          : AppColors.passengerPrimary,
                    ),
                  ),
                  icon: const Icon(Icons.settings),
                  label: const Text('Cài đặt'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareLocation(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: BorderSide(color: AppColors.info),
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text('Chia sẻ vị trí'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRouteInfo(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: BorderSide(color: AppColors.warning),
                  ),
                  icon: const Icon(Icons.route),
                  label: const Text('Thông tin tuyến'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _toggleFullScreen(),
      backgroundColor: widget.userRole == 'DRIVER' 
          ? AppColors.driverPrimary 
          : AppColors.passengerPrimary,
      child: Icon(
        _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
        color: Colors.white,
      ),
    );
  }

  void _startTracking() {
    setState(() {
      _isTracking = true;
    });
    context.read<TrackingCubit>().startTracking(widget.rideId.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã bắt đầu theo dõi vị trí'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
    });
    context.read<TrackingCubit>().stopTracking(widget.rideId.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã dừng theo dõi vị trí'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _refreshLocation() {
    context.read<TrackingCubit>().refreshTracking(widget.rideId.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã làm mới vị trí'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _centerOnCurrentLocation() async {
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      if (mounted) {
        if (position != null) {
          // Map centering is now handled by MapTrackingWidget
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã định vị về vị trí: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Không thể lấy vị trí hiện tại'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lấy vị trí: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _zoomIn() {
    // Map zoom is now handled by MapTrackingWidget
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã phóng to bản đồ'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _zoomOut() {
    // Map zoom is now handled by MapTrackingWidget
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã thu nhỏ bản đồ'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _showTrackingSettings() {
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Cài đặt theo dõi',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: AppColors.info),
              title: const Text('Tần suất cập nhật'),
              subtitle: const Text('Mỗi 5 giây'),
              onTap: () {
                Navigator.pop(context);
                _showUpdateFrequencySettings();
              },
            ),
            ListTile(
              leading: Icon(Icons.battery_alert, color: AppColors.warning),
              title: const Text('Tiết kiệm pin'),
              subtitle: const Text('Tự động giảm tần suất'),
              onTap: () {
                Navigator.pop(context);
                _showBatterySavingSettings();
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: AppColors.passengerPrimary),
              title: const Text('Thông báo vị trí'),
              subtitle: const Text('Thông báo khi đến gần'),
              onTap: () {
                Navigator.pop(context);
                _showNotificationSettings();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _shareLocation() {
    // Mock implementation - replace with real sharing functionality
    // This would typically use the share_plus package to share location data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chức năng chia sẻ vị trí sẽ được phát triển'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  /// Show update frequency settings dialog
  void _showUpdateFrequencySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tần suất cập nhật'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('Mỗi 2 giây'),
              value: 2,
              groupValue: 5, // Current value
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật tần suất: Mỗi 2 giây')),
                );
              },
            ),
            RadioListTile<int>(
              title: const Text('Mỗi 5 giây'),
              value: 5,
              groupValue: 5,
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật tần suất: Mỗi 5 giây')),
                );
              },
            ),
            RadioListTile<int>(
              title: const Text('Mỗi 10 giây'),
              value: 10,
              groupValue: 5,
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật tần suất: Mỗi 10 giây')),
                );
              },
            ),
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

  /// Show battery saving settings dialog
  void _showBatterySavingSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tiết kiệm pin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Tự động tiết kiệm pin'),
              subtitle: const Text('Giảm tần suất cập nhật khi pin thấp'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tiết kiệm pin: ${value ? "Bật" : "Tắt"}')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Giảm độ sáng màn hình'),
              subtitle: const Text('Tự động giảm độ sáng khi theo dõi'),
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Giảm độ sáng: ${value ? "Bật" : "Tắt"}')),
                );
              },
            ),
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

  /// Show notification settings dialog
  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo vị trí'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Thông báo khi đến gần'),
              subtitle: const Text('Thông báo khi cách điểm đến 500m'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thông báo đến gần: ${value ? "Bật" : "Tắt"}')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Thông báo khi đến nơi'),
              subtitle: const Text('Thông báo khi đã đến điểm đến'),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thông báo đến nơi: ${value ? "Bật" : "Tắt"}')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Thông báo lệch đường'),
              subtitle: const Text('Thông báo khi lệch khỏi tuyến đường'),
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thông báo lệch đường: ${value ? "Bật" : "Tắt"}')),
                );
              },
            ),
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

  void _showRouteInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thông tin tuyến đường'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRouteInfoItem('Điểm đi', 'Hà Nội'),
            _buildRouteInfoItem('Điểm đến', 'Hải Phòng'),
            _buildRouteInfoItem('Khoảng cách', '120 km'),
            _buildRouteInfoItem('Thời gian dự kiến', '2 giờ 30 phút'),
            _buildRouteInfoItem('Phương tiện', 'Ô tô 4 chỗ'),
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

  Widget _buildRouteInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
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
    );
  }
}
