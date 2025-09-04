/// UserUpdateRequestDTO - Đồng bộ với Swagger API
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

  factory UserUpdateRequestDTO.fromJson(Map<String, dynamic> json) {
    return UserUpdateRequestDTO(
      phone: json['phone'] ?? '',
      fullName: json['fullName'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      numberOfSeats: json['numberOfSeats'] ?? 0,
      vehicleImageUrl: json['vehicleImageUrl'],
      licenseImageUrl: json['licenseImageUrl'],
      avatarImageUrl: json['avatarImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'fullName': fullName,
      'licensePlate': licensePlate,
      'brand': brand,
      'model': model,
      'color': color,
      'numberOfSeats': numberOfSeats,
      if (vehicleImageUrl != null) 'vehicleImageUrl': vehicleImageUrl,
      if (licenseImageUrl != null) 'licenseImageUrl': licenseImageUrl,
      if (avatarImageUrl != null) 'avatarImageUrl': avatarImageUrl,
    };
  }

  /// Validation theo pattern từ Swagger
  List<String> validate() {
    final errors = <String>[];

    // Phone validation: Support both formats from API docs
    // API docs show: "0|52057879" (with pipe separator)
    // Also support standard Vietnamese format: "052057879"
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$|^0\|[0-9]{8}$');
    if (!phoneRegex.hasMatch(phone)) {
      errors.add(
        'Số điện thoại không hợp lệ (định dạng: 052057879 hoặc 0|52057879)',
      );
    }

    // License plate validation: Support API docs format
    // API docs show: "96S-932097" (2 digits + 1-2 letters + dash + 4-6 digits)
    final licensePlateRegex = RegExp(r'^[0-9]{2}[A-Z]{1,2}-[0-9]{4,6}$');
    if (!licensePlateRegex.hasMatch(licensePlate)) {
      errors.add('Biển số xe không hợp lệ (định dạng: 96S-932097)');
    }

    // Number of seats minimum 1
    if (numberOfSeats < 1) {
      errors.add('Số ghế phải lớn hơn 0');
    }

    if (fullName.trim().isEmpty) {
      errors.add('Họ tên không được để trống');
    }

    if (brand.trim().isEmpty) {
      errors.add('Hãng xe không được để trống');
    }

    if (model.trim().isEmpty) {
      errors.add('Mẫu xe không được để trống');
    }

    if (color.trim().isEmpty) {
      errors.add('Màu xe không được để trống');
    }

    return errors;
  }
}
