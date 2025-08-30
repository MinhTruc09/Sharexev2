// lib/data/models/auth/entities/user.dart
// Domain Entity - Pure business logic, không phụ thuộc external frameworks

import 'package:equatable/equatable.dart';
import 'package:sharexev2/data/models/auth/value_objects/email.dart';
import 'package:sharexev2/data/models/auth/value_objects/phone_number.dart';
import 'entities/user_role.dart';

// Backward-compat exports and type alias
export 'entities/user_role.dart';

typedef AppUser = User;

/// Domain Entity: User
/// Chứa business logic và validation, không phụ thuộc vào external frameworks
class User extends Equatable {
  final int? id;
  final Email email;
  final String fullName;
  final PhoneNumber? phoneNumber;
  final String? avatarUrl;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const User({
    this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  // ===== Factory Constructors =====

  /// Tạo User từ registration data
  factory User.fromRegistration({
    required String email,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
  }) {
    return User(
      email: Email(email),
      fullName: fullName.trim(),
      role: role,
      phoneNumber: phoneNumber != null ? PhoneNumber(phoneNumber) : null,
      isActive: true,
    );
  }

  /// Tạo User với validation minimal (cho trusted sources)
  factory User.trusted({
    int? id,
    required String email,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isActive = true,
  }) {
    return User(
      id: id,
      email: Email.trusted(email),
      fullName: fullName,
      role: role,
      phoneNumber:
          phoneNumber != null ? PhoneNumber.trusted(phoneNumber) : null,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  // ===== Business Logic =====

  /// Kiểm tra user có thể thực hiện action không
  bool canPerformAction(UserAction action) {
    if (!isActive) return false;

    switch (action) {
      case UserAction.bookRide:
        return role.canBookRide;
      case UserAction.offerRide:
        return role.canOfferRide;
      case UserAction.manageUsers:
        return role.hasAdminAccess;
      case UserAction.updateProfile:
      case UserAction.viewTrips:
      case UserAction.chat:
        return true; // All active users can do these
      case UserAction.cancelTrip:
      case UserAction.rateTrip:
        return role == UserRole.passenger || role == UserRole.driver;
    }
  }

  /// Validate toàn bộ user data
  List<String> validate() {
    final errors = <String>[];

    // Email đã được validate trong Email value object

    if (fullName.trim().length < 2) {
      errors.add('Tên phải có ít nhất 2 ký tự');
    }

    if (fullName.trim().length > 50) {
      errors.add('Tên không được quá 50 ký tự');
    }

    // Phone number đã được validate trong PhoneNumber value object

    return errors;
  }

  /// Kiểm tra user có hợp lệ không
  bool get isValid => validate().isEmpty;

  /// Kiểm tra có phải user mới không (chưa có ID)
  bool get isNewUser => id == null;

  /// Kiểm tra profile có đầy đủ không
  bool get hasCompleteProfile {
    return fullName.isNotEmpty &&
        phoneNumber != null &&
        avatarUrl != null &&
        avatarUrl!.isNotEmpty;
  }

  // ===== Copy Methods =====

  User copyWith({
    int? id,
    Email? email,
    String? fullName,
    PhoneNumber? phoneNumber,
    String? avatarUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // ===== Equatable =====

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phoneNumber,
    avatarUrl,
    role,
    createdAt,
    updatedAt,
    isActive,
  ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $role, isActive: $isActive)';
  }

  // ===== JSON Serialization =====

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email.toString(),
      'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber.toString(),
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'role': _userRoleToString(role),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User.trusted(
      id: json['id'] as int?,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: UserRole.fromApiValue(json['role'] as String?),
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static String _userRoleToString(UserRole role) {
    switch (role) {
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
}
