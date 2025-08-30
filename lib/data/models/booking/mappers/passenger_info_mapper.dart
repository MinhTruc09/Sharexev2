import 'package:sharexev2/data/models/booking/passenger_info_dto.dart';
import 'package:sharexev2/data/models/booking/passenger_info.dart';

class PassengerInfoMapper {
  static PassengerInfo fromDto(PassengerInfoDto dto) {
    return PassengerInfo(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      phone: dto.phone,
      avatarUrl: dto.avatarUrl,
      status: dto.status,
      seatsBooked: dto.seatsBooked,
    );
  }
}
