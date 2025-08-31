import '../entities/booking_entity.dart';
import '../dtos/booking_dto.dart';
import '../dtos/vehicle_dto.dart';
import '../dtos/passenger_info_dto.dart';
import '../booking_status.dart' as dto_status;

/// Mapper để convert giữa BookingDTO và BookingEntity
class BookingEntityMapper {
  /// Convert từ DTO sang Entity
  static BookingEntity fromDto(BookingDto dto) {
    return BookingEntity(
      id: dto.id,
      rideId: dto.rideId,
      seatsBooked: dto.seatsBooked,
      status: _mapDtoStatusToEntity(dto.status),
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      totalPrice: dto.totalPrice,
      departure: dto.departure,
      destination: dto.destination,
      startTime: DateTime.tryParse(dto.startTime) ?? DateTime.now(),
      pricePerSeat: dto.pricePerSeat,
      rideStatus: dto.rideStatus,
      totalSeats: dto.totalSeats,
      availableSeats: dto.availableSeats,
      driverId: dto.driverId,
      driverName: dto.driverName,
      driverPhone: dto.driverPhone,
      driverEmail: dto.driverEmail,
      driverAvatarUrl: dto.driverAvatarUrl,
      driverStatus: dto.driverStatus,
      vehicle: dto.vehicle != null ? _mapVehicle(dto.vehicle!) : null,
      passengerId: dto.passengerId,
      passengerName: dto.passengerName,
      passengerPhone: dto.passengerPhone,
      passengerEmail: dto.passengerEmail,
      passengerAvatarUrl: dto.passengerAvatarUrl,
      fellowPassengers: dto.fellowPassengers
          .map((p) => _mapPassengerInfo(p))
          .toList(),
    );
  }

  /// Convert từ Entity sang DTO
  static BookingDto toDto(BookingEntity entity) {
    return BookingDto(
      id: entity.id,
      rideId: entity.rideId,
      seatsBooked: entity.seatsBooked,
      status: _mapEntityStatusToDto(entity.status),
      createdAt: entity.createdAt.toIso8601String(),
      totalPrice: entity.totalPrice,
      departure: entity.departure,
      destination: entity.destination,
      startTime: entity.startTime.toIso8601String(),
      pricePerSeat: entity.pricePerSeat,
      rideStatus: entity.rideStatus,
      totalSeats: entity.totalSeats,
      availableSeats: entity.availableSeats,
      driverId: entity.driverId,
      driverName: entity.driverName,
      driverPhone: entity.driverPhone,
      driverEmail: entity.driverEmail,
      driverAvatarUrl: entity.driverAvatarUrl ?? '',
      driverStatus: entity.driverStatus,
      vehicle: entity.vehicle != null ? _mapVehicleToDto(entity.vehicle!) : null,
      passengerId: entity.passengerId,
      passengerName: entity.passengerName,
      passengerPhone: entity.passengerPhone,
      passengerEmail: entity.passengerEmail,
      passengerAvatarUrl: entity.passengerAvatarUrl ?? '',
      fellowPassengers: entity.fellowPassengers
          .map((p) => _mapPassengerInfoToDto(p))
          .toList(),
    );
  }

  /// Convert list từ DTO sang Entity
  static List<BookingEntity> fromDtoList(List<BookingDto> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }

  /// Convert list từ Entity sang DTO
  static List<BookingDto> toDtoList(List<BookingEntity> entities) {
    return entities.map((entity) => toDto(entity)).toList();
  }

  /// Map VehicleDto to VehicleEntity
  static VehicleEntity _mapVehicle(VehicleDto dto) {
    return VehicleEntity(
      licensePlate: dto.licensePlate,
      brand: dto.brand,
      model: dto.model,
      color: dto.color,
      numberOfSeats: dto.numberOfSeats,
      vehicleImageUrl: dto.vehicleImageUrl,
      licenseImageUrl: dto.licenseImageUrl,
    );
  }

  /// Map VehicleEntity to VehicleDto
  static VehicleDto _mapVehicleToDto(VehicleEntity entity) {
    return VehicleDto(
      licensePlate: entity.licensePlate,
      brand: entity.brand,
      model: entity.model,
      color: entity.color,
      numberOfSeats: entity.numberOfSeats,
      vehicleImageUrl: entity.vehicleImageUrl ?? '',
      licenseImageUrl: entity.licenseImageUrl ?? '',
      licenseImagePublicId: '',
      vehicleImagePublicId: '',
    );
  }

  /// Map PassengerInfoDto to PassengerInfoEntity
  static PassengerInfoEntity _mapPassengerInfo(PassengerInfoDto dto) {
    return PassengerInfoEntity(
      id: dto.id,
      name: dto.name,
      phone: dto.phone,
      email: dto.email,
      avatarUrl: dto.avatarUrl,
      status: BookingStatus.fromString(dto.status.value),
      seatsBooked: dto.seatsBooked,
    );
  }

  /// Map PassengerInfoEntity to PassengerInfoDto
  static PassengerInfoDto _mapPassengerInfoToDto(PassengerInfoEntity entity) {
    return PassengerInfoDto(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      avatarUrl: entity.avatarUrl ?? '',
      status: _mapEntityStatusToDto(entity.status),
      seatsBooked: entity.seatsBooked,
    );
  }

  // Helper methods for status mapping
  static BookingStatus _mapDtoStatusToEntity(dto_status.BookingStatus dtoStatus) {
    // Map from DTO enum to Entity enum by name
    switch (dtoStatus) {
      case dto_status.BookingStatus.pending:
        return BookingStatus.pending;
      case dto_status.BookingStatus.accepted:
        return BookingStatus.accepted;
      case dto_status.BookingStatus.rejected:
        return BookingStatus.rejected;
      case dto_status.BookingStatus.inProgress:
        return BookingStatus.inProgress;
      case dto_status.BookingStatus.completed:
        return BookingStatus.completed;
      case dto_status.BookingStatus.cancelled:
        return BookingStatus.cancelled;
    }
  }

  static dto_status.BookingStatus _mapEntityStatusToDto(BookingStatus entityStatus) {
    // Map from Entity enum to DTO enum by name
    switch (entityStatus) {
      case BookingStatus.pending:
        return dto_status.BookingStatus.pending;
      case BookingStatus.accepted:
        return dto_status.BookingStatus.accepted;
      case BookingStatus.rejected:
        return dto_status.BookingStatus.rejected;
      case BookingStatus.inProgress:
        return dto_status.BookingStatus.inProgress;
      case BookingStatus.passengerConfirmed:
        return dto_status.BookingStatus.completed; // Map to completed
      case BookingStatus.driverConfirmed:
        return dto_status.BookingStatus.completed; // Map to completed
      case BookingStatus.completed:
        return dto_status.BookingStatus.completed;
      case BookingStatus.cancelled:
        return dto_status.BookingStatus.cancelled;
    }
  }
}
