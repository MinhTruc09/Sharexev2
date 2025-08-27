import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/config/app_config.dart';

class LocationService {
  final ApiClient _api = ApiClient();
  StreamSubscription<Position>? _locationSubscription;
  
  // Current location
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  /// Initialize location service
  Future<bool> initialize() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return true;
    } catch (e) {
      print('Error initializing location service: $e');
      return false;
    }
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _currentPosition;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Start location tracking
  void startLocationTracking({
    required Function(Position) onLocationUpdate,
    Duration interval = const Duration(seconds: 10),
  }) {
    _locationSubscription?.cancel();
    
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: Duration(seconds: 30),
      ),
    ).listen(
      (Position position) {
        _currentPosition = position;
        onLocationUpdate(position);
      },
      onError: (error) {
        print('Location tracking error: $error');
      },
    );
  }

  /// Stop location tracking
  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Calculate distance between two points
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      // TODO: Implement reverse geocoding with proper API
      // For now, return a formatted string
      return 'Lat: $lat, Lng: $lng';
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  /// Get coordinates from address (geocoding)
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      // TODO: Implement geocoding with proper API
      // For now, return null
      return null;
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  /// Update driver location to backend
  Future<bool> updateDriverLocation(String driverId, double lat, double lng) async {
    try {
      final response = await _api.client.post(
        '${AppConfig.I.tracking.sendTest}$driverId',
        data: {
          'latitude': lat,
          'longitude': lng,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating driver location: $e');
      return false;
    }
  }

  /// Get nearby places
  Future<List<Map<String, dynamic>>> searchNearbyPlaces(
    String query,
    LatLng location,
    {double radius = 5000}
  ) async {
    try {
      // TODO: Implement Google Places API or custom search
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      
      return [
        {
          'name': 'Trường Đại học Giao thông Vận tải',
          'address': '3 Cầu Giấy, Láng Thượng, Đống Đa, Hà Nội',
          'location': LatLng(location.latitude + 0.001, location.longitude + 0.001),
          'distance': 1200.0,
        },
        {
          'name': 'Bệnh viện Bạch Mai',
          'address': '78 Giải Phóng, Phương Mai, Đống Đa, Hà Nội',
          'location': LatLng(location.latitude - 0.001, location.longitude - 0.001),
          'distance': 800.0,
        },
      ];
    } catch (e) {
      print('Error searching nearby places: $e');
      return [];
    }
  }

  /// Calculate route between two points
  Future<List<LatLng>> calculateRoute(LatLng start, LatLng end) async {
    try {
      // TODO: Implement routing API (OSRM, Google Directions, etc.)
      // For now, return a simple straight line
      return [start, end];
    } catch (e) {
      print('Error calculating route: $e');
      return [start, end];
    }
  }

  /// Dispose resources
  void dispose() {
    stopLocationTracking();
  }
}
