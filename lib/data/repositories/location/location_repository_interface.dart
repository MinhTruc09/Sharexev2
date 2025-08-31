import '../../../core/network/api_response.dart';

/// Location data model
class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final String? ward;
  final String? district;
  final String? province;
  final double? accuracy;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.ward,
    this.district,
    this.province,
    this.accuracy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'ward': ward,
    'district': district,
    'province': province,
    'accuracy': accuracy,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Route data model
class RouteData {
  final List<LocationData> waypoints;
  final double distanceKm;
  final int durationMinutes;
  final double estimatedFare;
  final String polyline;

  const RouteData({
    required this.waypoints,
    required this.distanceKm,
    required this.durationMinutes,
    required this.estimatedFare,
    required this.polyline,
  });
}

/// Interface cho Location Repository - OSM Integration
abstract class LocationRepositoryInterface {
  /// Get current location using device GPS
  Future<ApiResponse<LocationData>> getCurrentLocation();

  /// Reverse geocoding - Get address from coordinates using OSM Nominatim
  Future<ApiResponse<LocationData>> getLocationByCoordinates(double lat, double lng);

  /// Search places using OSM Nominatim API
  Future<ApiResponse<List<LocationData>>> searchPlaces(String query);

  /// Get route using OSM routing services (OSRM, GraphHopper, etc.)
  Future<ApiResponse<RouteData>> getRoute({
    required LocationData origin,
    required LocationData destination,
    List<LocationData>? waypoints,
  });

  /// Calculate fare estimate based on distance
  Future<ApiResponse<double>> calculateFareEstimate({
    required LocationData origin,
    required LocationData destination,
    required String vehicleType,
  });

  /// Start location tracking using device GPS
  Stream<LocationData> startLocationTracking();

  /// Stop location tracking
  Future<void> stopLocationTracking();

  /// Update driver location (for drivers) - Store locally or send to backend
  Future<ApiResponse<void>> updateDriverLocation(LocationData location);

  /// Get nearby drivers (for passengers) - From backend API
  Future<ApiResponse<List<LocationData>>> getNearbyDrivers({
    required LocationData passengerLocation,
    required double radiusKm,
  });

  /// OSM-specific methods

  /// Get map tiles for OSM display
  String getOSMTileUrl(int zoom, int x, int y);

  /// Convert coordinates to OSM tile coordinates
  Map<String, int> coordinatesToTile(double lat, double lng, int zoom);
}
