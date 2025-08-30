// lib/data/services/auth/auth_service_interface.dart
// Service Interface - Auth API Operations

import '../../models/auth/dtos/auth_response_dto.dart';
import '../../models/auth/dtos/login_request_dto.dart';
import '../../models/auth/dtos/register_request_dto.dart';
import '../../models/auth/dtos/refresh_token_request_dto.dart';

/// Interface cho Auth Service operations
/// Định nghĩa contract cho tất cả auth API calls
abstract class AuthServiceInterface {
  // ===== Authentication Operations =====

  /// Đăng nhập bằng email/password
  Future<AuthResponseDto> login(LoginRequestDto request);

  /// Đăng nhập bằng Google
  Future<AuthResponseDto> loginWithGoogle(GoogleLoginRequestDto request);

  /// Refresh access token
  Future<AuthResponseDto> refreshToken(RefreshTokenRequestDto request);

  // ===== Registration Operations =====

  /// Đăng ký passenger
  Future<AuthResponseDto> registerPassenger(
    RegisterPassengerRequestDto request,
  );

  /// Đăng ký driver
  Future<AuthResponseDto> registerDriver(RegisterDriverRequestDto request);

  // ===== Session Management =====

  /// Logout (invalidate token on server)
  Future<void> logout(String accessToken);

  /// Verify token validity
  Future<bool> verifyToken(String accessToken);

  // ===== User Profile Operations =====

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUserProfile(String accessToken);

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    String accessToken,
    Map<String, dynamic> profileData,
  );

  /// Change password
  Future<void> changePassword(
    String accessToken,
    String currentPassword,
    String newPassword,
  );

  // ===== Device Management =====

  /// Register device for push notifications
  Future<void> registerDevice(
    String accessToken,
    String deviceToken,
    String deviceType,
  );

  /// Unregister device
  Future<void> unregisterDevice(String accessToken, String deviceToken);
}

/// Exception cho Auth Service operations
class AuthServiceException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const AuthServiceException(
    this.message, {
    this.code,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'AuthServiceException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Network-related auth exceptions
class AuthNetworkException extends AuthServiceException {
  const AuthNetworkException(
    super.message, {
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Server-related auth exceptions
class AuthServerException extends AuthServiceException {
  const AuthServerException(
    super.message, {
    super.code,
    super.statusCode,
    super.details,
  });
}

/// Validation-related auth exceptions
class AuthValidationException extends AuthServiceException {
  const AuthValidationException(
    super.message, {
    super.code,
    super.statusCode,
    super.details,
  });
}
