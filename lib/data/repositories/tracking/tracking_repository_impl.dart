import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/tracking/dtos/tracking_payload_dto.dart';
import 'package:sharexev2/data/models/tracking/entities/tracking_payload.dart';
import 'package:sharexev2/data/models/tracking/entities/location_entity.dart';
import 'package:sharexev2/data/models/tracking/mappers/tracking_payload_mapper.dart';
import 'package:sharexev2/data/services/tracking_service.dart';
import 'tracking_repository_interface.dart';

class TrackingRepositoryImpl implements TrackingRepositoryInterface {
  final TrackingService _service;

  TrackingRepositoryImpl(this._service);

  @override
  Future<void> startTracking(String rideId) async {
    // Implementation for starting tracking
    // This would typically set up real-time location updates
  }

  @override
  Future<void> stopTracking(String rideId) async {
    // Implementation for stopping tracking
    // This would typically stop real-time location updates
  }

  @override
  Future<LocationEntity?> getCurrentLocation(String rideId) async {
    // Implementation for getting current location
    // This would typically get the latest location from the service
    return null;
  }

  @override
  Future<void> sendLocationUpdate(String rideId, LocationEntity location) async {
    // Implementation for sending location update
    // This would typically send location to the backend
  }

  @override
  Stream<LocationEntity> subscribeToLocationUpdates(String rideId) {
    // Implementation for subscribing to location updates
    // This would typically return a stream of location updates
    return Stream.empty();
  }

  @override
  Future<List<LocationEntity>> getTrackingHistory(String rideId) async {
    // Implementation for getting tracking history
    // This would typically get historical location data
    return [];
  }

  Future<ApiResponse<TrackingPayload>> sendDriverLocation(
    String rideId,
    TrackingPayload payload,
  ) async {
    final dto = TrackingPayloadMapper.toDto(payload);
    final res = await _service.sendDriverLocation(rideId, dto);
    final mapped = res.data != null
        ? TrackingPayloadMapper.fromDto(res.data as TrackingPayloadDto)
        : null;

    return ApiResponse<TrackingPayload>(
      message: res.message,
      statusCode: res.statusCode,
      data: mapped,
      success: res.success,
    );
  }
}


