import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Location Service - Real location services with geocoding
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  SharedPreferences? _prefs;
  Position? _currentPosition;
  String? _currentAddress;

  /// Initialize location service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCachedLocation();
  }

  /// Get current position with real GPS
  Future<Position?> getCurrentPosition() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Cache position
      await _cacheLocation(_currentPosition!);
      
      return _currentPosition;
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Get address from coordinates (Reverse Geocoding)
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street}, ${place.locality}, ${place.administrativeArea}';
        return address;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
    }
  }

  /// Get coordinates from address (Geocoding)
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations[0];
        return LatLng(location.latitude, location.longitude);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      return null;
    }
  }

  /// Calculate distance between two points
  double calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  /// Calculate ETA based on distance and average speed
  Duration calculateETA(double distanceKm, double averageSpeedKmh) {
    double hours = distanceKm / averageSpeedKmh;
    return Duration(minutes: (hours * 60).round());
  }

  /// Get current address
  Future<String?> getCurrentAddress() async {
    if (_currentPosition != null) {
      _currentAddress = await getAddressFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }
    return _currentAddress;
  }

  /// Cache location to SharedPreferences
  Future<void> _cacheLocation(Position position) async {
    if (_prefs != null) {
      await _prefs!.setDouble('cached_lat', position.latitude);
      await _prefs!.setDouble('cached_lng', position.longitude);
      await _prefs!.setInt('cached_timestamp', DateTime.now().millisecondsSinceEpoch);
    }
  }

  /// Load cached location from SharedPreferences
  Future<void> _loadCachedLocation() async {
    if (_prefs != null) {
      final lat = _prefs!.getDouble('cached_lat');
      final lng = _prefs!.getDouble('cached_lng');
      final timestamp = _prefs!.getInt('cached_timestamp');
      
      if (lat != null && lng != null && timestamp != null) {
        // Use cached location if it's less than 5 minutes old
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (cacheAge < 5 * 60 * 1000) { // 5 minutes
          _currentPosition = Position(
            latitude: lat,
            longitude: lng,
            timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        }
      }
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get location permission status
  Future<LocationPermission> getLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Search places using geocoding
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      
      // Use geocoding to search for places
      final locations = await locationFromAddress(query);
      
      return locations.map((location) => {
        'name': query,
        'address': query,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'formatted_address': query,
      }).toList();
    } catch (e) {
      debugPrint('Error searching places: $e');
      return [];
    }
  }
}
