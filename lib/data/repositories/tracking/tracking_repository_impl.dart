import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/tracking/dtos/tracking_payload_dto.dart';
import 'package:sharexev2/data/models/tracking/entities/tracking_payload.dart';
import 'package:sharexev2/data/models/tracking/mappers/tracking_payload_mapper.dart';
import 'package:sharexev2/data/services/tracking_service.dart';
import 'tracking_repository_interface.dart';

class TrackingRepositoryImpl implements TrackingRepositoryInterface {
  final TrackingService _service;

  TrackingRepositoryImpl(this._service);

  @override
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


