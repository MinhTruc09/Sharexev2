enum DriverStatus { PENDING, APPROVED, REJECTED }

extension DriverStatusX on DriverStatus {
  static DriverStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case "APPROVED":
        return DriverStatus.APPROVED;
      case "REJECTED":
        return DriverStatus.REJECTED;
      case "PENDING":
      default:
        return DriverStatus.PENDING;
    }
  }

  String toJson() => name;
}

class DriverDTO {
  final int id;
  final DriverStatus status;
  final String? avatarImage;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final String licensePlate;
  final String brand;
  final String model;
  final String color;
  final int numberOfSeats;
  final String? vehicleImageUrl;
  final String? licenseImageUrl;

  DriverDTO({
    required this.id,
    required this.status,
    this.avatarImage,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.color,
    required this.numberOfSeats,
    this.vehicleImageUrl,
    this.licenseImageUrl,
  });

  factory DriverDTO.fromJson(Map<String, dynamic> json) {
    return DriverDTO(
      id: json['id'] ?? 0,
      status: DriverStatusX.fromString(json['status']),
      avatarImage: json['avatarImage'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      numberOfSeats: json['numberOfSeats'] ?? 0,
      vehicleImageUrl: json['vehicleImageUrl'],
      licenseImageUrl: json['licenseImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "status": status.toJson(),
      "avatarImage": avatarImage,
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "role": role,
      "licensePlate": licensePlate,
      "brand": brand,
      "model": model,
      "color": color,
      "numberOfSeats": numberOfSeats,
      "vehicleImageUrl": vehicleImageUrl,
      "licenseImageUrl": licenseImageUrl,
    };
  }
}
