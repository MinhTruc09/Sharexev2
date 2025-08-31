import '../dtos/booking_dto.dart';
import '../entities/booking_entity.dart';
import 'booking_entity_mapper.dart';

class BookingMapper {
  static BookingEntity fromDto(BookingDto dto) {
    return BookingEntityMapper.fromDto(dto);
  }
}
