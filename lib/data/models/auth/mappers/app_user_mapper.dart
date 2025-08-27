// lib/data/mappers/app_user_mapper.dart

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:sharexev2/data/models/auth/api/driver_dto.dart';
import 'package:sharexev2/data/models/auth/api/user_dto.dart';
import 'package:sharexev2/data/models/auth/app_user.dart';

class AppUserMapper {
  /// Map từ UserDTO (Swagger API - hành khách / user chung)
  static AppUser fromUserDto(UserDTO dto) {
    return AppUser(
      id: dto.id,
      email: dto.email,
      fullName: dto.fullName,
      role: _parseRole(dto.role), // ✅ parse string -> enum
      phoneNumber: dto.phoneNumber,
      avatarUrl: dto.avatarUrl,
    );
  }

  /// Map từ DriverDTO (Swagger API - tài xế)
  static AppUser fromDriverDto(DriverDTO dto) {
    return AppUser(
      id: dto.id,
      email: dto.email,
      fullName: dto.fullName,
      phoneNumber: dto.phoneNumber,
      avatarUrl: dto.avatarImage,
      role: UserRole.driver, // driver thì gán cứng enum
    );
  }

  /// Map từ Firebase User (Firebase Auth)
  static AppUser fromFirebase(fb.User user) {
    return AppUser(
      id: null,
      email: user.email ?? '',
      fullName: user.displayName ?? '',
      phoneNumber: user.phoneNumber,
      avatarUrl: user.photoURL,
      role: UserRole.passenger, // default gán passenger khi login Firebase
    );
  }

  /// Parse string -> enum role
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
