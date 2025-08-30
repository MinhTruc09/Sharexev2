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

/// DTO cho driver data từ API (extends UserDto với thông tin vehicle)
class DriverDto extends UserDto {
  final String? licenseNumber;
  final String? licensePlate;
  final String? vehicleBrand;
  final String? vehicleModel;
  final String? vehicleColor;
  final int? numberOfSeats;
  final String? vehicleImageUrl;
  final String? licenseImageUrl;
  final String? driverStatus;

  const DriverDto({
    required super.id,
    required super.email,
    required super.fullName,
    super.phoneNumber,
    super.avatarUrl,
    super.role = 'driver',
    super.status,
    super.createdAt,
    super.updatedAt,
    this.licenseNumber,
    this.licensePlate,
    this.vehicleBrand,
    this.vehicleModel,
    this.vehicleColor,
    this.numberOfSeats,
    this.vehicleImageUrl,
    this.licenseImageUrl,
    this.driverStatus,
  });

  factory DriverDto.fromJson(Map<String, dynamic> json) {
    final userDto = UserDto.fromJson(json);
    
    return DriverDto(
      id: userDto.id,
      email: userDto.email,
      fullName: userDto.fullName,
      phoneNumber: userDto.phoneNumber,
      avatarUrl: userDto.avatarUrl,
      role: userDto.role,
      status: userDto.status,
      createdAt: userDto.createdAt,
      updatedAt: userDto.updatedAt,
      licenseNumber: json['licenseNumber'] as String? ?? json['license_number'] as String?,
      licensePlate: json['licensePlate'] as String? ?? json['license_plate'] as String?,
      vehicleBrand: json['vehicleBrand'] as String? ?? json['vehicle_brand'] as String? ?? json['brand'] as String?,
      vehicleModel: json['vehicleModel'] as String? ?? json['vehicle_model'] as String? ?? json['model'] as String?,
      vehicleColor: json['vehicleColor'] as String? ?? json['vehicle_color'] as String? ?? json['color'] as String?,
      numberOfSeats: json['numberOfSeats'] as int? ?? json['number_of_seats'] as int?,
      vehicleImageUrl: json['vehicleImageUrl'] as String? ?? json['vehicle_image_url'] as String?,
      licenseImageUrl: json['licenseImageUrl'] as String? ?? json['license_image_url'] as String?,
      driverStatus: json['driverStatus'] as String? ?? json['driver_status'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
      if (licensePlate != null) 'licensePlate': licensePlate,
      if (vehicleBrand != null) 'vehicleBrand': vehicleBrand,
      if (vehicleModel != null) 'vehicleModel': vehicleModel,
      if (vehicleColor != null) 'vehicleColor': vehicleColor,
      if (numberOfSeats != null) 'numberOfSeats': numberOfSeats,
      if (vehicleImageUrl != null) 'vehicleImageUrl': vehicleImageUrl,
      if (licenseImageUrl != null) 'licenseImageUrl': licenseImageUrl,
      if (driverStatus != null) 'driverStatus': driverStatus,
    });
    return json;
  }

  @override
  String toString() {
    return 'DriverDto(id: $id, email: $email, licensePlate: $licensePlate, status: $driverStatus)';
  }
}
