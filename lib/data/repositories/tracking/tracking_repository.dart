import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/tracking/entities/tracking_payload.dart';
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
  Future<ApiResponse<TrackingPayload>> sendDriverLocation(
    String rideId,
    TrackingPayload payload,
  ) =>
      _impl.sendDriverLocation(rideId, payload);
}


