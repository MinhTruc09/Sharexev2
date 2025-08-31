import 'package:equatable/equatable.dart';
import 'user_entity.dart';
import 'user_role.dart';

/// Business Entity cho Driver - extends UserEntity
class DriverEntity extends UserEntity {
  final DriverStatus status;
  final String licensePlate;
  final String brand;
  final String model;
  final String color;
  final int numberOfSeats;
  final String? vehicleImageUrl;
  final String? licenseImageUrl;

  const DriverEntity({
    required super.id,
    super.avatarUrl,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    required this.status,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.color,
    required this.numberOfSeats,
    this.vehicleImageUrl,
    this.licenseImageUrl,
  }) : super(role: UserRole.driver);

  @override
  List<Object?> get props => [
        ...super.props,
        status,
        licensePlate,
        brand,
        model,
        color,
        numberOfSeats,
        vehicleImageUrl,
        licenseImageUrl,
      ];

  /// Business methods
  bool get isApproved => status == DriverStatus.approved;
  bool get isPending => status == DriverStatus.pending;
  bool get isRejected => status == DriverStatus.rejected;
  bool get canAcceptRides => isApproved;
  bool get hasVehicleImage => vehicleImageUrl != null && vehicleImageUrl!.isNotEmpty;
  bool get hasLicenseImage => licenseImageUrl != null && licenseImageUrl!.isNotEmpty;
  
  String get vehicleInfo => '$brand $model ($color)';
  String get vehicleFullInfo => '$brand $model - $color - $licensePlate';
  String get seatsInfo => '$numberOfSeats chỗ ngồi';
  
  String get statusDisplayName => status.displayName;

  @override
  DriverEntity copyWith({
    int? id,
    String? avatarUrl,
    String? fullName,
    String? email,
    String? phoneNumber,
    UserRole? role, // Required for UserEntity compatibility
    DriverStatus? status,
    String? licensePlate,
    String? brand,
    String? model,
    String? color,
    int? numberOfSeats,
    String? vehicleImageUrl,
    String? licenseImageUrl,
  }) {
    return DriverEntity(
      id: id ?? this.id,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      licensePlate: licensePlate ?? this.licensePlate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      numberOfSeats: numberOfSeats ?? this.numberOfSeats,
      vehicleImageUrl: vehicleImageUrl ?? this.vehicleImageUrl,
      licenseImageUrl: licenseImageUrl ?? this.licenseImageUrl,
    );
  }
}

enum DriverStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case DriverStatus.pending:
        return 'Chờ duyệt';
      case DriverStatus.approved:
        return 'Đã duyệt';
      case DriverStatus.rejected:
        return 'Bị từ chối';
    }
  }

  static DriverStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return DriverStatus.pending;
      case 'APPROVED':
        return DriverStatus.approved;
      case 'REJECTED':
        return DriverStatus.rejected;
      default:
        return DriverStatus.pending;
    }
  }
}
