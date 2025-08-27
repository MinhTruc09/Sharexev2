// lib/data/models/auth/api/login_request_dto.dart

class LoginRequestDTO {
  final String email;
  final String password;

  LoginRequestDTO({
    required this.email,
    required this.password,
  });

  factory LoginRequestDTO.fromJson(Map<String, dynamic> json) {
    return LoginRequestDTO(
      email: json["email"],
      password: json["password"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
    };
  }
}
