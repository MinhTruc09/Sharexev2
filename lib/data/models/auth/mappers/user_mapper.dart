// User Mapper: Convert between UserDto and User Entity
// Chứa logic mapping với proper error handling

import '../app_user.dart'; // Import User entity
import '../dtos/user_dto.dart';
import '../dtos/driver_dto.dart';

/// Mapper cho User-related conversions
class UserMapper {
  // ===== User Entity Mapping =====

  /// Convert UserDto to User Entity
  static User userFromDto(UserDto dto) {
    try {
      return User.trusted(
        id: dto.id,
        email: dto.email,
        fullName: dto.fullName,
        phoneNumber: dto.phoneNumber,
        avatarUrl: dto.avatarUrl,
        role: _parseUserRole(dto.role),
        createdAt: _parseDateTime(dto.createdAt),
        updatedAt: _parseDateTime(dto.updatedAt),
        isActive: _parseUserStatus(dto.status),
      );
    } catch (e) {
      throw UserMappingException('Failed to map UserDto to User: $e');
    }
  }

  /// Backwards-compatible alias expected by older code
  static User fromUserDto(UserDto dto) => userFromDto(dto);

  /// Convert DriverDto to User Entity
  static User userFromDriverDto(DriverDto dto) {
    try {
      return User.trusted(
        id: dto.id,
        email: dto.email,
        fullName: dto.fullName,
        phoneNumber: dto.phoneNumber,
        avatarUrl: dto.avatarImage,
        role: UserRole.driver, // Always driver for DriverDto
        createdAt: DateTime.now(), // DriverDto doesn't have createdAt
        updatedAt: DateTime.now(), // DriverDto doesn't have updatedAt
        isActive: dto.status == DriverApiStatus.approved,
      );
    } catch (e) {
      throw UserMappingException('Failed to map DriverDto to User: $e');
    }
  }

  /// Backwards-compatible alias expected by older code
  static User fromDriverDto(DriverDto dto) => userFromDriverDto(dto);

  /// Convert User Entity to UserDto
  static UserDto dtoFromUser(User user) {
    try {
      return UserDto(
        id: user.id ?? 0,
        email: user.email.toString(),
        fullName: user.fullName,
        phoneNumber: user.phoneNumber?.toString(),
        avatarUrl: user.avatarUrl,
        role: _userRoleToString(user.role),
        status: user.isActive ? 'active' : 'inactive',
        createdAt: user.createdAt?.toIso8601String(),
        updatedAt: user.updatedAt?.toIso8601String(),
      );
    } catch (e) {
      throw UserMappingException('Failed to map User to UserDto: $e');
    }
  }

  /// Backwards-compatible alias expected by older code
  static UserDto toUserDto(User user) => dtoFromUser(user);

  // ===== Batch Mapping =====

  /// Convert list of UserDto to list of User entities
  static List<User> usersFromDtos(List<UserDto> dtos) {
    try {
      return dtos.map((dto) => userFromDto(dto)).toList();
    } catch (e) {
      throw UserMappingException('Failed to map UserDto list to User list: $e');
    }
  }

  /// Convert list of User entities to list of UserDto
  static List<UserDto> dtosFromUsers(List<User> users) {
    try {
      return users.map((user) => dtoFromUser(user)).toList();
    } catch (e) {
      throw UserMappingException('Failed to map User list to UserDto list: $e');
    }
  }

  // ===== Private Helper Methods =====

  /// Parse string role to UserRole enum
  static UserRole _parseUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'passenger':
        return UserRole.passenger;
      case 'driver':
        return UserRole.driver;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.unknown;
    }
  }

  /// Convert UserRole enum to string
  static String _userRoleToString(UserRole role) {
    switch (role) {
      case UserRole.passenger:
        return 'passenger';
      case UserRole.driver:
        return 'driver';
      case UserRole.admin:
        return 'admin';
      case UserRole.unknown:
        return 'unknown';
    }
  }

  /// Parse DateTime from string
  static DateTime? _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      // If parsing fails, return null instead of throwing
      return null;
    }
  }

  /// Parse user status from string
  static bool _parseUserStatus(String? status) {
    if (status == null) return true; // Default to active

    switch (status.toLowerCase()) {
      case 'active':
      case 'verified':
      case 'enabled':
        return true;
      case 'inactive':
      case 'disabled':
      case 'suspended':
      case 'banned':
        return false;
      default:
        return true; // Default to active
    }
  }

// _parseDriverStatus method removed - no longer needed

  // ===== Validation Helpers =====

  /// Validate UserDto before mapping
  static void validateUserDto(UserDto dto) {
    final errors = <String>[];

    if (dto.email.isEmpty) {
      errors.add('Email cannot be empty');
    }

    if (dto.fullName.isEmpty) {
      errors.add('Full name cannot be empty');
    }

    if (dto.role.isEmpty) {
      errors.add('Role cannot be empty');
    }

    if (errors.isNotEmpty) {
      throw UserMappingException('Invalid UserDto: ${errors.join(', ')}');
    }
  }

  /// Validate User entity before mapping
  static void validateUser(User user) {
    final validationErrors = user.validate();
    if (validationErrors.isNotEmpty) {
      throw UserMappingException(
        'Invalid User entity: ${validationErrors.join(', ')}',
      );
    }
  }

  // ===== Safe Mapping Methods =====

  /// Safely convert UserDto to User (returns null on error)
  static User? safeUserFromDto(UserDto dto) {
    try {
      return userFromDto(dto);
    } catch (e) {
      return null;
    }
  }

  /// Safely convert User to UserDto (returns null on error)
  static UserDto? safeDtoFromUser(User user) {
    try {
      return dtoFromUser(user);
    } catch (e) {
      return null;
    }
  }
}

/// Custom exception for user mapping errors
class UserMappingException implements Exception {
  final String message;

  const UserMappingException(this.message);

  @override
  String toString() => 'UserMappingException: $message';
}
