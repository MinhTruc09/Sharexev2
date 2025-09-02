import '../dtos/booking_dto.dart';
import '../entities/booking_entity.dart';
import 'booking_entity_mapper.dart';

class BookingMapper {
  static BookingEntity fromDto(BookingDto dto) {
    return BookingEntityMapper.fromDto(dto);
  }

  /// Convert DTO to Entity (alias)
  static BookingEntity dtoToEntity(BookingDto dto) {
    return fromDto(dto);
  }

  /// Convert list of DTOs to list of Entities
  static List<BookingEntity> fromDtoList(List<BookingDto> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }
}
