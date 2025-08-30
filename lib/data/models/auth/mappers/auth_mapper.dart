// Mappers: Convert between DTOs and Entities
// Chứa logic mapping với proper error handling

import 'package:sharexev2/data/models/auth/entities/user_role.dart';

import '../entities/auth_session.dart';
import '../entities/auth_credentials.dart';
import '../dtos/auth_response_dto.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/register_request_dto.dart';
import '../dtos/refresh_token_request_dto.dart';

/// Mapper cho Auth-related conversions
class AuthMapper {
  // ===== AuthSession Mapping =====

  /// Convert AuthResponseDto to AuthSession
  static AuthSession authSessionFromDto(AuthResponseDto dto) {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(Duration(seconds: dto.expiresIn));

      return AuthSession(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
        expiresAt: expiresAt,
        issuedAt: now,
      );
    } catch (e) {
      throw AuthMappingException(
        'Failed to map AuthResponseDto to AuthSession: $e',
      );
    }
  }

  /// Backwards-compatible name used by repository: sessionFromAuthResponse
  static AuthSession sessionFromAuthResponse(AuthResponseDto dto) =>
      authSessionFromDto(dto);

  /// Convert RefreshTokenResponseDto to AuthSession
  static AuthSession authSessionFromRefreshDto(RefreshTokenResponseDto dto) {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(Duration(seconds: dto.expiresIn));

      return AuthSession(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
        expiresAt: expiresAt,
        issuedAt: now,
      );
    } catch (e) {
      throw AuthMappingException(
        'Failed to map RefreshTokenResponseDto to AuthSession: $e',
      );
    }
  }

  /// Backwards-compatible name used by repository: sessionFromRefreshResponse
  static AuthSession sessionFromRefreshResponse(RefreshTokenResponseDto dto) =>
      authSessionFromRefreshDto(dto);

  /// Create RefreshTokenRequestDto from a refresh token string
  static RefreshTokenRequestDto refreshTokenRequest(String refreshToken) {
    return RefreshTokenRequestDto(refreshToken: refreshToken);
  }

  // ===== Request DTOs Mapping =====

  /// Convert AuthCredentials to LoginRequestDto
  static LoginRequestDto loginRequestFromCredentials(
    AuthCredentials credentials, {
    String? deviceId,
    String? deviceName,
  }) {
    try {
      final normalizedCredentials = credentials.normalize();

      return LoginRequestDto(
        email: normalizedCredentials.email,
        password: normalizedCredentials.password,
        deviceId: deviceId,
        deviceName: deviceName,
      );
    } catch (e) {
      throw AuthMappingException(
        'Failed to map AuthCredentials to LoginRequestDto: $e',
      );
    }
  }

  /// Backwards-compatible alias
  static LoginRequestDto loginRequest(
    AuthCredentials credentials, {
    String? deviceId,
    String? deviceName,
  }) => loginRequestFromCredentials(
    credentials,
    deviceId: deviceId,
    deviceName: deviceName,
  );

  /// Convert RegisterCredentials to RegisterPassengerRequestDto
  static RegisterPassengerRequestDto passengerRequestFromCredentials(
    RegisterCredentials credentials, {
    String? deviceId,
    String? deviceName,
  }) {
    try {
      final normalizedCredentials = credentials.normalize();

      return RegisterPassengerRequestDto(
        email: normalizedCredentials.email,
        password: normalizedCredentials.password,
        fullName: normalizedCredentials.fullName,
        phoneNumber: normalizedCredentials.phoneNumber,
        deviceId: deviceId,
        deviceName: deviceName,
      );
    } catch (e) {
      throw AuthMappingException(
        'Failed to map RegisterCredentials to RegisterPassengerRequestDto: $e',
      );
    }
  }

  /// Backwards-compatible alias used by repository
  static Object registerRequestFromCredentials(
    RegisterCredentials credentials,
    UserRole role, {
    String? deviceId,
    String? deviceName,
  }) {
    if (role == UserRole.driver) {
      return driverRequestFromCredentials(
        credentials,
        deviceId: deviceId,
        deviceName: deviceName,
      );
    }
    return passengerRequestFromCredentials(
      credentials,
      deviceId: deviceId,
      deviceName: deviceName,
    );
  }

  /// Convert RegisterCredentials to RegisterDriverRequestDto
  static RegisterDriverRequestDto driverRequestFromCredentials(
    RegisterCredentials credentials, {
    String? deviceId,
    String? deviceName,
  }) {
    try {
      final normalizedCredentials = credentials.normalize();

      if (normalizedCredentials.licenseNumber == null) {
        throw AuthMappingException(
          'License number is required for driver registration',
        );
      }

      if (normalizedCredentials.phoneNumber == null) {
        throw AuthMappingException(
          'Phone number is required for driver registration',
        );
      }

      return RegisterDriverRequestDto(
        email: normalizedCredentials.email,
        password: normalizedCredentials.password,
        fullName: normalizedCredentials.fullName,
        phoneNumber: normalizedCredentials.phoneNumber!,
        licenseNumber: normalizedCredentials.licenseNumber!,
        deviceId: deviceId,
        deviceName: deviceName,
      );
    } catch (e) {
      throw AuthMappingException(
        'Failed to map RegisterCredentials to RegisterDriverRequestDto: $e',
      );
    }
  }

  // ===== Google Login Mapping =====

  /// Convert Google ID token to GoogleLoginRequestDto
  static GoogleLoginRequestDto googleLoginRequest(
    String idToken,
    String role, {
    String? deviceId,
    String? deviceName,
  }) {
    try {
      if (idToken.isEmpty) {
        throw AuthMappingException('Google ID token cannot be empty');
      }

      if (!['passenger', 'driver'].contains(role.toLowerCase())) {
        throw AuthMappingException(
          'Invalid role: $role. Must be passenger or driver',
        );
      }

      return GoogleLoginRequestDto(
        idToken: idToken,
        role: role.toLowerCase(),
        deviceId: deviceId,
        deviceName: deviceName,
      );
    } catch (e) {
      throw AuthMappingException('Failed to create GoogleLoginRequestDto: $e');
    }
  }

  /// Backwards-compatible alias used by repository
  static GoogleLoginRequestDto googleSignInRequest(
    String idToken,
    UserRole role, {
    String? deviceId,
    String? deviceName,
  }) {
    return GoogleLoginRequestDto(
      idToken: idToken,
      role: role.toString().split('.').last.toLowerCase(),
      deviceId: deviceId,
      deviceName: deviceName,
    );
  }

  // ===== Validation Helpers =====

  /// Validate mapping input
  static void validateMappingInput(dynamic input, String inputType) {
    if (input == null) {
      throw AuthMappingException('$inputType cannot be null');
    }
  }

  /// Validate credentials before mapping
  static void validateCredentials(AuthCredentials credentials) {
    final errors = credentials.validate();
    if (errors.isNotEmpty) {
      throw AuthMappingException('Invalid credentials: ${errors.join(', ')}');
    }
  }

  /// Validate register credentials before mapping
  static void validateRegisterCredentials(
    RegisterCredentials credentials, {
    bool isDriver = false,
  }) {
    final errors = credentials.validate(requireStrongPassword: true);
    if (errors.isNotEmpty) {
      throw AuthMappingException(
        'Invalid register credentials: ${errors.join(', ')}',
      );
    }

    if (isDriver) {
      if (credentials.licenseNumber == null ||
          credentials.licenseNumber!.isEmpty) {
        throw AuthMappingException(
          'License number is required for driver registration',
        );
      }

      if (credentials.phoneNumber == null || credentials.phoneNumber!.isEmpty) {
        throw AuthMappingException(
          'Phone number is required for driver registration',
        );
      }
    }
  }
}

/// Custom exception for mapping errors
class AuthMappingException implements Exception {
  final String message;

  const AuthMappingException(this.message);

  @override
  String toString() => 'AuthMappingException: $message';
}
