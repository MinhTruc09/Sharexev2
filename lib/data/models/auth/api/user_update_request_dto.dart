class UserUpdateRequestDTO {
  final String phone;
  final String fullName;
  final String licensePlate;
  final String brand;
  final String model;
  final String color;
  final int numberOfSeats;
  final String? vehicleImageUrl;
  final String? licenseImageUrl;
  final String? avatarImageUrl;

  UserUpdateRequestDTO({
    required this.phone,
    required this.fullName,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.color,
    required this.numberOfSeats,
    this.vehicleImageUrl,
    this.licenseImageUrl,
    this.avatarImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "phone": phone,
      "fullName": fullName,
      "licensePlate": licensePlate,
      "brand": brand,
      "model": model,
      "color": color,
      "numberOfSeats": numberOfSeats,
      "vehicleImageUrl": vehicleImageUrl,
      "licenseImageUrl": licenseImageUrl,
      "avatarImageUrl": avatarImageUrl,
    };
  }
}
