import 'package:equatable/equatable.dart';

/// Register Passenger Request DTO for API communication
class RegisterPassengerRequestDto extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;
  final String? deviceId;
  final String? deviceName;

  const RegisterPassengerRequestDto({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl,
    this.deviceId,
    this.deviceName,
  });

  /// Create from JSON
  factory RegisterPassengerRequestDto.fromJson(Map<String, dynamic> json) {
    return RegisterPassengerRequestDto(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': 'passenger', // Always passenger for this DTO
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
    };
  }

  /// Copy with
  RegisterPassengerRequestDto copyWith({
    String? email,
    String? password,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? deviceId,
    String? deviceName,
  }) {
    return RegisterPassengerRequestDto(
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
    );
  }

  /// Validation
  List<String> validate() {
    final errors = <String>[];
    
    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!_isValidEmail(email)) {
      errors.add('Invalid email format');
    }
    
    if (password.isEmpty) {
      errors.add('Password is required');
    } else if (password.length < 6) {
      errors.add('Password must be at least 6 characters');
    }
    
    if (fullName.isEmpty) {
      errors.add('Full name is required');
    } else if (fullName.length < 2) {
      errors.add('Full name must be at least 2 characters');
    }
    
    if (phoneNumber.isEmpty) {
      errors.add('Phone number is required');
    } else if (!_isValidPhoneNumber(phoneNumber)) {
      errors.add('Invalid phone number format');
    }
    
    return errors;
  }

  /// Check if valid
  bool get isValid => validate().isEmpty;

  /// Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Phone number validation (Vietnamese format)
  bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^(\+84|84|0)[3|5|7|8|9][0-9]{8}$').hasMatch(phone);
  }

  @override
  List<Object?> get props => [email, password, fullName, phoneNumber, avatarUrl, deviceId, deviceName];

  @override
  String toString() => 'RegisterPassengerRequestDto(email: $email, fullName: $fullName)';
}
