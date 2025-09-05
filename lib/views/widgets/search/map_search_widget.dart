import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/theme.dart';
import '../../../logic/ride/ride_cubit.dart';
import '../../../data/models/ride/entities/ride_entity.dart';

/// Widget for map-based ride search
class MapSearchWidget extends StatefulWidget {
  final LatLng? initialCenter;
  final double initialZoom;
  final Function(LatLng)? onLocationSelected;
  final Function(RideEntity)? onRideSelected;
  final List<RideEntity> rides;
  final bool showRideMarkers;

  const MapSearchWidget({
    Key? key,
    this.initialCenter,
    this.initialZoom = 13.0,
    this.onLocationSelected,
    this.onRideSelected,
    this.rides = const [],
    this.showRideMarkers = true,
  }) : super(key: key);

  @override
  State<MapSearchWidget> createState() => _MapSearchWidgetState();
}

class _MapSearchWidgetState extends State<MapSearchWidget> {
  MapController? _mapController;
  late LatLng _currentCenter;
  final List<Marker> _markers = [];
  LatLng? _selectedLocation;
  RideEntity? _selectedRide;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCenter = widget.initialCenter ?? const LatLng(21.0285, 105.8542); // Hanoi
    _setupMarkers();
  }

  void _setupMarkers() {
    _markers.clear();
    
    if (widget.showRideMarkers) {
      // Add ride markers
      for (int i = 0; i < widget.rides.length; i++) {
        final ride = widget.rides[i];
        _markers.add(_createRideMarker(ride, i));
      }
    }
    
    // Add selected location marker
    if (_selectedLocation != null) {
      _markers.add(_createLocationMarker(_selectedLocation!));
    }
  }

  Marker _createRideMarker(RideEntity ride, int index) {
    return Marker(
      point: LatLng(ride.startLat, ride.startLng),
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _onRideMarkerTapped(ride),
        child: Container(
          decoration: BoxDecoration(
            color: _selectedRide?.id == ride.id 
                ? AppColors.passengerPrimary 
                : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.passengerPrimary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.directions_car,
                  color: _selectedRide?.id == ride.id 
                      ? Colors.white 
                      : AppColors.passengerPrimary,
                  size: 20,
                ),
              ),
              // Price tag
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.passengerPrimary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Text(
                    '${ride.pricePerSeat.toInt()}k',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Marker _createLocationMarker(LatLng location) {
    return Marker(
      point: location,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.location_on,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _onRideMarkerTapped(RideEntity ride) {
    setState(() {
      _selectedRide = _selectedRide?.id == ride.id ? null : ride;
    });
    widget.onRideSelected?.call(ride);
  }

  void _onMapTapped(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _selectedRide = null;
    });
    _setupMarkers();
    widget.onLocationSelected?.call(point);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentCenter,
            initialZoom: widget.initialZoom,
            onTap: _onMapTapped,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // OSM Tile Layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.sharexe',
              maxZoom: 19,
            ),
            
            // Markers Layer
            MarkerLayer(markers: _markers),
          ],
        ),
        
        // Map controls
        _buildMapControls(),
        
        // Selected ride info
        if (_selectedRide != null)
          _buildSelectedRideInfo(),
        
        // Search area button
        _buildSearchAreaButton(),
      ],
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          _buildControlButton(
            icon: Icons.my_location,
            onPressed: _centerOnCurrentLocation,
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.zoom_in,
            onPressed: _zoomIn,
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.zoom_out,
            onPressed: _zoomOut,
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.layers,
            onPressed: _toggleMapType,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSelectedRideInfo() {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.passengerPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: AppColors.passengerPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_selectedRide!.departure} → ${_selectedRide!.destination}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _selectedRide!.driverName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_selectedRide!.pricePerSeat.toInt()},000₫',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.passengerPrimary,
                        ),
                      ),
                      Text(
                        '${_selectedRide!.availableSeats} chỗ trống',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(_selectedRide!.startTime),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Handle ride booking
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.passengerPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Đặt chỗ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAreaButton() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: ElevatedButton.icon(
        onPressed: _searchInCurrentArea,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.passengerPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.search),
        label: const Text('Tìm kiếm trong khu vực này'),
      ),
    );
  }

  void _centerOnCurrentLocation() {
    // Get current location and center map
    if (_mapController != null) {
      // For now, center on Hanoi. In production, use location service
      _mapController!.move(_currentCenter, 15.0);
      
      // Show message to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã di chuyển đến vị trí hiện tại'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _zoomIn() {
    if (_mapController != null) {
      final currentZoom = _mapController!.camera.zoom;
      _mapController!.move(_mapController!.camera.center, currentZoom + 1);
    }
  }

  void _zoomOut() {
    if (_mapController != null) {
      final currentZoom = _mapController!.camera.zoom;
      _mapController!.move(_mapController!.camera.center, currentZoom - 1);
    }
  }

  void _toggleMapType() {
    // Implement map type toggle (e.g., satellite view)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng đổi loại bản đồ đang được phát triển'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _searchInCurrentArea() {
    final bounds = _mapController?.camera.visibleBounds;
    if (bounds != null) {
      // Trigger search in visible area
      context.read<RideCubit>().searchRidesInArea(
        southwest: bounds.southWest,
        northeast: bounds.northEast,
      );
      
      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang tìm kiếm chuyến đi trong khu vực này...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      return 'Hôm nay ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ngày mai ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
