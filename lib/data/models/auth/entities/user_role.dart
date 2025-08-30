// lib/data/models/auth/entities/user_role.dart
// Domain Value Object - User Role Enum

/// User roles trong hệ thống ShareXe
enum UserRole {
  passenger,
  driver,
  admin,
  unknown;

  /// Display name cho UI
  String get displayName {
    switch (this) {
      case UserRole.passenger:
        return 'Hành khách';
      case UserRole.driver:
        return 'Tài xế';
      case UserRole.admin:
        return 'Quản trị viên';
      case UserRole.unknown:
        return 'Không xác định';
    }
  }

  /// API value để gửi lên server
  String get apiValue {
    switch (this) {
      case UserRole.passenger:
        return 'PASSENGER';
      case UserRole.driver:
        return 'DRIVER';
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.unknown:
        return 'UNKNOWN';
    }
  }

  /// Business logic - quyền đặt chuyến
  bool get canBookRide => this == UserRole.passenger;

  /// Business logic - quyền tạo chuyến
  bool get canOfferRide => this == UserRole.driver;

  /// Business logic - quyền admin
  bool get hasAdminAccess => this == UserRole.admin;

  /// Parse từ string API response
  static UserRole fromApiValue(String? value) {
    switch (value?.toUpperCase()) {
      case 'PASSENGER':
        return UserRole.passenger;
      case 'DRIVER':
        return UserRole.driver;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.unknown;
    }
  }

  /// Parse từ string display name
  static UserRole fromDisplayName(String? displayName) {
    switch (displayName) {
      case 'Hành khách':
        return UserRole.passenger;
      case 'Tài xế':
        return UserRole.driver;
      case 'Quản trị viên':
        return UserRole.admin;
      default:
        return UserRole.unknown;
    }
  }
}

/// User actions trong hệ thống
enum UserAction {
  bookRide,
  offerRide,
  manageUsers,
  updateProfile,
  viewTrips,
  cancelTrip,
  rateTrip,
  chat,
}
