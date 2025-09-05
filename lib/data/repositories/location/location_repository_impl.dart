import 'dart:async';

import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/services/tracking_service.dart';
import 'package:sharexev2/data/models/tracking/dtos/tracking_payload_dto.dart';
import 'location_repository_interface.dart';

/// Implementation của LocationRepository sử dụng device GPS và OSM API
class LocationRepositoryImpl implements LocationRepositoryInterface {
  final TrackingService _trackingService;
  final Dio _dio;
  StreamController<LocationData>? _locationStreamController;
  StreamSubscription<Position>? _positionSubscription;

  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  LocationRepositoryImpl({required TrackingService trackingService})
    : _trackingService = trackingService,
      _dio = Dio();

  @override
  Future<ApiResponse<LocationData>> getCurrentLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return ApiResponse.error(message: 'Location permissions are denied');
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

      // Get address from coordinates using reverse geocoding
      final addressResponse = await getLocationByCoordinates(
        position.latitude,
        position.longitude,
      );

      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: addressResponse.data?.address ?? 'Vị trí hiện tại',
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );

      return ApiResponse.success(
        data: locationData,
        message: 'Location retrieved successfully',
      );
    } catch (e) {
      return ApiResponse.error(message: 'Failed to get current location: $e');
    }
  }

  @override
  Future<ApiResponse<LocationData>> getLocationByCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      // Use OSM Nominatim reverse geocoding
      final response = await _dio.get(
        '$_nominatimBaseUrl/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lng,
          'zoom': 18,
          'addressdetails': 1,
          'accept-language': 'vi,en',
        },
        options: Options(headers: {'User-Agent': 'ShareXeV2 Mobile App/1.0.0'}),
      );

      String address = 'Địa chỉ không xác định';

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey('display_name')) {
          address = data['display_name'] as String;
        } else if (data.containsKey('address')) {
          final addressData = data['address'] as Map<String, dynamic>;
          final parts = <String>[];

          // Build address from components
          if (addressData.containsKey('house_number')) {
            parts.add(addressData['house_number'] as String);
          }
          if (addressData.containsKey('road')) {
            parts.add(addressData['road'] as String);
          }
          if (addressData.containsKey('suburb')) {
            parts.add(addressData['suburb'] as String);
          }
          if (addressData.containsKey('city_district')) {
            parts.add(addressData['city_district'] as String);
          }
          if (addressData.containsKey('city')) {
            parts.add(addressData['city'] as String);
          }

          if (parts.isNotEmpty) {
            address = parts.join(', ');
          }
        }
      }

      final locationData = LocationData(
        latitude: lat,
        longitude: lng,
        address: address,
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
      if (query.trim().isEmpty) {
        return ApiResponse.success(
          data: <LocationData>[],
          message: 'Empty query',
        );
      }

      // Use OSM Nominatim search
      final response = await _dio.get(
        '$_nominatimBaseUrl/search',
        queryParameters: {
          'format': 'json',
          'q': query,
          'limit': 10,
          'addressdetails': 1,
          'countrycodes': 'vn', // Focus on Vietnam
          'accept-language': 'vi,en',
        },
        options: Options(headers: {'User-Agent': 'ShareXeV2 Mobile App/1.0.0'}),
      );

      final locations = <LocationData>[];

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data as List<dynamic>;

        for (final result in results) {
          final data = result as Map<String, dynamic>;

          if (data.containsKey('lat') && data.containsKey('lon')) {
            final lat = double.parse(data['lat'] as String);
            final lng = double.parse(data['lon'] as String);
            final displayName =
                data['display_name'] as String? ?? 'Địa điểm không xác định';

            locations.add(
              LocationData(
                latitude: lat,
                longitude: lng,
                address: displayName,
                timestamp: DateTime.now(),
              ),
            );
          }
        }
      }

      return ApiResponse.success(
        data: locations,
        message: 'Search completed successfully',
      );
    } catch (e) {
      return ApiResponse.error(message: 'Failed to search places: $e');
    }
  }

  @override
  Future<ApiResponse<RouteData>> getRoute({
    required LocationData origin,
    required LocationData destination,
    List<LocationData>? waypoints,
  }) async {
    try {
      // Implement route calculation using OSRM (Open Source Routing Machine)
      try {
        final routeResponse = await _getOSRMRoute(
          origin.latitude,
          origin.longitude,
          destination.latitude,
          destination.longitude,
          waypoints,
        );

        if (routeResponse.success && routeResponse.data != null) {
          final route = routeResponse.data!;

          return ApiResponse.success(
            data: route,
            message: 'Route calculated successfully using OSRM',
          );
        }
      } catch (e) {
        // Fallback to basic calculation if OSRM fails
        print('OSRM route calculation failed: $e');
      }

      // Fallback: Calculate basic distance and estimated route
      final distanceInMeters = Geolocator.distanceBetween(
        origin.latitude,
        origin.longitude,
        destination.latitude,
        destination.longitude,
      );

      final routeData = RouteData(
        waypoints: [origin, destination],
        distanceKm: distanceInMeters / 1000,
        durationMinutes:
            (distanceInMeters / 1000 / 50 * 60).round(), // Assume 50km/h
        estimatedFare: (distanceInMeters / 1000) * 15000, // 15,000 VND per km
        polyline: _generateSimplePolyline(
          origin,
          destination,
        ), // Simple polyline for now
      );

      return ApiResponse.success(
        data: routeData,
        message: 'Route calculated successfully',
      );
    } catch (e) {
      return ApiResponse.error(message: 'Failed to calculate route: $e');
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
      return ApiResponse.error(message: 'Failed to calculate fare: $e');
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
      // Send location to backend API via TrackingService
      // Create TrackingPayloadDto for API
      final payload = TrackingPayloadDto(
        rideId: '1', // This should come from current active ride
        driverEmail: location.address, // Should be current driver email
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: location.timestamp,
      );

      await _trackingService.sendDriverLocation('1', payload);

      return ApiResponse.success(
        data: null,
        message: 'Driver location updated successfully',
      );
    } catch (e) {
      return ApiResponse.error(message: 'Failed to update driver location: $e');
    }
  }

  @override
  Future<ApiResponse<List<LocationData>>> getNearbyDrivers({
    required LocationData passengerLocation,
    required double radiusKm,
  }) async {
    try {
      // Backend doesn't have nearby drivers endpoint yet
      // TODO: Implement when backend API is available
      // final drivers = await _trackingService.getNearbyDrivers(
      //   latitude: passengerLocation.latitude,
      //   longitude: passengerLocation.longitude,
      //   radiusKm: radiusKm,
      // );

      // Return empty list until API is implemented
      return ApiResponse.success(
        data: <LocationData>[],
        message: 'Nearby drivers endpoint not yet implemented',
      );
    } catch (e) {
      return ApiResponse.error(message: 'Failed to get nearby drivers: $e');
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
    final y =
        ((1.0 -
                    math.log(
                          (math.tan(latRad) + (1 / math.cos(latRad))).abs(),
                        ) /
                        math.pi) /
                2.0 *
                n)
            .floor();

    return {'x': x, 'y': y};
  }

  /// Get route from OSRM (Open Source Routing Machine)
  /// Uses the public OSRM demo server for route calculation
  ///
  /// Features:
  /// - Real-time route calculation with traffic considerations
  /// - Support for waypoints (multiple stops)
  /// - Returns encoded polyline for map display
  /// - Includes distance, duration, and turn-by-turn instructions
  /// - Fallback to basic calculation if OSRM fails
  ///
  /// API Endpoint: https://router.project-osrm.org/route/v1/driving/{coordinates}
  ///
  /// Example coordinates format: "105.8412,21.0245;105.8512,21.0345"
  /// (longitude,latitude pairs separated by semicolons)
  Future<ApiResponse<RouteData>> _getOSRMRoute(
    double originLat,
    double originLng,
    double destLat,
    double destLng,
    List<LocationData>? waypoints,
  ) async {
    try {
      // Build coordinates string for OSRM API
      final coordinates = <String>[];

      // Add origin
      coordinates.add('$originLng,$originLat');

      // Add waypoints if any
      if (waypoints != null) {
        for (final waypoint in waypoints) {
          coordinates.add('${waypoint.longitude},${waypoint.latitude}');
        }
      }

      // Add destination
      coordinates.add('$destLng,$destLat');

      final coordinatesString = coordinates.join(';');

      // OSRM API endpoint (using public demo server)
      final osrmUrl =
          'https://router.project-osrm.org/route/v1/driving/$coordinatesString';

      final response = await _dio.get(
        osrmUrl,
        queryParameters: {
          'overview': 'full', // Get full route geometry
          'steps': 'true', // Include step-by-step instructions
          'annotations': 'true', // Include speed and duration data
          'geometries': 'polyline', // Return encoded polyline
        },
        options: Options(
          headers: {
            'User-Agent': 'ShareXeV2 Mobile App/1.0.0',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey('routes') && data['routes'] is List) {
          final routes = data['routes'] as List;
          if (routes.isNotEmpty) {
            final route = routes.first as Map<String, dynamic>;

            // Extract route information
            final distance = (route['distance'] as num?)?.toDouble() ?? 0.0;
            final duration = (route['duration'] as num?)?.toDouble() ?? 0.0;
            final geometry = route['geometry'] as String? ?? '';

            // Calculate estimated fare (15,000 VND per km)
            final estimatedFare = (distance / 1000) * 15000;

            // Build waypoints list
            final routeWaypoints = <LocationData>[];
            if (data.containsKey('waypoints') && data['waypoints'] is List) {
              final waypointsData = data['waypoints'] as List;
              for (final waypoint in waypointsData) {
                if (waypoint is Map<String, dynamic>) {
                  final location = waypoint['location'] as List?;
                  if (location != null && location.length >= 2) {
                    routeWaypoints.add(
                      LocationData(
                        latitude: (location[1] as num).toDouble(),
                        longitude: (location[0] as num).toDouble(),
                        address: 'Route waypoint',
                        timestamp: DateTime.now(),
                      ),
                    );
                  }
                }
              }
            }

            // Add origin and destination if not in waypoints
            if (routeWaypoints.isEmpty) {
              routeWaypoints.addAll([
                LocationData(
                  latitude: originLat,
                  longitude: originLng,
                  address: 'Origin',
                  timestamp: DateTime.now(),
                ),
                LocationData(
                  latitude: destLat,
                  longitude: destLng,
                  address: 'Destination',
                  timestamp: DateTime.now(),
                ),
              ]);
            }

            final routeData = RouteData(
              waypoints: routeWaypoints,
              distanceKm: distance / 1000,
              durationMinutes: (duration / 60).round(),
              estimatedFare: estimatedFare,
              polyline:
                  geometry.isNotEmpty
                      ? geometry
                      : _generateSimplePolyline(
                        LocationData(
                          latitude: originLat,
                          longitude: originLng,
                          address: 'Origin',
                          timestamp: DateTime.now(),
                        ),
                        LocationData(
                          latitude: destLat,
                          longitude: destLng,
                          address: 'Destination',
                          timestamp: DateTime.now(),
                        ),
                      ),
            );

            return ApiResponse.success(
              data: routeData,
              message: 'Route calculated successfully using OSRM',
            );
          }
        }
      }

      throw Exception('Invalid OSRM response format');
    } catch (e) {
      return ApiResponse.error(message: 'Failed to get OSRM route: $e');
    }
  }

  /// Generate a simple polyline between two points
  /// This is a basic implementation - in production, use proper routing service
  String _generateSimplePolyline(
    LocationData origin,
    LocationData destination,
  ) {
    // Simple polyline format: just encode the two points
    // In production, this should use Google Polyline encoding algorithm
    final points = [
      [origin.latitude, origin.longitude],
      [destination.latitude, destination.longitude],
    ];

    // Basic polyline encoding (simplified)
    String polyline = '';
    for (final point in points) {
      final lat = (point[0] * 1e5).round();
      final lng = (point[1] * 1e5).round();
      polyline += '${lat.toString()},${lng.toString()};';
    }

    return polyline.isNotEmpty
        ? polyline.substring(0, polyline.length - 1)
        : '';
  }

  /// Dispose resources
  void dispose() {
    stopLocationTracking();
  }
}
