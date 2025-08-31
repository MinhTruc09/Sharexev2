import 'package:equatable/equatable.dart';

/// Register Driver Request DTO for API communication
class RegisterDriverRequestDto extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String licensePlate;
  final String brand;
  final String model;
  final String color;
  final int numberOfSeats;
  final String? avatarUrl;
  final String? vehicleImageUrl;
  final String? licenseImageUrl;
  final String? deviceId;
  final String? deviceName;

  const RegisterDriverRequestDto({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.color,
    required this.numberOfSeats,
    this.avatarUrl,
    this.vehicleImageUrl,
    this.licenseImageUrl,
    this.deviceId,
    this.deviceName,
  });

  /// Create from JSON
  factory RegisterDriverRequestDto.fromJson(Map<String, dynamic> json) {
    return RegisterDriverRequestDto(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      numberOfSeats: json['numberOfSeats'] ?? 4,
      avatarUrl: json['avatarUrl'],
      vehicleImageUrl: json['vehicleImageUrl'],
      licenseImageUrl: json['licenseImageUrl'],
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
      'role': 'driver', // Always driver for this DTO
      'licensePlate': licensePlate,
      'brand': brand,
      'model': model,
      'color': color,
      'numberOfSeats': numberOfSeats,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (vehicleImageUrl != null) 'vehicleImageUrl': vehicleImageUrl,
      if (licenseImageUrl != null) 'licenseImageUrl': licenseImageUrl,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
    };
  }

  /// Copy with
  RegisterDriverRequestDto copyWith({
    String? email,
    String? password,
    String? fullName,
    String? phoneNumber,
    String? licensePlate,
    String? brand,
    String? model,
    String? color,
    int? numberOfSeats,
    String? avatarUrl,
    String? vehicleImageUrl,
    String? licenseImageUrl,
    String? deviceId,
    String? deviceName,
  }) {
    return RegisterDriverRequestDto(
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      licensePlate: licensePlate ?? this.licensePlate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      numberOfSeats: numberOfSeats ?? this.numberOfSeats,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      vehicleImageUrl: vehicleImageUrl ?? this.vehicleImageUrl,
      licenseImageUrl: licenseImageUrl ?? this.licenseImageUrl,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
    );
  }

  /// Validation
  List<String> validate() {
    final errors = <String>[];
    
    // Basic user validation
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
    
    // Driver-specific validation
    if (licensePlate.isEmpty) {
      errors.add('License plate is required');
    } else if (!_isValidLicensePlate(licensePlate)) {
      errors.add('Invalid license plate format');
    }
    
    if (brand.isEmpty) {
      errors.add('Vehicle brand is required');
    }
    
    if (model.isEmpty) {
      errors.add('Vehicle model is required');
    }
    
    if (color.isEmpty) {
      errors.add('Vehicle color is required');
    }
    
    if (numberOfSeats < 1 || numberOfSeats > 50) {
      errors.add('Number of seats must be between 1 and 50');
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

  /// License plate validation (Vietnamese format)
  bool _isValidLicensePlate(String plate) {
    // Vietnamese license plate format: 30A-12345 or 51B-123.45
    return RegExp(r'^[0-9]{2}[A-Z]{1,2}-[0-9]{3,5}(\.[0-9]{2})?$').hasMatch(plate);
  }

  @override
  List<Object?> get props => [
        email,
        password,
        fullName,
        phoneNumber,
        licensePlate,
        brand,
        model,
        color,
        numberOfSeats,
        avatarUrl,
        vehicleImageUrl,
        licenseImageUrl,
        deviceId,
        deviceName,
      ];

  @override
  String toString() => 'RegisterDriverRequestDto(email: $email, licensePlate: $licensePlate)';
}
