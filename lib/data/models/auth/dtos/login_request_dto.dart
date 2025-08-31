// API DTO: Login Request
// Chỉ chứa data structure cho API communication

/// DTO cho login request
class LoginRequestDto {
  final String email;
  final String password;
  final String? deviceId;
  final String? deviceName;

  const LoginRequestDto({
    required this.email,
    required this.password,
    this.deviceId,
    this.deviceName,
  });

  // ===== JSON Serialization =====

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
    };
  }

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) {
    return LoginRequestDto(
      email: json['email'] as String,
      password: json['password'] as String,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
    );
  }

  @override
  String toString() {
    return 'LoginRequestDto(email: $email, deviceId: $deviceId)';
  }
}

// GoogleLoginRequestDto moved to separate file: google_login_request_dto.dart
