import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/services/tracking_service.dart';
import 'location_repository_interface.dart';

/// Implementation của LocationRepository sử dụng device GPS và OSM API
class LocationRepositoryImpl implements LocationRepositoryInterface {
  final TrackingService _trackingService;
  StreamController<LocationData>? _locationStreamController;
  StreamSubscription<Position>? _positionSubscription;

  LocationRepositoryImpl({
    required TrackingService trackingService,
  }) : _trackingService = trackingService;

  @override
  Future<ApiResponse<LocationData>> getCurrentLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return ApiResponse.error(
            message: 'Location permissions are denied',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return ApiResponse.error(
          message: 'Location permissions are permanently denied',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: 'Vị trí hiện tại', // TODO: Implement reverse geocoding
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );

      return ApiResponse.success(
        data: locationData,
        message: 'Location retrieved successfully',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to get current location: $e',
      );
    }
  }

  @override
  Future<ApiResponse<LocationData>> getLocationByCoordinates(double lat, double lng) async {
    try {
      // TODO: Implement OSM Nominatim reverse geocoding
      final locationData = LocationData(
        latitude: lat,
        longitude: lng,
        address: 'Địa chỉ từ tọa độ', // Placeholder until OSM integration
        timestamp: DateTime.now(),
      );

      return ApiResponse.success(
        data: locationData,
        message: 'Location found successfully',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to get location by coordinates: $e',
      );
    }
  }

  @override
  Future<ApiResponse<List<LocationData>>> searchPlaces(String query) async {
    try {
      // TODO: Implement OSM Nominatim search
      // For now, return empty list until OSM integration is complete
      return ApiResponse.success(
        data: <LocationData>[],
        message: 'Search completed (OSM integration pending)',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to search places: $e',
      );
    }
  }

  @override
  Future<ApiResponse<RouteData>> getRoute({
    required LocationData origin,
    required LocationData destination,
    List<LocationData>? waypoints,
  }) async {
    try {
      // TODO: Implement route calculation using OSRM or similar
      // Calculate basic distance for now
      final distanceInMeters = Geolocator.distanceBetween(
        origin.latitude,
        origin.longitude,
        destination.latitude,
        destination.longitude,
      );

      final routeData = RouteData(
        waypoints: [origin, destination],
        distanceKm: distanceInMeters / 1000,
        durationMinutes: (distanceInMeters / 1000 / 50 * 60).round(), // Assume 50km/h
        estimatedFare: (distanceInMeters / 1000) * 15000, // 15,000 VND per km
        polyline: '', // TODO: Generate polyline from route service
      );

      return ApiResponse.success(
        data: routeData,
        message: 'Route calculated successfully',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to calculate route: $e',
      );
    }
  }

  @override
  Future<ApiResponse<double>> calculateFareEstimate({
    required LocationData origin,
    required LocationData destination,
    required String vehicleType,
  }) async {
    try {
      final distanceInMeters = Geolocator.distanceBetween(
        origin.latitude,
        origin.longitude,
        destination.latitude,
        destination.longitude,
      );

      final distanceKm = distanceInMeters / 1000;
      
      // Basic fare calculation
      double farePerKm = 15000; // Default 15,000 VND per km
      
      // Adjust fare based on vehicle type
      switch (vehicleType.toLowerCase()) {
        case 'motorbike':
          farePerKm = 8000;
          break;
        case 'car':
          farePerKm = 15000;
          break;
        case 'van':
          farePerKm = 20000;
          break;
      }

      final estimatedFare = distanceKm * farePerKm;

      return ApiResponse.success(
        data: estimatedFare,
        message: 'Fare calculated successfully',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to calculate fare: $e',
      );
    }
  }

  @override
  Stream<LocationData> startLocationTracking() {
    _locationStreamController?.close();
    _locationStreamController = StreamController<LocationData>.broadcast();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        final locationData = LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          address: 'Tracking location',
          accuracy: position.accuracy,
          timestamp: DateTime.now(),
        );
        
        _locationStreamController?.add(locationData);
      },
      onError: (error) {
        _locationStreamController?.addError(error);
      },
    );

    return _locationStreamController!.stream;
  }

  @override
  Future<void> stopLocationTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    
    await _locationStreamController?.close();
    _locationStreamController = null;
  }

  @override
  Future<ApiResponse<void>> updateDriverLocation(LocationData location) async {
    try {
      // TODO: Send location to backend API
      // For now, just return success
      return ApiResponse.success(
        data: null,
        message: 'Driver location updated successfully',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to update driver location: $e',
      );
    }
  }

  @override
  Future<ApiResponse<List<LocationData>>> getNearbyDrivers({
    required LocationData passengerLocation,
    required double radiusKm,
  }) async {
    try {
      // TODO: Get nearby drivers from backend API
      // For now, return empty list
      return ApiResponse.success(
        data: <LocationData>[],
        message: 'Nearby drivers retrieved (API integration pending)',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to get nearby drivers: $e',
      );
    }
  }

  @override
  String getOSMTileUrl(int zoom, int x, int y) {
    return 'https://tile.openstreetmap.org/$zoom/$x/$y.png';
  }

  @override
  Map<String, int> coordinatesToTile(double lat, double lng, int zoom) {
    final latRad = lat * (3.14159265359 / 180.0);
    final n = (1 << zoom).toDouble();
    
    final x = ((lng + 180.0) / 360.0 * n).floor();
    final y = ((1.0 - math.log((math.tan(latRad) + (1 / math.cos(latRad))).abs()) / math.pi) / 2.0 * n).floor();
    
    return {'x': x, 'y': y};
  }

  /// Dispose resources
  void dispose() {
    stopLocationTracking();
  }
}
