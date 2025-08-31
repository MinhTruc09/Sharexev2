import 'package:equatable/equatable.dart';
import 'user_role.dart';

/// Business Entity cho User - dùng trong UI và business logic
class UserEntity extends Equatable {
  final int id;
  final String? avatarUrl;
  final String fullName;
  final String email;
  final String phoneNumber;
  final UserRole role;

  const UserEntity({
    required this.id,
    this.avatarUrl,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  @override
  List<Object?> get props => [
        id,
        avatarUrl,
        fullName,
        email,
        phoneNumber,
        role,
      ];

  /// Business methods
  bool get isDriver => role == UserRole.driver;
  bool get isPassenger => role == UserRole.passenger;
  bool get isAdmin => role == UserRole.admin;
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
  
  String get displayName => fullName.isNotEmpty ? fullName : email;
  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }
  
  String get formattedPhone {
    if (phoneNumber.length == 10) {
      return '${phoneNumber.substring(0, 4)} ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7)}';
    }
    return phoneNumber;
  }

  UserEntity copyWith({
    int? id,
    String? avatarUrl,
    String? fullName,
    String? email,
    String? phoneNumber,
    UserRole? role,
  }) {
    return UserEntity(
      id: id ?? this.id,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }
}

// UserRole enum đã được định nghĩa trong user_role.dart
