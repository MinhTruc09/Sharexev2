// API DTO: Auth Response
// Chỉ chứa data structure cho API communication

import 'user_dto.dart';

/// DTO cho auth response từ API
class AuthResponseDto {
  final String accessToken;
  final String refreshToken;
  final UserDto user;
  final int expiresIn; // seconds
  final String tokenType;
  final DateTime? expiresAt; // Thêm field từ file cũ

  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresIn,
    this.tokenType = 'Bearer',
    this.expiresAt,
  });

  // ===== JSON Serialization =====

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken:
          json['access_token'] as String? ?? json['accessToken'] as String,
      refreshToken:
          json['refresh_token'] as String? ?? json['refreshToken'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      expiresIn:
          json['expires_in'] as int? ?? json['expiresIn'] as int? ?? 3600,
      tokenType:
          json['token_type'] as String? ??
          json['tokenType'] as String? ??
          'Bearer',
      expiresAt:
          json['expires_at'] != null
              ? DateTime.parse(json['expires_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'expires_in': expiresIn,
      'token_type': tokenType,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AuthResponseDto(user: ${user.email}, expiresIn: $expiresIn, expiresAt: $expiresAt)';
  }
}

/// DTO cho refresh token response
class RefreshTokenResponseDto {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  const RefreshTokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.tokenType = 'Bearer',
  });

  factory RefreshTokenResponseDto.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponseDto(
      accessToken:
          json['access_token'] as String? ?? json['accessToken'] as String,
      refreshToken:
          json['refresh_token'] as String? ?? json['refreshToken'] as String,
      expiresIn:
          json['expires_in'] as int? ?? json['expiresIn'] as int? ?? 3600,
      tokenType:
          json['token_type'] as String? ??
          json['tokenType'] as String? ??
          'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'token_type': tokenType,
    };
  }

  @override
  String toString() {
    return 'RefreshTokenResponseDto(expiresIn: $expiresIn)';
  }
}
