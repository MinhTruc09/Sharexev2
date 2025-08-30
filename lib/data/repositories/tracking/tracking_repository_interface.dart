import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/tracking/entities/tracking_payload.dart';

abstract class TrackingRepositoryInterface {
  Future<ApiResponse<TrackingPayload>> sendDriverLocation(
    String rideId,
    TrackingPayload payload,
  );
}


