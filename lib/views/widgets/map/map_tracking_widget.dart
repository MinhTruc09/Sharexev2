import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/services/location_service.dart';
import 'package:sharexev2/data/services/tracking_service.dart';
import 'package:sharexev2/data/models/tracking/dtos/tracking_payload_dto.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/core/auth/auth_manager.dart';

/// Real-time tracking map widget
class MapTrackingWidget extends StatefulWidget {
  final String rideId;
  final bool isDriverTracking;
  final LatLng? initialPosition;
  final LatLng? destinationPosition;
  final double? zoomLevel;
  final bool showControls;

  const MapTrackingWidget({
    super.key,
    required this.rideId,
    required this.isDriverTracking,
    this.initialPosition,
    this.destinationPosition,
    this.zoomLevel = 15.0,
    this.showControls = true,
  });

  @override
  State<MapTrackingWidget> createState() => _MapTrackingWidgetState();
}

class _MapTrackingWidgetState extends State<MapTrackingWidget> {
  late MapController _mapController;
  late double _currentZoom;
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentZoom = widget.zoomLevel ?? 15.0;
    _initializeMap();
  }

  void _initializeMap() {
    // Set initial position
    _currentLocation = widget.initialPosition ?? const LatLng(21.0285, 105.8542); // Default to Hanoi
    
    // Generate route points (simplified)
    _generateRoutePoints();
    
    // Start tracking if driver
    if (widget.isDriverTracking) {
      _startLocationTracking();
    }
  }

  void _generateRoutePoints() {
    // Simple route generation between two points
    final start = widget.initialPosition ?? const LatLng(21.0285, 105.8542);
    final end = widget.destinationPosition ?? start;
    
    // Add intermediate points for a more realistic route
    _routePoints = [
      start,
      LatLng(
        start.latitude + (end.latitude - start.latitude) * 0.3,
        start.longitude + (end.longitude - start.longitude) * 0.3,
      ),
      LatLng(
        start.latitude + (end.latitude - start.latitude) * 0.7,
        start.longitude + (end.longitude - start.longitude) * 0.7,
      ),
      end,
    ];
  }

  void _startLocationTracking() {
    setState(() {
      _isTracking = true;
    });
    
    // Start real location tracking
    _startRealLocationTracking();
  }

  void _startRealLocationTracking() async {
    if (!_isTracking) return;
    
    try {
      // Import LocationService for real location tracking
      final locationService = LocationService();
      
      // Get current location
      final position = await locationService.getCurrentPosition();
      if (position != null && mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        
        // Send location to backend for real-time tracking
        await _sendLocationToBackend(position.latitude, position.longitude);
      }
      
      // Continue tracking every 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _isTracking) {
          _startRealLocationTracking();
        }
      });
    } catch (e) {
      debugPrint('Error in real location tracking: $e');
      // Fallback to simulated tracking if real tracking fails
      _simulateLocationUpdates();
    }
  }

  Future<void> _sendLocationToBackend(double latitude, double longitude) async {
    try {
      // Import TrackingService to send location to backend
      // This would integrate with the real tracking API
      debugPrint('Sending location to backend: $latitude, $longitude');
      
      // Real tracking service call
      try {
        final trackingService = ServiceLocator.get<TrackingService>();
        final authManager = AuthManager();
        final userEmail = authManager.getUserEmail() ?? 'unknown@example.com';
        
        final payload = TrackingPayloadDto(
          rideId: widget.rideId,
          driverEmail: userEmail,
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
        );
        
        final response = await trackingService.sendDriverLocation(widget.rideId, payload);
        
        if (response.success) {
          debugPrint('Location sent successfully to backend');
        } else {
          debugPrint('Failed to send location: ${response.message}');
        }
      } catch (e) {
        debugPrint('Error sending location to backend: $e');
      }
    } catch (e) {
      debugPrint('Error sending location to backend: $e');
    }
  }

  void _simulateLocationUpdates() {
    if (!_isTracking) return;
    
    // Fallback simulation for demo purposes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _isTracking) {
        setState(() {
          // Move current location along the route
          final progress = DateTime.now().millisecondsSinceEpoch % 10000 / 10000.0;
          final routeIndex = (progress * (_routePoints.length - 1)).floor();
          final nextIndex = (routeIndex + 1) % _routePoints.length;
          
          if (routeIndex < _routePoints.length - 1) {
            final current = _routePoints[routeIndex];
            final next = _routePoints[nextIndex];
            final localProgress = (progress * (_routePoints.length - 1)) - routeIndex;
            
            _currentLocation = LatLng(
              current.latitude + (next.latitude - current.latitude) * localProgress,
              current.longitude + (next.longitude - current.longitude) * localProgress,
            );
          }
        });
        
        _simulateLocationUpdates();
      }
    });
  }

  void _centerOnCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, _currentZoom);
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(1.0, 20.0);
    });
    _mapController.move(_currentLocation ?? const LatLng(21.0285, 105.8542), _currentZoom);
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(1.0, 20.0);
    });
    _mapController.move(_currentLocation ?? const LatLng(21.0285, 105.8542), _currentZoom);
  }

  @override
  void dispose() {
    _isTracking = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLocation ?? const LatLng(21.0285, 105.8542),
            initialZoom: _currentZoom,
            minZoom: 1.0,
            maxZoom: 20.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // Tile layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sharexev2.app',
            ),
            
            // Route polyline
            if (_routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4.0,
                    color: AppColors.primary,
                  ),
                ],
              ),
            
            // Markers
            MarkerLayer(
              markers: [
                // Start marker
                if (widget.initialPosition != null)
                  Marker(
                    point: widget.initialPosition!,
                  width: 30,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                
                // End marker
                if (widget.destinationPosition != null)
                  Marker(
                    point: widget.destinationPosition!,
                  width: 30,
                  height: 30,
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
                ),
                
                // Current location marker
                if (_currentLocation != null)
                  Marker(
                    point: _currentLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        
        // Map controls
        if (widget.showControls)
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _buildMapControlButton(
                  Icons.my_location,
                  'Vị trí hiện tại',
                  _centerOnCurrentLocation,
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  Icons.zoom_in,
                  'Phóng to',
                  _zoomIn,
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  Icons.zoom_out,
                  'Thu nhỏ',
                  _zoomOut,
                ),
              ],
            ),
          ),
        
        // Tracking status
        if (_isTracking)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đang theo dõi',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMapControlButton(IconData icon, String tooltip, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }
}
