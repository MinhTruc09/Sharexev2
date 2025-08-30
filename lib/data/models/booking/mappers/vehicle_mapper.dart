import 'package:sharexev2/data/models/booking/vehicle_dto.dart';
import 'package:sharexev2/data/models/booking/vehicle.dart';

class VehicleMapper {
  static Vehicle fromDto(VehicleDTO dto) {
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
