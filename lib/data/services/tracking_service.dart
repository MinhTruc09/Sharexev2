import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/tracking/dtos/tracking_payload_dto.dart';
import 'package:sharexev2/config/app_config.dart';

class TrackingService {
  final ApiClient _api;

  TrackingService(this._api);

  /// Gửi vị trí driver (test qua HTTP theo Swagger)
  Future<ApiResponse<TrackingPayloadDto>> sendDriverLocation(
    String rideId,
    TrackingPayloadDto payload,
  ) async {
    final res = await _api.client.post(
      "${AppConfig.I.tracking.sendTest}$rideId",
      data: payload.toJson(),
    );

    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => TrackingPayloadDto.fromJson(json as Map<String, dynamic>),
    );
  }
}


