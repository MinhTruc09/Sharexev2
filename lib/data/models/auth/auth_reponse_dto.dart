// lib/data/models/auth/auth_response_dto.dart
import 'package:sharexev2/data/models/auth/api/user_dto.dart';

class AuthResponseDto {
  final String accessToken;
  final String refreshToken;
  final UserDTO user;
  final DateTime expiresAt;

  AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: UserDTO.fromJson(json['user']),
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "access_token": accessToken,
      "refresh_token": refreshToken,
      "user": user.toJson(),
      "expires_at": expiresAt.toIso8601String(),
    };
  }
}
