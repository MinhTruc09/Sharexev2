import '../entities/ride_entity.dart' as entity;
import '../dtos/ride_request_dto.dart' as dto;

/// Mapper để convert giữa RideRequestDTO và RideEntity
class RideMapper {
  /// Convert từ DTO sang Entity
  static entity.RideEntity fromDto(dto.RideRequestDTO dto) {
    return entity.RideEntity(
      id: dto.id,
      availableSeats: dto.availableSeats,
      driverName: dto.driverName,
      driverEmail: dto.driverEmail,
      departure: dto.departure,
      startLat: dto.startLat,
      startLng: dto.startLng,
      startAddress: dto.startAddress,
      startWard: dto.startWard,
      startDistrict: dto.startDistrict,
      startProvince: dto.startProvince,
      endLat: dto.endLat,
      endLng: dto.endLng,
      endAddress: dto.endAddress,
      endWard: dto.endWard,
      endDistrict: dto.endDistrict,
      endProvince: dto.endProvince,
      destination: dto.destination,
      startTime: dto.startTime,
      pricePerSeat: dto.pricePerSeat,
      totalSeat: dto.totalSeat,
      status: _mapStatus(dto.status),
    );
  }

  /// Convert từ Entity sang DTO
  static dto.RideRequestDTO toDto(entity.RideEntity entity) {
    return dto.RideRequestDTO(
      id: entity.id,
      availableSeats: entity.availableSeats ?? 0,
      driverName: entity.driverName,
      driverEmail: entity.driverEmail,
      departure: entity.departure,
      startLat: entity.startLat,
      startLng: entity.startLng,
      startAddress: entity.startAddress,
      startWard: entity.startWard,
      startDistrict: entity.startDistrict,
      startProvince: entity.startProvince,
      endLat: entity.endLat,
      endLng: entity.endLng,
      endAddress: entity.endAddress,
      endWard: entity.endWard,
      endDistrict: entity.endDistrict,
      endProvince: entity.endProvince,
      destination: entity.destination,
      startTime: entity.startTime,
      pricePerSeat: entity.pricePerSeat,
      totalSeat: entity.totalSeat,
      status: _mapStatusToDto(entity.status),
    );
  }

  /// Convert list từ DTO sang Entity
  static List<entity.RideEntity> fromDtoList(List<dto.RideRequestDTO> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }

  /// Convert list từ Entity sang DTO
  static List<dto.RideRequestDTO> toDtoList(List<entity.RideEntity> entities) {
    return entities.map((entity) => toDto(entity)).toList();
  }

  /// Map status từ DTO enum sang Entity enum
  static entity.RideStatus _mapStatus(dto.RideStatus dtoStatus) {
    switch (dtoStatus) {
      case dto.RideStatus.ACTIVE:
        return entity.RideStatus.active;
      case dto.RideStatus.IN_PROGRESS:
        return entity.RideStatus.inProgress;
      case dto.RideStatus.DRIVER_CONFIRMED:
        return entity.RideStatus.driverConfirmed;
      case dto.RideStatus.COMPLETED:
        return entity.RideStatus.completed;
      case dto.RideStatus.CANCELLED:
        return entity.RideStatus.cancelled;
    }
  }

  /// Map status từ Entity enum sang DTO enum
  static dto.RideStatus _mapStatusToDto(entity.RideStatus status) {
    switch (status) {
      case entity.RideStatus.active:
        return dto.RideStatus.ACTIVE;
      case entity.RideStatus.inProgress:
        return dto.RideStatus.IN_PROGRESS;
      case entity.RideStatus.driverConfirmed:
        return dto.RideStatus.DRIVER_CONFIRMED;
      case entity.RideStatus.completed:
        return dto.RideStatus.COMPLETED;
      case entity.RideStatus.cancelled:
        return dto.RideStatus.CANCELLED;
    }
  }
}
