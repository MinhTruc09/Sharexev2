// API DTO: Register Request
// Chỉ chứa data structure cho API communication

/// DTO cho passenger register request
class RegisterPassengerRequestDto {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  final String? deviceId;
  final String? deviceName;

  const RegisterPassengerRequestDto({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
    this.deviceId,
    this.deviceName,
  });

  // ===== JSON Serialization =====

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
    };
  }

  factory RegisterPassengerRequestDto.fromJson(Map<String, dynamic> json) {
    return RegisterPassengerRequestDto(
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
    );
  }

  @override
  String toString() {
    return 'RegisterPassengerRequestDto(email: $email, fullName: $fullName)';
  }
}

/// DTO cho driver register request
class RegisterDriverRequestDto {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String licenseNumber;
  final String? deviceId;
  final String? deviceName;

  const RegisterDriverRequestDto({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    required this.licenseNumber,
    this.deviceId,
    this.deviceName,
  });

  // ===== JSON Serialization =====

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'licenseNumber': licenseNumber,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
    };
  }

  factory RegisterDriverRequestDto.fromJson(Map<String, dynamic> json) {
    return RegisterDriverRequestDto(
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      licenseNumber: json['licenseNumber'] as String,
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
    );
  }

  @override
  String toString() {
    return 'RegisterDriverRequestDto(email: $email, fullName: $fullName, licenseNumber: $licenseNumber)';
  }
}
