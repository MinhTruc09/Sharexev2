import '../dtos/vehicle_dto.dart';
import '../entities/vehicle.dart';

class VehicleMapper {
  static Vehicle fromDto(VehicleDto dto) {
    return Vehicle(
      licensePlate: dto.licensePlate,
      brand: dto.brand,
      model: dto.model,
      color: dto.color,
      numberOfSeats: dto.numberOfSeats,
      vehicleImageUrl: dto.vehicleImageUrl,
      licenseImageUrl: dto.licenseImageUrl,
    );
  }
}
