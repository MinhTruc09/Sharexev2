import 'package:sharexev2/config/env.dart';

/// 🧑‍💻 UserDTO - Đồng bộ với Swagger
class UserDTO {
  final int id;
  final String? avatarUrl;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;

  UserDTO({
    required this.id,
    this.avatarUrl,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    String? convertImageUrl(String? url) {
      if (url == null) return null;
      return url.replaceFirst('http://localhost:8080', Env().apiBaseUrl);
    }

    return UserDTO(
      id: json['id'] ?? 0,
      avatarUrl: convertImageUrl(json['avatarUrl']),
      fullName: json['fullName'] ?? "",
      email: json['email'] ?? "",
      phoneNumber: json["phoneNumber"] ?? json["phone"] ?? "",
      role: json["role"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "avatarUrl": avatarUrl,
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "role": role,
    };
  }
}
