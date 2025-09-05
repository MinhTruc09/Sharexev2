import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/tracking/entities/tracking_payload.dart';
import 'package:sharexev2/data/models/tracking/entities/location_entity.dart';
import 'tracking_repository_interface.dart';
import 'tracking_repository_impl.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/data/services/tracking_service.dart';

class TrackingRepository implements TrackingRepositoryInterface {
  final TrackingRepositoryImpl _impl;

  TrackingRepository({TrackingService? service})
      : _impl = TrackingRepositoryImpl(
          service ?? ServiceLocator.get<TrackingService>(),
        );

  @override
  Future<void> startTracking(String rideId) => _impl.startTracking(rideId);

  @override
  Future<void> stopTracking(String rideId) => _impl.stopTracking(rideId);

  @override
  Future<LocationEntity?> getCurrentLocation(String rideId) => _impl.getCurrentLocation(rideId);

  @override
  Future<void> sendLocationUpdate(String rideId, LocationEntity location) => _impl.sendLocationUpdate(rideId, location);

  @override
  Stream<LocationEntity> subscribeToLocationUpdates(String rideId) => _impl.subscribeToLocationUpdates(rideId);

  @override
  Future<List<LocationEntity>> getTrackingHistory(String rideId) => _impl.getTrackingHistory(rideId);

  Future<ApiResponse<TrackingPayload>> sendDriverLocation(
    String rideId,
    TrackingPayload payload,
  ) =>
      _impl.sendDriverLocation(rideId, payload);
}


