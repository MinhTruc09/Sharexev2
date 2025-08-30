import '../tracking_payload_dto.dart';
import '../tracking_payload.dart';

class TrackingPayloadMapper {
  static TrackingPayload fromDto(TrackingPayloadDto dto) {
    return TrackingPayload(
      rideId: dto.rideId,
      driverEmail: dto.driverEmail,
      latitude: dto.latitude,
      longitude: dto.longitude,
      timestamp: dto.timestamp,
    );
  }

  static TrackingPayloadDto toDto(TrackingPayload entity) {
    return TrackingPayloadDto(
      rideId: entity.rideId,
      driverEmail: entity.driverEmail,
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.timestamp,
    );
  }
}
