// lib/data/models/auth/auth_response.dart
import 'package:sharexev2/data/models/auth/app_user.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final AppUser user;
  final DateTime expiresAt;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: AppUser.fromJson(json['user']),
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}
