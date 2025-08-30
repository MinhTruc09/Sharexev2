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

/// DTO cho Google login request
class GoogleLoginRequestDto {
  final String idToken;
  final String role; // 'passenger' or 'driver'
  final String? deviceId;
  final String? deviceName;

  const GoogleLoginRequestDto({
    required this.idToken,
    required this.role,
    this.deviceId,
    this.deviceName,
  });

  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      'role': role,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
    };
  }

  factory GoogleLoginRequestDto.fromJson(Map<String, dynamic> json) {
    return GoogleLoginRequestDto(
      idToken: json['idToken'] as String,
      role: json['role'] as String,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
    );
  }

  @override
  String toString() {
    return 'GoogleLoginRequestDto(role: $role, deviceId: $deviceId)';
  }
}
