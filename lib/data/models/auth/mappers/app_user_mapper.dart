// lib/data/models/auth/mappers/app_user_mapper.dart
// Backward Compatible Mapper for existing API DTOs

import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../app_user.dart';
import '../dtos/user_dto.dart';
import '../dtos/driver_dto.dart';

/// Backward compatible mapper for existing code
/// Maps from old API DTOs to new User entity
class AppUserMapper {
  /// Map từ UserDto (API) to User Entity
  static User fromUserDto(UserDto dto) {
    try {
      return User.trusted(
        id: dto.id,
        email: dto.email,
        fullName: dto.fullName,
        role: _parseRole(dto.role),
        phoneNumber: dto.phoneNumber?.isNotEmpty == true ? dto.phoneNumber : null,
        avatarUrl: dto.avatarUrl,
        isActive: true,
      );
    } catch (e) {
      throw UserMappingException('Failed to map UserDTO to User: $e');
    }
  }

  /// Map từ DriverDTO (API) to User Entity
  static User fromDriverDto(DriverDto dto) {
    try {
      return User.trusted(
        id: dto.id,
        email: dto.email,
        fullName: dto.fullName,
        role: UserRole.driver,
        phoneNumber: dto.phoneNumber.isNotEmpty ? dto.phoneNumber : null,
        avatarUrl: dto.avatarImage,
        isActive: dto.status == DriverApiStatus.approved,
      );
    } catch (e) {
      throw UserMappingException('Failed to map DriverDto to User: $e');
    }
  }

  /// Map từ Firebase User to User Entity
  static User fromFirebase(fb.User user) {
    try {
      return User.trusted(
        id: null,
        email: user.email ?? '',
        fullName: user.displayName ?? '',
        phoneNumber: user.phoneNumber,
        avatarUrl: user.photoURL,
        role: UserRole.passenger, // Default to passenger for Firebase users
        isActive: true,
      );
    } catch (e) {
      throw UserMappingException('Failed to map Firebase User to User: $e');
    }
  }

  /// Parse string role to UserRole enum
  static UserRole _parseRole(String? role) {
    switch (role?.toUpperCase()) {
      case "PASSENGER":
        return UserRole.passenger;
      case "DRIVER":
        return UserRole.driver;
      case "ADMIN":
        return UserRole.admin;
      default:
        return UserRole.unknown;
    }
  }
}

/// Exception cho User mapping errors
class UserMappingException implements Exception {
  final String message;

  const UserMappingException(this.message);

  @override
  String toString() => 'UserMappingException: $message';
}
