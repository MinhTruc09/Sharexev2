// API DTO: User Data
// Chỉ chứa data structure cho API communication

/// DTO cho user data từ API
class UserDto {
  final int id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  const UserDto({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // ===== JSON Serialization =====

  factory UserDto.fromJson(Map<String, dynamic> json) {
    // Helper function để convert image URL
    String? convertImageUrl(String? url) {
      if (url == null || url.isEmpty) return null;
      
      // Convert localhost URLs to actual API base URL
      if (url.startsWith('http://localhost:8080')) {
        // This should be replaced with actual API base URL from config
        return url.replaceFirst('http://localhost:8080', 'https://api.sharexe.com');
      }
      
      return url;
    }

    return UserDto(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['full_name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? json['phone_number'] as String? ?? json['phone'] as String?,
      avatarUrl: convertImageUrl(json['avatarUrl'] as String? ?? json['avatar_url'] as String?),
      role: json['role'] as String? ?? 'passenger',
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'role': role,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  @override
  String toString() {
    return 'UserDto(id: $id, email: $email, fullName: $fullName, role: $role)';
  }
}

/// Backward-compat alias to satisfy older references expecting `UserDTO`
typedef UserDTO = UserDto;

// DriverDto moved to separate file: driver_dto.dart
