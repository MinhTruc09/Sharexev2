import '../dtos/passenger_info_dto.dart';
import '../entities/passenger_info.dart';
import '../booking_status.dart';

class PassengerInfoMapper {
  static PassengerInfo fromDto(PassengerInfoDto dto) {
    return PassengerInfo(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      phone: dto.phone,
      avatarUrl: dto.avatarUrl,
      status: _mapStatus(dto.status),
      seatsBooked: dto.seatsBooked,
    );
  }

  static BookingStatus _mapStatus(BookingStatus statusValue) {
    return statusValue;
  }
}
