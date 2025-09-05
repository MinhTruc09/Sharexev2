import 'package:sharexev2/data/models/tracking/entities/location_entity.dart';

/// Interface for tracking repository
abstract class TrackingRepositoryInterface {
  /// Start tracking for a specific ride
  Future<void> startTracking(String rideId);

  /// Stop tracking for a specific ride
  Future<void> stopTracking(String rideId);

  /// Get current location for a ride
  Future<LocationEntity?> getCurrentLocation(String rideId);

  /// Send location update
  Future<void> sendLocationUpdate(String rideId, LocationEntity location);

  /// Subscribe to location updates for a ride
  Stream<LocationEntity> subscribeToLocationUpdates(String rideId);

  /// Get tracking history for a ride
  Future<List<LocationEntity>> getTrackingHistory(String rideId);
}