import 'package:equatable/equatable.dart';

/// Driver Status for API communication (DTO-specific)
enum DriverApiStatus {
  pending,
  approved,
  rejected,
  suspended;

  String get value {
    switch (this) {
      case DriverApiStatus.pending:
        return 'PENDING';
      case DriverApiStatus.approved:
        return 'APPROVED';
      case DriverApiStatus.rejected:
        return 'REJECTED';
      case DriverApiStatus.suspended:
        return 'SUSPENDED';
    }
  }

  static DriverApiStatus fromValue(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return DriverApiStatus.pending;
      case 'APPROVED':
        return DriverApiStatus.approved;
      case 'REJECTED':
        return DriverApiStatus.rejected;
      case 'SUSPENDED':
        return DriverApiStatus.suspended;
      default:
        throw ArgumentError('Unknown driver status: $value');
    }
  }
}

/// Driver DTO for API communication
class DriverDto extends Equatable {
  final int id;
  final DriverApiStatus status;
  final String? avatarImage;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String licensePlate;
  final String brand;
  final String model;
  final String color;
  final int numberOfSeats;
  final String? vehicleImage;
  final String? licenseImage;

  const DriverDto({
    required this.id,
    required this.status,
    this.avatarImage,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.color,
    required this.numberOfSeats,
    this.vehicleImage,
    this.licenseImage,
  });

  /// Create from JSON
  factory DriverDto.fromJson(Map<String, dynamic> json) {
    return DriverDto(
      id: json['id'] ?? 0,
      status: DriverApiStatus.fromValue(json['status'] ?? 'PENDING'),
      avatarImage: json['avatarImage'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      numberOfSeats: json['numberOfSeats'] ?? 4,
      vehicleImage: json['vehicleImage'],
      licenseImage: json['licenseImage'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.value,
      'avatarImage': avatarImage,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'licensePlate': licensePlate,
      'brand': brand,
      'model': model,
      'color': color,
      'numberOfSeats': numberOfSeats,
      'vehicleImage': vehicleImage,
      'licenseImage': licenseImage,
    };
  }

  /// Copy with
  DriverDto copyWith({
    int? id,
    DriverApiStatus? status,
    String? avatarImage,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? licensePlate,
    String? brand,
    String? model,
    String? color,
    int? numberOfSeats,
    String? vehicleImage,
    String? licenseImage,
  }) {
    return DriverDto(
      id: id ?? this.id,
      status: status ?? this.status,
      avatarImage: avatarImage ?? this.avatarImage,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      licensePlate: licensePlate ?? this.licensePlate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      numberOfSeats: numberOfSeats ?? this.numberOfSeats,
      vehicleImage: vehicleImage ?? this.vehicleImage,
      licenseImage: licenseImage ?? this.licenseImage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        avatarImage,
        fullName,
        email,
        phoneNumber,
        licensePlate,
        brand,
        model,
        color,
        numberOfSeats,
        vehicleImage,
        licenseImage,
      ];

  @override
  String toString() => 'DriverDTO(id: $id, fullName: $fullName, status: $status)';
}
