// lib/data/services/auth/auth_api_service.dart
// Service Implementation - Auth API Operations

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../config/app_config.dart';
import '../../models/auth/dtos/auth_response_dto.dart';
import '../../models/auth/dtos/login_request_dto.dart';
import '../../models/auth/dtos/register_request_dto.dart';
import '../../models/auth/dtos/refresh_token_request_dto.dart';
import 'auth_service_interface.dart';

/// Implementation của AuthServiceInterface
/// Handles tất cả auth API calls với proper error handling
class AuthApiService implements AuthServiceInterface {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  // ===== Authentication Operations =====

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    try {
      final response = await _apiClient.client.post(
        AppConfig.I.auth.login,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => AuthResponseDto.fromJson(data),
      );

      return apiResponse.data as AuthResponseDto;
    } on DioException catch (e) {
      throw _handleDioException(e, 'Login failed');
    } catch (e) {
      throw AuthServiceException('Unexpected error during login: $e');
    }
  }

  @override
  Future<AuthResponseDto> loginWithGoogle(GoogleLoginRequestDto request) async {
    try {
      final response = await _apiClient.client.post(
        AppConfig.I.auth.googleSignIn,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => AuthResponseDto.fromJson(data),
      );

      return apiResponse.data as AuthResponseDto;
    } on DioException catch (e) {
      throw _handleDioException(e, 'Google sign in failed');
    } catch (e) {
      throw AuthServiceException('Unexpected error during Google sign in: $e');
    }
  }

  @override
  Future<AuthResponseDto> refreshToken(RefreshTokenRequestDto request) async {
    try {
      final response = await _apiClient.client.post(
        AppConfig.I.auth.refresh,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => AuthResponseDto.fromJson(data),
      );

      return apiResponse.data as AuthResponseDto;
    } on DioException catch (e) {
      throw _handleDioException(e, 'Token refresh failed');
    } catch (e) {
      throw AuthServiceException('Unexpected error during token refresh: $e');
    }
  }

  // ===== Registration Operations =====

  @override
  Future<AuthResponseDto> registerPassenger(
    RegisterPassengerRequestDto request,
  ) async {
    try {
      final response = await _apiClient.client.post(
        AppConfig.I.auth.registerPassenger,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => AuthResponseDto.fromJson(data),
      );

      return apiResponse.data as AuthResponseDto;
    } on DioException catch (e) {
      throw _handleDioException(e, 'Passenger registration failed');
    } catch (e) {
      throw AuthServiceException(
        'Unexpected error during passenger registration: $e',
      );
    }
  }

  @override
  Future<AuthResponseDto> registerDriver(
    RegisterDriverRequestDto request,
  ) async {
    try {
      final response = await _apiClient.client.post(
        AppConfig.I.auth.registerDriver,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => AuthResponseDto.fromJson(data),
      );

      return apiResponse.data as AuthResponseDto;
    } on DioException catch (e) {
      throw _handleDioException(e, 'Driver registration failed');
    } catch (e) {
      throw AuthServiceException(
        'Unexpected error during driver registration: $e',
      );
    }
  }

  // ===== Session Management =====

  @override
  Future<void> logout(String accessToken) async {
    try {
      await _apiClient.client.post(
        AppConfig.I.auth.logout,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Logout failed');
    } catch (e) {
      throw AuthServiceException('Unexpected error during logout: $e');
    }
  }

  @override
  Future<bool> verifyToken(String accessToken) async {
    try {
      final response = await _apiClient.client.get(
        AppConfig.I.auth.verify,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return false; // Token is invalid
      }
      throw _handleDioException(e, 'Token verification failed');
    } catch (e) {
      throw AuthServiceException(
        'Unexpected error during token verification: $e',
      );
    }
  }

  // ===== User Profile Operations =====

  @override
  Future<Map<String, dynamic>> getCurrentUserProfile(String accessToken) async {
    try {
      final response = await _apiClient.client.get(
        AppConfig.I.auth.profile,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data,
      );

      return apiResponse.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to get user profile');
    } catch (e) {
      throw AuthServiceException('Unexpected error getting user profile: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserProfile(
    String accessToken,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await _apiClient.client.put(
        AppConfig.I.auth.profile,
        data: profileData,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data,
      );

      return apiResponse.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to update user profile');
    } catch (e) {
      throw AuthServiceException('Unexpected error updating user profile: $e');
    }
  }

  @override
  Future<void> changePassword(
    String accessToken,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _apiClient.client.post(
        AppConfig.I.auth.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to change password');
    } catch (e) {
      throw AuthServiceException('Unexpected error changing password: $e');
    }
  }

  // ===== Device Management =====

  @override
  Future<void> registerDevice(
    String accessToken,
    String deviceToken,
    String deviceType,
  ) async {
    try {
      await _apiClient.client.post(
        AppConfig.I.auth.registerDevice,
        data: {'deviceToken': deviceToken, 'deviceType': deviceType},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to register device');
    } catch (e) {
      throw AuthServiceException('Unexpected error registering device: $e');
    }
  }

  @override
  Future<void> unregisterDevice(String accessToken, String deviceToken) async {
    try {
      await _apiClient.client.delete(
        AppConfig.I.auth.unregisterDevice,
        data: {'deviceToken': deviceToken},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw _handleDioException(e, 'Failed to unregister device');
    } catch (e) {
      throw AuthServiceException('Unexpected error unregistering device: $e');
    }
  }

  // ===== Error Handling =====

  AuthServiceException _handleDioException(DioException e, String operation) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AuthNetworkException(
          '$operation: Connection timeout',
          code: 'TIMEOUT',
          statusCode: e.response?.statusCode,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? '$operation failed';

        if (statusCode == 401) {
          return AuthServiceException(
            'Unauthorized: $message',
            code: 'UNAUTHORIZED',
            statusCode: statusCode,
          );
        } else if (statusCode == 422) {
          return AuthValidationException(
            'Validation error: $message',
            code: 'VALIDATION_ERROR',
            statusCode: statusCode,
            details: e.response?.data,
          );
        } else {
          return AuthServerException(
            '$operation: $message',
            code: 'SERVER_ERROR',
            statusCode: statusCode,
            details: e.response?.data,
          );
        }

      case DioExceptionType.cancel:
        return AuthServiceException(
          '$operation was cancelled',
          code: 'CANCELLED',
        );

      case DioExceptionType.unknown:
      default:
        return AuthNetworkException(
          '$operation: Network error - ${e.message}',
          code: 'NETWORK_ERROR',
        );
    }
  }
}
