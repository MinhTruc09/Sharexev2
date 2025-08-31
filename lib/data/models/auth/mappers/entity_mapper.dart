import '../entities/user_entity.dart';
import '../entities/driver_entity.dart';
import '../entities/user_role.dart';
import '../dtos/user_dto.dart';
import '../dtos/driver_dto.dart' as dto;

/// Mapper để convert giữa DTOs và Entities mới
class UserEntityMapper {
  /// Convert từ DTO sang Entity
  static UserEntity fromDto(UserDto dto) {
    return UserEntity(
      id: dto.id,
      avatarUrl: dto.avatarUrl,
      fullName: dto.fullName,
      email: dto.email,
      phoneNumber: dto.phoneNumber ?? '',
      role: UserRole.fromApiValue(dto.role),
    );
  }

  /// Convert từ Entity sang DTO
  static UserDto toDto(UserEntity entity) {
    return UserDto(
      id: entity.id,
      avatarUrl: entity.avatarUrl,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      role: entity.role.apiValue,
    );
  }

  /// Convert list từ DTO sang Entity
  static List<UserEntity> fromDtoList(List<UserDto> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }

  /// Convert list từ Entity sang DTO
  static List<UserDto> toDtoList(List<UserEntity> entities) {
    return entities.map((entity) => toDto(entity)).toList();
  }
}

/// Mapper để convert giữa DriverDTO và DriverEntity
class DriverEntityMapper {
  /// Convert từ DTO sang Entity
  static DriverEntity fromDto(dto.DriverDto dto) {
    return DriverEntity(
      id: dto.id,
      avatarUrl: dto.avatarImage,
      fullName: dto.fullName,
      email: dto.email,
      phoneNumber: dto.phoneNumber,
      status: DriverStatus.fromString(dto.status.name),
      licensePlate: dto.licensePlate,
      brand: dto.brand,
      model: dto.model,
      color: dto.color,
      numberOfSeats: dto.numberOfSeats,
      vehicleImageUrl: dto.vehicleImage,
      licenseImageUrl: dto.licenseImage,
    );
  }

  /// Convert từ Entity sang DTO
  static dto.DriverDto toDto(DriverEntity entity) {
    return dto.DriverDto(
      id: entity.id,
      status: dto.DriverApiStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == entity.status.name.toLowerCase(),
        orElse: () => dto.DriverApiStatus.pending,
      ),
      avatarImage: entity.avatarUrl,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      licensePlate: entity.licensePlate,
      brand: entity.brand,
      model: entity.model,
      color: entity.color,
      numberOfSeats: entity.numberOfSeats,
      vehicleImage: entity.vehicleImageUrl,
      licenseImage: entity.licenseImageUrl,
    );
  }

  /// Convert list từ DTO sang Entity
  static List<DriverEntity> fromDtoList(List<dto.DriverDto> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }

  /// Convert list từ Entity sang DTO
  static List<dto.DriverDto> toDtoList(List<DriverEntity> entities) {
    return entities.map((entity) => toDto(entity)).toList();
  }
}
